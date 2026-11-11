import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/punch_camera.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/kiosk/kiosk_client.dart';
import 'package:mnscloud_pulse/src/kiosk/kiosk_pin_dialog.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/p256.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:mnscloud_pulse/src/receipt/receipt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

const kioskUUID = '0b6f1f8e-3c1d-4a51-9a0e-2d3c4b5a6f70';
const profile = {
  'KioskUUID': kioskUUID,
  'Name': 'Recepção',
  'CompanyName': 'Empresa Exemplo',
  'PhotoRequired': true,
  'EmailReceipt': true,
};

Widget app(http.Client client) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en', 'US'),
  home: PulseShell(client: client, restoreSession: false),
);

Future<void> settle(WidgetTester tester, [int steps = 10]) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Fake API of a kiosk: verifies every signature with the key the device activated.
class KioskApi {
  final requests = <http.Request>[];
  String? publicKey;
  bool revoked = false;
  bool down = false;
  bool wrongPin = false;
  int lastCounter = 0;

  late final client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    if (down && !path.endsWith('/activate')) {
      throw http.ClientException('offline');
    }
    if (path.endsWith('/pulse/time')) {
      return json({
        'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
      });
    }
    if (path.endsWith('/pulse/kiosk/activate')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['activationCode'] != 'K7QM2XWP') {
        return json({'code': 'PULSE_KIOSK_ACTIVATION_INVALID'}, 400);
      }
      publicKey = body['publicKey'] as String;
      return json({
        'data': {
          'item': profile,
          'serverTime': DateTime.now().toUtc().toIso8601String(),
        },
      });
    }
    if (path.contains('/pulse/kiosk/')) {
      final counter = int.parse(request.headers['X-Kiosk-Counter']!);
      expect(counter, greaterThan(lastCounter));
      lastCounter = counter;
      expect(request.headers['X-Kiosk-Id'], kioskUUID);
      final message = pulseKioskSignatureMessage(
        request.method,
        path.substring(path.indexOf('/pulse/')),
        request.headers['X-Kiosk-Timestamp']!,
        '$counter',
        sha256.convert(request.bodyBytes).toString(),
      );
      expect(message.split('\n').first, 'MNSCLOUD-PULSE-KIOSK-V1');
      expect(request.headers['X-Kiosk-Signature'], isNotEmpty);
      if (revoked) {
        return json({
          'code': 'PULSE_KIOSK_INVALID',
          'reason': 'KIOSK_REVOKED',
        }, 401);
      }
      if (path.endsWith('/kiosk/me')) {
        return json({
          'data': {
            'item': profile,
            'serverTime': DateTime.now().toUtc().toIso8601String(),
          },
        });
      }
      if (path.endsWith('/kiosk/identify')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (wrongPin || body['pin'] != '4821') {
          return json({'code': 'PULSE_KIOSK_INVALID_PIN'}, 401);
        }
        return json({
          'data': {
            'item': {
              'EmployeeName': 'Test Employee',
              'CompanyName': 'Empresa Exemplo',
              'HasEmail': true,
              'LastPunchType': null,
              'NextPunchType': 'clock_in',
              'PhotoRequired': true,
            },
          },
        });
      }
      if (path.endsWith('/kiosk/punches')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return json({
          'data': {
            'item': {
              'TimePunchUUID': 'punch-1',
              'Type': body['type'],
              'OccurredAt': DateTime.now().toUtc().toIso8601String(),
              'NSR': 42,
              'Hash': 'abcdef0123456789abcdef',
              'Source': 'kiosk',
              'Duplicate': 0,
            },
            'employee': {
              'EmployeeName': 'Test Employee',
              'NextPunchType': 'break_start',
            },
          },
        });
      }
      if (path.endsWith('/kiosk/offline-punches')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['occurredAt'], isNotNull);
        return json({
          'data': body['pin'] == '4821'
              ? {
                  'status': 'recorded',
                  'item': {
                    'TimePunchUUID': 'off-${body['idempotencyKey']}',
                    'Offline': 1,
                  },
                }
              : {'status': 'rejected', 'reason': 'INVALID_PIN'},
        });
      }
      if (path.endsWith('/receipt/email')) {
        return json({
          'data': {
            'item': {
              'EmailDelivery': 'sent',
              'EmailRecipient': 'm***@example.com',
            },
          },
        });
      }
      if (path.endsWith('/photo')) {
        expect(request.headers['content-type'], 'image/jpeg');
        expect(request.headers['X-Photo-Id'], isNotEmpty);
        return json({
          'data': {
            'item': {'PhotoUUID': 'p', 'Duplicate': false},
          },
        });
      }
    }
    return json({'error': 'unexpected'}, 404);
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('time clock PIN rule matches the API', () {
    expect(validKioskPin('4821'), isTrue);
    expect(validKioskPin('905173'), isTrue);
    expect(validKioskPin('123'), isFalse);
    expect(validKioskPin('1234'), isFalse);
    expect(validKioskPin('9876'), isFalse);
    expect(validKioskPin('0000'), isFalse);
    expect(validKioskPin('1234567'), isFalse);
    expect(normalizeKioskCode(' k7qm-2xwp '), 'K7QM2XWP');
    expect(normalizeKioskCode('K7QM-2XW0'), isNull);
  });

  test('activation keeps the key and signs every request with a stored, growing counter', () async {
    final api = KioskApi();
    final client = KioskClient(httpClient: api.client);
    final profileRead = await client.activate('k7qm-2xwp', '24680');
    expect(profileRead.name, 'Recepção');
    final activation = api.requests.firstWhere(
      (r) => r.url.path.endsWith('/activate'),
    );
    final body = jsonDecode(activation.body) as Map<String, dynamic>;
    final state = (await client.read())!;
    final key = P256Key.fromPrivateBase64(state.privateKey);
    expect(body['publicKey'], key.spkiBase64);
    expect(
      key.verify(
        [
          'MNSCLOUD-PULSE-KIOSK-ACTIVATE-V1',
          'K7QM2XWP',
          body['timestamp'],
        ].join('\n'),
        body['signature'] as String,
      ),
      isTrue,
    );
    expect(await client.checkAdminPin('24680'), isTrue);
    expect(await client.checkAdminPin('11111'), isFalse);
    await client.me();
    await client.me();
    expect((await client.read())!.counter, 2);
    final me = api.requests.lastWhere((r) => r.url.path.endsWith('/kiosk/me'));
    final message = pulseKioskSignatureMessage(
      'GET',
      '/pulse/kiosk/me',
      me.headers['X-Kiosk-Timestamp']!,
      '2',
      sha256.convert(const <int>[]).toString(),
    );
    expect(key.verify(message, me.headers['X-Kiosk-Signature']!), isTrue);
    await expectLater(
      KioskClient(httpClient: api.client).activate('WRONG-CODE', '24680'),
      throwsA(isA<Object>()),
    );
  });

  testWidgets(
    'a device is activated from the sign-in page and opens as the time clock',
    (tester) async {
      final api = KioskApi();
      await tester.pumpWidget(app(api.client));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('useAsKiosk')));
      await tester.tap(find.byKey(const Key('useAsKiosk')));
      await settle(tester);
      expect(find.byKey(const Key('kioskActivation')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('kioskCode')), 'K7QM-2XWP');
      await tester.enterText(find.byKey(const Key('kioskAdminPin')), '24680');
      await tester.enterText(
        find.byKey(const Key('kioskAdminPinConfirm')),
        '24680',
      );
      await tester.tap(find.byKey(const Key('kioskActivate')));
      await settle(tester);
      expect(find.byKey(const Key('kioskShell')), findsOneWidget);
      expect(find.byKey(const Key('kioskName')), findsOneWidget);
      expect(find.text('Recepção'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'an employee punches with code, PIN and live photo; the clock returns to start',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = KioskApi();
      await KioskClient(httpClient: api.client).activate('K7QM2XWP', '24680');
      var shots = 0;
      punchPhotoCapture = (_) async {
        shots++;
        return Uint8List.fromList(List<int>.filled(16, 1));
      };
      addTearDown(() => punchPhotoCapture = capturePunchPhoto);
      await tester.pumpWidget(app(api.client));
      await settle(tester);
      expect(find.byKey(const Key('kioskShell')), findsOneWidget);
      // Wrong PIN: back to the code, nothing recorded.
      await tester.enterText(
        find.byKey(const Key('kioskLoginCode')),
        'ABCD-EFGH',
      );
      await tester.tap(find.byKey(const Key('kioskCodeContinue')));
      await settle(tester);
      for (final d in ['9', '9', '9', '1']) {
        await tester.tap(find.byKey(Key('kioskDigit$d')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('kioskPinOk')));
      await settle(tester);
      expect(find.text('Invalid code or PIN.'), findsOneWidget);
      expect(
        api.requests.where((r) => r.url.path.endsWith('/kiosk/punches')),
        isEmpty,
      );
      // Right PIN.
      await tester.enterText(
        find.byKey(const Key('kioskLoginCode')),
        'ABCD-EFGH',
      );
      await tester.tap(find.byKey(const Key('kioskCodeContinue')));
      await settle(tester);
      for (final d in ['4', '8', '2', '1']) {
        await tester.tap(find.byKey(Key('kioskDigit$d')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('kioskPinOk')));
      await settle(tester);
      expect(find.text('Hello, Test Employee'), findsOneWidget);
      await tester.tap(find.byKey(const Key('kioskRecord')));
      await settle(tester);
      expect(shots, 1);
      expect(find.byKey(const Key('kioskSaved')), findsOneWidget);
      expect(find.text('NSR 42'), findsOneWidget);
      final punch = api.requests.lastWhere(
        (r) => r.url.path.endsWith('/kiosk/punches'),
      );
      final body = jsonDecode(punch.body) as Map<String, dynamic>;
      expect(body['type'], 'clock_in');
      expect(body['loginCode'], 'ABCD-EFGH');
      expect(body['latitude'], -3.1);
      expect(
        api.requests.where((r) => r.url.path.endsWith('/photo')),
        hasLength(1),
      );
      // Receipt by e-mail to the registry address (printing is web only).
      expect(find.byKey(const Key('receiptPrint')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('receiptEmail')));
      await tester.tap(find.byKey(const Key('receiptEmail')));
      await settle(tester);
      expect(find.text('Receipt sent to m***@example.com.'), findsOneWidget);
      expect(
        api.requests.where(
          (r) => r.url.path.endsWith('/punch-1/receipt/email'),
        ),
        hasLength(1),
      );
      // Back to the start after the receipt, with nothing of the employee left.
      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
      expect(find.byKey(const Key('kioskLoginCode')), findsOneWidget);
      expect(find.text('Hello, Test Employee'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a revoked time clock stops; the administrator PIN leaves the mode',
    (tester) async {
      final api = KioskApi();
      await KioskClient(httpClient: api.client).activate('K7QM2XWP', '24680');
      api.revoked = true;
      await tester.pumpWidget(app(api.client));
      await settle(tester);
      expect(find.byKey(const Key('kioskRevoked')), findsOneWidget);
      await tester.tap(find.byKey(const Key('kioskExit')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('kioskExitPin')), '11111');
      await tester.tap(find.byKey(const Key('kioskExitConfirm')));
      await settle(tester);
      expect(find.text('Invalid administrator PIN.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('kioskExitPin')), '24680');
      await tester.tap(find.byKey(const Key('kioskExitConfirm')));
      await settle(tester);
      expect(find.byKey(const Key('kioskRevoked')), findsNothing);
      expect(find.byKey(const Key('useAsKiosk')), findsOneWidget);
      expect(await KioskClient(httpClient: api.client).read(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'the employee sets the time clock PIN with the current password',
    (tester) async {
      final sent = <Map<String, dynamic>>[];
      final api = PulseApi(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/pulse/kiosk-pin')) {
            sent.add(jsonDecode(request.body) as Map<String, dynamic>);
            final pin = sent.last['pin'];
            if (sent.last['currentPassword'] != 'secret-pass') {
              return json({'code': 'PULSE_INVALID_PASSWORD'}, 400);
            }
            return json({
              'data': {'HasKioskPin': pin == '4821'},
            });
          }
          return json({}, 404);
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showKioskPinDialog(context, api),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('kioskPinPassword')),
        'wrong',
      );
      await tester.enterText(find.byKey(const Key('kioskPinNew')), '1234');
      await tester.enterText(find.byKey(const Key('kioskPinConfirm')), '1234');
      await tester.tap(find.byKey(const Key('kioskPinSave')));
      await settle(tester);
      expect(sent, isEmpty);
      expect(find.textContaining('no sequence'), findsWidgets);
      await tester.enterText(find.byKey(const Key('kioskPinNew')), '4821');
      await tester.enterText(find.byKey(const Key('kioskPinConfirm')), '4821');
      await tester.tap(find.byKey(const Key('kioskPinSave')));
      await settle(tester);
      expect(find.byKey(const Key('kioskPinError')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('kioskPinPassword')),
        'secret-pass',
      );
      await tester.tap(find.byKey(const Key('kioskPinSave')));
      await settle(tester);
      expect(sent.last, {'currentPassword': 'secret-pass', 'pin': '4821'});
      expect(find.byKey(const Key('kioskPinDialog')), findsNothing);
      expect(find.text('Time clock PIN saved.'), findsOneWidget);
    },
  );

  test(
    'the printable receipt carries the art. 79 fields and escapes values',
    () {
      final html = receiptHtml(
        PunchReceipt.fromJson({
          'Title': 'Comprovante de Registro de Ponto do Trabalhador',
          'TimePunchUUID': 'p',
          'NSR': 7,
          'Hash': 'a0de',
          'TypeLabel': 'Saída',
          'OccurredAtText': '10/11/2026 18:00:00 (horário de Brasília)',
          'EmployerName': 'Aurora <Ltda>',
          'EmployerDocument': '12.345.678/0001-90',
          'EmployeeName': 'Marina',
          'EmployeeDocument': '***.***.789-00',
          'Collector': 'Relógio Recepção (00000001)',
          'Offline': true,
        }),
      );
      for (final part in [
        'Comprovante de Registro de Ponto do Trabalhador',
        'Aurora &lt;Ltda&gt;',
        '12.345.678/0001-90',
        '***.***.789-00',
        'Saída',
        'NSR',
        'a0de',
        'Relógio Recepção (00000001)',
        'sem conexão',
      ]) {
        expect(html, contains(part));
      }
      expect(html, isNot(contains('<Ltda>')));
    },
  );

  testWidgets(
    'without connection the mark waits on the device and is delivered later',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = KioskApi();
      final client = KioskClient(httpClient: api.client);
      await client.activate('K7QM2XWP', '24680');
      api.down = true;
      await tester.pumpWidget(app(api.client));
      await settle(tester);
      Future<void> offlineMark(String pin, String type) async {
        await tester.enterText(
          find.byKey(const Key('kioskLoginCode')),
          'ABCD-EFGH',
        );
        await tester.tap(find.byKey(const Key('kioskCodeContinue')));
        await settle(tester);
        for (final d in pin.split('')) {
          await tester.tap(find.byKey(Key('kioskDigit$d')));
          await tester.pump();
        }
        await tester.tap(find.byKey(const Key('kioskPinOk')));
        await settle(tester);
        expect(find.byKey(const Key('kioskOfflineTitle')), findsOneWidget);
        await tester.tap(find.byKey(Key('kioskType-$type')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('kioskRecord')));
        await settle(tester);
        expect(find.byKey(const Key('kioskOfflineSaved')), findsOneWidget);
        await tester.tap(find.byKey(const Key('kioskDone')));
        await settle(tester);
      }

      await offlineMark('4821', 'clock_in');
      await offlineMark('9991', 'break_start');
      expect(find.byKey(const Key('kioskPending')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      final kept = await client.queued();
      expect(kept.map((m) => m.type), ['clock_in', 'break_start']);
      expect(kept.first.latitude, -3.1);
      // Connection back: the next delivery pass sends both; the API records one and refuses one.
      api.down = false;
      await tester.pump(const Duration(minutes: 1));
      await settle(tester, 20);
      expect(
        api.requests.where(
          (r) => r.url.path.endsWith('/kiosk/offline-punches'),
        ),
        hasLength(2),
      );
      expect(await client.queued(), isEmpty);
      expect(find.byKey(const Key('kioskPending')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
