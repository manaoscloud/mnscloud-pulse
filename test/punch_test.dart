import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/ids.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (call) async => call.method == 'isLocationServiceEnabled' ? false : null,
    );
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  testWidgets('a reload reopens the session and the next mark is one tap', (
    tester,
  ) async {
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
  });

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
}
