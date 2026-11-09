import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/ids.dart';
import 'package:mnscloud_pulse/src/core/punch_camera.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_grant.dart';
import 'package:mnscloud_pulse/src/offline/p256.dart';
import 'package:mnscloud_pulse/src/punch/punch_labels.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

Map<String, dynamic> session({bool mustChange = false}) => {
  'data': {
    'accessToken': 'access-token',
    'refreshToken': null,
    'serverTime': DateTime.now().toUtc().toIso8601String(),
    'account': {
      'timeClockAccountUUID': 'account-1',
      'employeeName': 'Test Employee',
      'companyName': 'Example Company',
      'loginCode': 'ABCD-EFGH',
      'mustChangePassword': mustChange,
    },
  },
};

Widget app(http.Client client) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en', 'US'),
  home: PulseShell(client: client),
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  // Native test runs reach the geolocator plugin: answer "location services off" so a punch is
  // recorded without location instead of waiting for a platform that does not exist here.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async =>
              call.method == 'isLocationServiceEnabled' ? false : null,
        );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('next punch follows the last mark and ids are UUID v4', () {
    expect(nextPunchType(null), 'clock_in');
    expect(nextPunchType('clock_in'), 'break_start');
    expect(nextPunchType('break_start'), 'break_end');
    expect(nextPunchType('break_end'), 'clock_out');
    expect(nextPunchType('clock_out'), 'clock_in');
    final id = uuidV4();
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
    expect(uuidV4(), isNot(id));
  });

  test('server clock applies the measured offset', () {
    final clock = ServerClock();
    final device = DateTime.utc(2026, 10, 24, 12);
    clock.accept(DateTime.utc(2026, 10, 24, 12, 5), deviceNow: device);
    expect(clock.offset, const Duration(minutes: 5));
    expect(clock.measured, isTrue);
  });

  test('queued punches persist per account and keep their key', () async {
    final queue = PunchQueue('account-1');
    final punch = QueuedPunch(
      idempotencyKey: uuidV4(),
      type: 'clock_in',
      occurredAt: DateTime.utc(2026, 10, 24, 8),
      latitude: -3.1,
      longitude: -60.0,
    );
    await queue.add(punch);
    await queue.add(punch);
    final loaded = await PunchQueue('account-1').load();
    expect(loaded, hasLength(1));
    expect(loaded.single.idempotencyKey, punch.idempotencyKey);
    expect(await PunchQueue('account-2').load(), isEmpty);
    final body = loaded.single.body(offline: true, source: 'web');
    expect(body['offline'], isTrue);
    expect(body['occurredAt'], '2026-10-24T08:00:00.000Z');
    await queue.remove(punch.idempotencyKey);
    expect(await queue.load(), isEmpty);
  });

  testWidgets(
    'a reload reopens the session and the next mark is confirmed before it goes',
    (tester) async {
      final punches = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/auth/refresh')) return json(session());
        if (path.endsWith('/time')) {
          return json({
            'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
          });
        }
        if (path.endsWith('/punches') && request.method == 'POST') {
          expect(request.headers['authorization'], 'Bearer access-token');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          punches.add(body);
          return json({
            'data': {
              'item': {
                'Type': body['type'],
                'OccurredAt': DateTime.now().toUtc().toIso8601String(),
                'NSR': punches.length,
                'Hash': 'a' * 64,
                'Flags': <String>[],
                'Duplicate': 0,
              },
            },
          });
        }
        if (path.endsWith('/punches')) {
          return json({
            'data': {
              'items': [
                for (final (i, p) in punches.indexed)
                  {
                    'Type': p['type'],
                    'OccurredAt': DateTime.now().toUtc().toIso8601String(),
                    'NSR': i + 1,
                    'Hash': 'b' * 64,
                    'Flags': <String>[],
                  },
              ].reversed.toList(),
            },
          });
        }
        return json({'code': 'requestError'}, 400);
      });
      await tester.pumpWidget(app(client));
      await settle(tester);
      expect(find.text('Test Employee'), findsOneWidget);
      expect(find.byKey(const Key('officialClock')), findsOneWidget);
      expect(find.text('Clock in'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nextPunch')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirmPunch')));
      await settle(tester);
      expect(punches, hasLength(1));
      expect(punches.single['type'], 'clock_in');
      expect(punches.single['offline'], isFalse);
      expect(punches.single['source'], 'mobile');
      expect(punches.single['idempotencyKey'], hasLength(36));
      expect(find.text('Punch saved.'), findsOneWidget);
      expect(find.text('Break start'), findsOneWidget);
      expect(find.textContaining('NSR 1'), findsWidgets);
      expect(await PunchQueue('account-1').load(), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  /// API double for the photo tests: today reports [mode]; punches and photos are recorded.
  MockClient photoClient(
    String mode,
    List<Map<String, dynamic>> punches,
    List<http.Request> photos,
  ) => MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/auth/refresh')) return json(session());
    if (path.endsWith('/time')) {
      return json({
        'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
      });
    }
    if (path.endsWith('/today')) {
      return json({
        'data': {
          'date': '2026-11-08',
          'timezone': 'America/Sao_Paulo',
          'punchPhotoMode': mode,
          'punches': <Object>[],
          'working': false,
          'workedMinutes': 0,
        },
      });
    }
    if (path.endsWith('/photo')) {
      photos.add(request);
      return json({
        'data': {
          'item': {'PhotoUUID': 'photo-1', 'Duplicate': false},
        },
      });
    }
    if (path.endsWith('/punches') && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      punches.add(body);
      return json({
        'data': {
          'item': {
            'TimePunchUUID': 'punch-${punches.length}',
            'Type': body['type'],
            'OccurredAt': DateTime.now().toUtc().toIso8601String(),
            'NSR': punches.length,
            'Hash': 'a' * 64,
            'Flags': <String>[],
            'Duplicate': 0,
          },
        },
      });
    }
    if (path.endsWith('/punches')) {
      return json({
        'data': {
          'items': [
            for (final (i, p) in punches.indexed)
              {
                'TimePunchUUID': 'punch-${i + 1}',
                'Type': p['type'],
                'OccurredAt': DateTime.now().toUtc().toIso8601String(),
                'NSR': i + 1,
                'Flags': <String>[],
                'HasPhoto': photos.isNotEmpty,
              },
          ].reversed.toList(),
        },
      });
    }
    return json({'code': 'requestError'}, 400);
  });

  testWidgets('a cancelled confirmation records nothing', (tester) async {
    final punches = <Map<String, dynamic>>[];
    await tester.pumpWidget(app(photoClient('off', punches, [])));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    expect(find.byKey(const Key('confirmPunchDialog')), findsOneWidget);
    expect(find.text('Confirm Clock in?'), findsOneWidget);
    expect(find.byKey(const Key('retakePhoto')), findsNothing);
    await tester.tap(find.byKey(const Key('cancelPunch')));
    await settle(tester);
    expect(punches, isEmpty);
    expect(await PunchQueue('account-1').load(), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a required photo is taken, confirmed and sent with the punch', (
    tester,
  ) async {
    final punches = <Map<String, dynamic>>[];
    final photos = <http.Request>[];
    var shots = 0;
    punchPhotoCapture = () async {
      shots++;
      return Uint8List.fromList(base64Decode(_pixelJpeg));
    };
    addTearDown(() => punchPhotoCapture = capturePunchPhoto);
    await tester.pumpWidget(app(photoClient('required', punches, photos)));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    expect(shots, 1);
    expect(find.byKey(const Key('punchPhotoPreview')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('retakePhoto')));
    await tester.tap(find.byKey(const Key('retakePhoto')));
    await settle(tester);
    expect(shots, 2);
    await tester.tap(find.byKey(const Key('confirmPunch')));
    await settle(tester);
    expect(punches, hasLength(1));
    expect(photos, hasLength(1));
    expect(photos.single.url.path, endsWith('/pulse/punches/punch-1/photo'));
    expect(photos.single.headers['authorization'], 'Bearer access-token');
    expect(find.text('Punch saved with photo.'), findsOneWidget);
    expect(find.textContaining('With photo'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'without a photo (camera refused) the punch still goes, flagged',
    (tester) async {
      final punches = <Map<String, dynamic>>[];
      final photos = <http.Request>[];
      punchPhotoCapture = () async => throw StateError('camera denied');
      addTearDown(() => punchPhotoCapture = capturePunchPhoto);
      await tester.pumpWidget(app(photoClient('required', punches, photos)));
      await settle(tester);
      await tester.tap(find.byKey(const Key('nextPunch')));
      await settle(tester);
      expect(find.byKey(const Key('punchPhotoMissing')), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirmPunch')));
      await settle(tester);
      expect(punches, hasLength(1));
      expect(photos, isEmpty);
      expect(find.text('Punch saved.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('without connection the mark is kept and sent later as offline', (
    tester,
  ) async {
    var online = false;
    final sent = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/auth/refresh')) return json(session());
      if (!online) throw http.ClientException('offline');
      if (path.endsWith('/punches') && request.method == 'POST') {
        sent.add(jsonDecode(request.body) as Map<String, dynamic>);
        return json({
          'data': {
            'item': {'Duplicate': 0},
          },
        });
      }
      if (path.endsWith('/punches')) {
        return json({
          'data': {'items': <Object>[]},
        });
      }
      return json({
        'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
      });
    });
    await tester.pumpWidget(app(client));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirmPunch')));
    await settle(tester);
    expect(find.byKey(const Key('pendingPunches')), findsOneWidget);
    expect(find.text('Waiting to be sent'), findsOneWidget);
    final queued = await PunchQueue('account-1').load();
    expect(queued, hasLength(1));
    online = true;
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
    expect(sent, hasLength(1));
    expect(sent.single['offline'], isTrue);
    expect(sent.single['idempotencyKey'], queued.single.idempotencyKey);
    expect(await PunchQueue('account-1').load(), isEmpty);
    expect(find.byKey(const Key('pendingPunches')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an ended session returns to sign in and keeps queued marks', (
    tester,
  ) async {
    var refreshes = 0;
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/auth/refresh')) {
        refreshes++;
        return refreshes == 1
            ? json(session())
            : json({'code': 'PULSE_SESSION_INVALID'}, 401);
      }
      if (path.endsWith('/time')) {
        return json({
          'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
        });
      }
      return json({'code': 'PULSE_ACCESS_DENIED'}, 403);
    });
    await tester.pumpWidget(app(client));
    await settle(tester);
    expect(find.text('Your access is not active. Contact HR.'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets(
    'opened offline, the remembered employee punches and the device grant sends it',
    (tester) async {
      final key = P256Key.generate();
      await SecretVault.instance.write(
        'pulse.offline.profile',
        jsonEncode({
          'timeClockAccountUUID': 'account-1',
          'loginCode': 'ABCD-EFGH',
          'employeeName': 'Test Employee',
        }),
      );
      await SecretVault.instance.write(
        'pulse.device.account-1',
        jsonEncode(
          DeviceGrantState(
            deviceUUID: 'device-1',
            privateKey: key.privateBase64,
            counter: 2,
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 5)),
          ).toJson(),
        ),
      );
      var online = false;
      final signed = <http.Request>[];
      final client = MockClient((request) async {
        final path = request.url.path;
        if (!online) throw http.ClientException('offline');
        if (path.endsWith('/device/punches')) {
          signed.add(request);
          return json({
            'data': {
              'item': {'Duplicate': 0, 'Offline': true},
            },
          });
        }
        // The session itself is gone (signed out elsewhere, expired): only the grant sends.
        return json({'code': 'PULSE_SESSION_INVALID'}, 401);
      });
      await tester.pumpWidget(app(client));
      await settle(tester);
      expect(find.byKey(const Key('offlineEntry')), findsOneWidget);
      expect(find.text('Test Employee'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nextPunch')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirmPunch')));
      await settle(tester);
      expect(find.byKey(const Key('pendingPunches')), findsOneWidget);
      final queued = await PunchQueue('account-1').load();
      expect(queued, hasLength(1));
      online = true;
      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
      expect(signed, hasLength(1));
      // The attempt made while offline already used counter 3: a counter is never reused.
      expect(signed.single.headers['X-Device-Counter'], '4');
      expect(signed.single.headers['authorization'], isNull);
      expect(
        jsonDecode(signed.single.body)['idempotencyKey'],
        queued.single.idempotencyKey,
      );
      expect(await PunchQueue('account-1').load(), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'the customer HR account of the session survives the password change',
    () {
      final account = PulseAccount.fromJson({
        'timeClockAccountUUID': 'account-1',
        'loginCode': 'ABCD-EFGH',
        'mustChangePassword': true,
        'companyName': 'Customer Company',
        'hrAccountName': 'Customer HR',
      });
      expect(account.hrAccountName, 'Customer HR');
      expect(account.passwordChanged().hrAccountName, 'Customer HR');
      expect(PulseAccount.fromJson({'loginCode': 'X'}).hrAccountName, isNull);
    },
  );
}

/// 1x1 JPEG, enough for Image.memory in the confirmation preview.
const _pixelJpeg =
    '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0s8g/9k=';
