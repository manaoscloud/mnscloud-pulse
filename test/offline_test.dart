import 'dart:io';
import 'dart:typed_data';
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

  group('photos kept for later', () {
    final bytes = Uint8List.fromList(List.generate(64, (i) => i));

    test(
      'the store keeps a photo per mark and releases it once bound',
      () async {
        final store = await PunchStore.open();
        store.addPhoto('account-1', 'key-1', 'photo-1', bytes);
        store.addPhoto('account-1', 'key-1', 'photo-other', bytes);
        store.addPhoto(kioskPhotoOwner, 'key-k', 'photo-k', bytes);
        expect(store.readyPhotos('account-1'), isEmpty);
        expect(store.accounts(), ['account-1']);
        store.bindPhoto('key-1', 'punch-1');
        final ready = store.readyPhotos('account-1').single;
        expect(ready.punchUUID, 'punch-1');
        expect(ready.photoUUID, 'photo-1');
        expect(ready.bytes, bytes);
        store.removePhoto('key-1');
        expect(store.hasPhoto('key-1'), isFalse);
        expect(store.hasPhoto('key-k'), isTrue);
      },
    );

    test('the 24 hours count from the bound mark; unbound photos stay while queued', () async {
      final store = await PunchStore.open();
      final old = DateTime.now().subtract(const Duration(hours: 25));
      store.addPhoto(
        'account-1',
        'old',
        'p1',
        bytes,
        punchUUID: 'u1',
        createdAt: old,
      );
      store.addPhoto('account-1', 'new', 'p2', bytes, punchUUID: 'u2');
      // Created long ago but never bound: not dropped by age while its mark still waits.
      final waiting = mark('clock_in', 5);
      store.add('account-1', waiting);
      store.addPhoto(
        'account-1',
        waiting.idempotencyKey,
        'p3',
        bytes,
        createdAt: old,
      );
      store.addPhoto('account-1', 'gone', 'p4', bytes);
      store.dropOldPhotos();
      store.dropOrphanPhotos('account-1');
      expect(store.hasPhoto('old'), isFalse);
      expect(store.hasPhoto('new'), isTrue);
      expect(store.hasPhoto(waiting.idempotencyKey), isTrue);
      expect(store.hasPhoto('gone'), isFalse);
    });

    test('the upload decision deletes only 400/404/413', () {
      bool retry(String code, [int? status]) =>
          photoUploadRetry(PulseFailure(code, status: status));
      for (final keep in [
        ('networkError', null),
        ('requestError', 500),
        ('requestError', 503),
        ('requestError', 408),
        ('PULSE_RATE_LIMITED', 429),
        ('PULSE_ACCESS_DENIED', 403),
        ('HR_STORAGE_NOT_CONFIGURED', 409),
        ('HR_STORAGE_UNAVAILABLE', 503),
        ('PULSE_MODULE_UNAVAILABLE', 403),
        ('PULSE_DEVICE_CLOCK_SKEW', 401),
        ('PULSE_DEVICE_INVALID', 401),
      ]) {
        expect(retry(keep.$1, keep.$2), isTrue, reason: keep.$1);
      }
      for (final drop in [
        ('PULSE_PUNCH_NOT_FOUND', 404),
        ('requestError', 400),
        ('requestError', 413),
      ]) {
        expect(retry(drop.$1, drop.$2), isFalse, reason: drop.$1);
      }
      expect(
        photoAlreadyStored(const PulseFailure('PULSE_PUNCH_PHOTO_EXISTS')),
        isTrue,
      );
    });

    Future<DeviceGrants> grantsFor(
      PulseApi api,
      int counter, {
      int expiredDays = 3,
    }) async {
      await vault.write(
        'pulse.device.account-1',
        jsonEncode(
          DeviceGrantState(
            deviceUUID: 'device-1',
            privateKey: _photoKey.privateBase64,
            counter: counter,
            expiresAt: DateTime.now().toUtc().add(Duration(days: expiredDays)),
          ).toJson(),
        ),
      );
      return DeviceGrants(api: api, clock: ServerClock(), vault: vault);
    }

    test(
      'without a session the photo goes to the device route, signed',
      () async {
        final requests = <http.Request>[];
        final client = MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('/photo')) return json({'data': {}});
          return json({
            'data': {
              'item': {'TimePunchUUID': 'punch-9', 'Duplicate': 0},
            },
          });
        });
        final api = PulseApi(
          client: client,
          baseUrl: 'https://pulse.test/api/v1',
        );
        final grants = await grantsFor(api, 4);
        final sync = PunchSync(api: api, grants: grants, source: 'mobile');
        final queue = PunchQueue('account-1');
        final punch = mark('clock_in', 5);
        await queue.add(punch);
        await queue.addPhoto(punch.idempotencyKey, 'photo-uuid', bytes);
        final result = await sync.flush('account-1');
        expect(result.sent, 1);
        expect(result.photosSent, 1);
        final photo = requests.last;
        expect(photo.url.path, '/api/v1/pulse/device/punches/punch-9/photo');
        expect(photo.headers['content-type'], 'image/jpeg');
        expect(photo.url.queryParameters, {'photoId': 'photo-uuid'});
        expect(photo.headers.containsKey('X-Photo-Id'), isFalse);
        expect(photo.headers['X-Device-Id'], 'device-1');
        expect(photo.headers['authorization'], isNull);
        expect(photo.bodyBytes, bytes);
        // The punch used counter 5; the photo route signs it again without consuming one.
        expect(photo.headers['X-Device-Counter'], '5');
        final message = [
          'MNSCLOUD-PULSE-DEVICE-V1',
          'POST',
          '/pulse/device/punches/punch-9/photo?photoId=photo-uuid',
          photo.headers['X-Device-Timestamp']!,
          '5',
          sha256.convert(bytes).toString(),
        ].join('\n');
        expect(
          _photoKey.verify(message, photo.headers['X-Device-Signature']!),
          isTrue,
        );
        expect((await grants.read('account-1'))!.counter, 5);
        expect(await queue.readyPhotos(), isEmpty);
      },
    );

    test(
      'with a session the photo uses the session route; retry and drop rules',
      () async {
        var status = 200;
        var code = 'requestError';
        var photoCalls = 0;
        final client = MockClient((request) async {
          if (request.url.path.endsWith('/auth/signin')) return json(session());
          if (request.url.path.endsWith('/photo')) {
            photoCalls++;
            expect(request.url.path, '/api/v1/pulse/punches/punch-9/photo');
            return status == 200
                ? json({'data': {}})
                : json({'code': code}, status);
          }
          return json({
            'data': {
              'item': {'TimePunchUUID': 'punch-9', 'Duplicate': 0},
            },
          });
        });
        final api = PulseApi(
          client: client,
          baseUrl: 'https://pulse.test/api/v1',
        );
        await api.signIn('ABCD-EFGH', 'secret');
        final grants = DeviceGrants(
          api: api,
          clock: ServerClock(),
          vault: vault,
        );
        final sync = PunchSync(api: api, grants: grants, source: 'mobile');
        final queue = PunchQueue('account-1');
        final punch = mark('clock_in', 5);
        await queue.add(punch);
        await queue.addPhoto(punch.idempotencyKey, 'photo-uuid', bytes);
        // Server error: the photo stays and the pass reports no connection.
        status = 503;
        var result = await sync.flush('account-1');
        expect(result.sent, 1);
        expect(result.photosSent, 0);
        expect(await queue.readyPhotos(), hasLength(1));
        // Already stored (409): same as sent.
        status = 409;
        code = 'PULSE_PUNCH_PHOTO_EXISTS';
        result = await sync.flush('account-1');
        expect(result.photosSent, 1);
        expect(await queue.readyPhotos(), isEmpty);
        // A definitive refusal drops it (404 mark not found).
        await queue.addPhoto('other', 'photo-2', bytes, punchUUID: 'punch-9');
        status = 404;
        code = 'PULSE_PUNCH_NOT_FOUND';
        await sync.flush('account-1');
        expect(await queue.readyPhotos(), isEmpty);
        expect(photoCalls, 3);
      },
    );
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

final _photoKey = P256Key.generate();
