import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/src/core/ids.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_grant.dart';
import 'package:mnscloud_pulse/src/offline/p256.dart';
import 'package:mnscloud_pulse/src/offline/punch_sync.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

Map<String, dynamic> session() => {
  'data': {
    'accessToken': 'access-token',
    'refreshToken': 'refresh-1',
    'serverTime': DateTime.now().toUtc().toIso8601String(),
    'account': {
      'timeClockAccountUUID': 'account-1',
      'loginCode': 'ABCD-EFGH',
      'mustChangePassword': false,
    },
  },
};

QueuedPunch mark(String type, int minutesAgo) => QueuedPunch(
  idempotencyKey: uuidV4(),
  type: type,
  occurredAt: DateTime.now().toUtc().subtract(Duration(minutes: minutesAgo)),
);

void main() {
  late MemoryVault vault;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vault = MemoryVault();
    SecretVault.instance = vault;
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('the encrypted store keeps marks per account, oldest first', () async {
    final store = await PunchStore.open();
    final late = mark('break_start', 5);
    final early = mark('clock_in', 50);
    store.add('account-1', late);
    store.add('account-1', early);
    store.add('account-1', early);
    store.add('account-2', mark('clock_in', 1));
    expect(store.pending('account-1').map((p) => p.idempotencyKey), [
      early.idempotencyKey,
      late.idempotencyKey,
    ]);
    expect(store.accounts().toSet(), {'account-1', 'account-2'});
    store.remove(early.idempotencyKey);
    expect(store.pending('account-1'), hasLength(1));
  });

  test('a file store opens with the key and refuses another key', () {
    final path =
        '${Directory.systemTemp.createTempSync('pulse').path}/pulse.db';
    final db = sqlite3.open(path)..execute("PRAGMA key = 'first-key'");
    final store = PunchStore.memory(db)..add('account-1', mark('clock_in', 1));
    expect(store.encrypted, isTrue);
    db.close();
    final other = sqlite3.open(path)..execute("PRAGMA key = 'other-key'");
    expect(
      () => other.select('SELECT count(*) FROM sqlite_master'),
      throwsA(isA<SqliteException>()),
    );
    other.close();
  });

  test(
    'marks of the plain legacy queue move into the encrypted store',
    () async {
      final legacy = mark('clock_in', 10);
      SharedPreferences.setMockInitialValues({
        'pulse.queue.account-1': jsonEncode([legacy.toJson()]),
      });
      final loaded = await PunchQueue('account-1').load();
      expect(loaded.single.idempotencyKey, legacy.idempotencyKey);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'pulse.queue.account-1',
        ),
        isNull,
      );
    },
  );

  test(
    'registration proves the key and a refused key is replaced once',
    () async {
      final registrations = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/signin')) return json(session());
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        registrations.add(body);
        if (registrations.length == 1) {
          return json({'code': 'PULSE_DEVICE_KEY_REJECTED'}, 409);
        }
        return json({
          'data': {
            'item': {
              'deviceUUID': body['deviceUUID'],
              'grantExpiresAt': DateTime.now()
                  .toUtc()
                  .add(const Duration(days: 30))
                  .toIso8601String(),
              'lastCounter': 4,
            },
          },
        });
      });
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await api.signIn('ABCD-EFGH', 'secret');
      final grants = DeviceGrants(api: api, clock: ServerClock(), vault: vault);
      await grants.ensure('account-1');
      expect(registrations, hasLength(2));
      expect(
        registrations[0]['deviceUUID'],
        isNot(registrations[1]['deviceUUID']),
      );
      final state = (await grants.read('account-1'))!;
      expect(state.deviceUUID, registrations[1]['deviceUUID']);
      expect(state.counter, 4);
      expect(await grants.available('account-1'), isTrue);
      final key = P256Key.fromPrivateBase64(state.privateKey);
      expect(registrations[1]['publicKey'], key.spkiBase64);
      expect(
        key.verify(
          pulseDeviceRegisterMessage(
            state.deviceUUID,
            'account-1',
            registrations[1]['timestamp'] as String,
          ),
          registrations[1]['signature'] as String,
        ),
        isTrue,
      );
      // Renewed at most once a day.
      await grants.ensure('account-1');
      expect(registrations, hasLength(2));
    },
  );

  test(
    'without a session the queue goes signed by the device, counters grow',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return json({
          'data': {
            'item': {'Type': body['type'], 'Offline': true, 'Duplicate': 0},
          },
        });
      });
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      final key = P256Key.generate();
      await vault.write(
        'pulse.device.account-1',
        jsonEncode(
          DeviceGrantState(
            deviceUUID: 'device-1',
            privateKey: key.privateBase64,
            counter: 7,
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
          ).toJson(),
        ),
      );
      final grants = DeviceGrants(api: api, clock: ServerClock(), vault: vault);
      final sync = PunchSync(api: api, grants: grants, source: 'web');
      final queue = PunchQueue('account-1');
      final first = mark('clock_in', 30);
      final second = mark('break_start', 10);
      await queue.add(second);
      await queue.add(first);
      final result = await sync.flush('account-1');
      expect(result.sent, 2);
      expect(await queue.load(), isEmpty);
      expect(requests.map((r) => r.url.path), [
        '/api/v1/pulse/device/punches',
        '/api/v1/pulse/device/punches',
      ]);
      expect(requests.map((r) => r.headers['X-Device-Counter']), ['8', '9']);
      for (final request in requests) {
        expect(request.headers['authorization'], isNull);
        expect(request.headers['X-Device-Id'], 'device-1');
        final message = pulseDeviceSignatureMessage(
          'POST',
          '/pulse/device/punches',
          request.headers['X-Device-Timestamp']!,
          request.headers['X-Device-Counter']!,
          sha256.convert(utf8.encode(request.body)).toString(),
        );
        expect(
          key.verify(message, request.headers['X-Device-Signature']!),
          isTrue,
        );
        expect(jsonDecode(request.body)['offline'], isTrue);
      }
      expect(
        jsonDecode(requests.first.body)['idempotencyKey'],
        first.idempotencyKey,
      );
      expect((await grants.read('account-1'))!.counter, 9);
    },
  );

  test('a refused grant keeps the marks for the next session', () async {
    final client = MockClient(
      (request) async => json({
        'code': 'PULSE_DEVICE_INVALID',
        'reason': 'DEVICE_REVOKED',
      }, 401),
    );
    final api = PulseApi(client: client, baseUrl: 'https://pulse.test/api/v1');
    await vault.write(
      'pulse.device.account-1',
      jsonEncode(
        DeviceGrantState(
          deviceUUID: 'device-1',
          privateKey: P256Key.generate().privateBase64,
          counter: 1,
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
        ).toJson(),
      ),
    );
    final grants = DeviceGrants(api: api, clock: ServerClock(), vault: vault);
    final sync = PunchSync(api: api, grants: grants, source: 'web');
    await PunchQueue('account-1').add(mark('clock_in', 5));
    final result = await sync.flush('account-1');
    expect(result.sent, 0);
    expect(await PunchQueue('account-1').load(), hasLength(1));
    expect(await grants.available('account-1'), isFalse);
  });

  test(
    'a session ending mid-flush hands the mark to the device grant',
    () async {
      final paths = <String>[];
      final client = MockClient((request) async {
        final path = request.url.path;
        paths.add(path);
        if (path.endsWith('/auth/signin')) return json(session());
        if (path.endsWith('/auth/refresh')) {
          return json({'code': 'PULSE_SESSION_INVALID'}, 401);
        }
        if (path.endsWith('/pulse/punches')) {
          return json({'code': 'PULSE_SESSION_INVALID'}, 401);
        }
        return json({
          'data': {
            'item': {'Duplicate': 0},
          },
        });
      });
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await api.signIn('ABCD-EFGH', 'secret');
      await vault.write(
        'pulse.device.account-1',
        jsonEncode(
          DeviceGrantState(
            deviceUUID: 'device-1',
            privateKey: P256Key.generate().privateBase64,
            counter: 0,
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
          ).toJson(),
        ),
      );
      final grants = DeviceGrants(api: api, clock: ServerClock(), vault: vault);
      final sync = PunchSync(api: api, grants: grants, source: 'mobile');
      await PunchQueue('account-1').add(mark('clock_out', 5));
      final result = await sync.flush('account-1');
      expect(result.sessionEnded, 'PULSE_SESSION_INVALID');
      expect(result.sent, 1);
      expect(paths.last, '/api/v1/pulse/device/punches');
      expect(await PunchQueue('account-1').load(), isEmpty);
    },
  );

  test('the native refresh token is kept in secure storage', () async {
    final saved = <String?>[];
    final store = _Store(saved);
    final client = MockClient((request) async => json(session()));
    final api = PulseApi(
      client: client,
      baseUrl: 'https://pulse.test/api/v1',
      refreshStore: store,
    );
    await api.signIn('ABCD-EFGH', 'secret');
    await Future<void>.delayed(Duration.zero);
    expect(saved.last, 'refresh-1');
    final reopened = PulseApi(
      client: MockClient((request) async {
        expect(jsonDecode(request.body)['refreshToken'], 'refresh-1');
        return json(session());
      }),
      baseUrl: 'https://pulse.test/api/v1',
      refreshStore: store,
    );
    expect(await reopened.restore(), isNotNull);
    await reopened.signOut();
    await Future<void>.delayed(Duration.zero);
    expect(saved.last, isNull);
  });
}

class _Store implements RefreshTokenStore {
  _Store(this.saved);
  final List<String?> saved;

  @override
  Future<String?> read() async => saved.isEmpty ? null : saved.last;

  @override
  Future<void> write(String? token) async => saved.add(token);
}
