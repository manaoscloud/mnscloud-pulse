import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/employment_choice.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:mnscloud_pulse/src/punch/punch_workspace.dart';
import 'package:mnscloud_pulse/src/receipt/receipt.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_print.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

Map<String, dynamic> employment(String id, String company, String location) => {
  'employmentUUID': id,
  'companyUUID': 'c-$id',
  'companyName': company,
  'locationUUID': 'l-$id',
  'locationName': location,
  'registrationNumber': 'R$id',
  'hireDate': '2024-01-02',
};

Map<String, dynamic> session(List<Map<String, dynamic>> employments) => {
  'data': {
    'accessToken': 'access-token',
    'refreshToken': null,
    'serverTime': DateTime.now().toUtc().toIso8601String(),
    'account': {
      'timeClockAccountUUID': 'account-1',
      'employeeName': 'Test Employee',
      'companyName': 'Example Company',
      'loginCode': 'ABCD-EFGH',
      'mustChangePassword': false,
      'employments': employments,
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('account parses employments and tolerates none', () {
    final account = PulseAccount.fromJson({
      'timeClockAccountUUID': 'a',
      'loginCode': 'X',
      'employments': [
        employment('1', 'Acme', 'HQ'),
        {'noUUID': true},
      ],
    });
    expect(account.employments, hasLength(1));
    expect(account.employments.single.label('Reg.'), 'Acme · HQ · Reg. R1');
    expect(
      PulseAccount.fromJson({'timeClockAccountUUID': 'a'}).employments,
      isEmpty,
    );
    expect(account.passwordChanged().employments, hasLength(1));
  });

  test('queued punch keeps its employment in the offline queue body', () {
    final punch = QueuedPunch(
      idempotencyKey: 'k',
      type: 'clock_in',
      occurredAt: DateTime.utc(2026, 11, 12, 10),
      employmentUUID: 'e-1',
    );
    final again = QueuedPunch.fromJson(punch.toJson());
    expect(again.employmentUUID, 'e-1');
    expect(punch.body(offline: true, source: 'web')['employmentUUID'], 'e-1');
    final legacy = QueuedPunch.fromJson({
      'idempotencyKey': 'k',
      'type': 'clock_in',
      'occurredAt': '2026-11-12T10:00:00Z',
    });
    expect(legacy.employmentUUID, isNull);
    expect(legacy.toJson().containsKey('employmentUUID'), isFalse);
  });

  test('choice resolves the remembered employment or the first', () {
    final list = [
      PulseEmployment.fromJson(employment('1', 'A', 'X')),
      PulseEmployment.fromJson(employment('2', 'B', 'Y')),
    ];
    expect(EmploymentChoice.resolve(list, '2'), '2');
    expect(EmploymentChoice.resolve(list, 'gone'), '1');
    expect(EmploymentChoice.resolve(const [], '2'), isNull);
  });

  test('kiosk employment message exists in every language', () {
    for (final locale in ['en', 'es', 'pt']) {
      final t = lookupAppLocalizations(Locale(locale));
      expect(t.kioskEmploymentRequired, isNotEmpty);
      expect(t.employmentWaiting(2), contains('2'));
    }
  });

  test('receipt carries the outside geofence flag', () {
    expect(
      PunchReceipt.fromJson({'OutsideGeofence': 1}).outsideGeofence,
      isTrue,
    );
    expect(PunchReceipt.fromJson({}).outsideGeofence, isFalse);
  });

  test('outside geofence is read from the field or the flag', () {
    expect(isOutsideGeofence({'OutsideGeofence': 1}), isTrue);
    expect(
      isOutsideGeofence({
        'Flags': ['outside_geofence'],
      }),
      isTrue,
    );
    expect(isOutsideGeofence({'OutsideGeofence': 0, 'Flags': []}), isFalse);
  });

  test('timesheet header reads registration, location and termination', () {
    final header = TimesheetHeader.fromJson({
      'employee': {
        'Name': 'N',
        'RegistrationNumber': '123',
        'LocationName': 'HQ',
        'TerminationDate': '2026-10-31',
      },
    });
    expect(header.registrationNumber, '123');
    expect(header.locationName, 'HQ');
    expect(header.terminationDate, '2026-10-31');
  });

  /// API double: [refuse] is the code POST /punches answers with while not empty; /auth/me
  /// answers [meEmployments] (null: unreachable).
  MockClient employmentClient({
    required List<Map<String, dynamic>> employments,
    required List<Map<String, dynamic>> bodies,
    required String Function() refuse,
    List<Map<String, dynamic>>? Function()? meEmployments,
    List<Map<String, dynamic>> listed = const [],
  }) => MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/auth/refresh')) return json(session(employments));
    if (path.endsWith('/auth/me')) {
      final fresh = meEmployments?.call();
      if (fresh == null) return json({'code': 'requestError'}, 500);
      return json({
        'data': {'item': session(fresh)['data']['account']},
      });
    }
    if (path.endsWith('/time')) {
      return json({
        'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
      });
    }
    if (path.endsWith('/punches') && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      bodies.add(body);
      if (refuse().isNotEmpty) {
        return json({
          'code': refuse(),
          'fields': ['employmentUUID'],
        }, 409);
      }
      return json({
        'data': {
          'item': {'Type': body['type'], 'NSR': 1, 'Duplicate': 0},
        },
      });
    }
    if (path.endsWith('/punches')) {
      return json({
        'data': {'items': listed},
      });
    }
    return json({'code': 'requestError'}, 400);
  });

  final two = [
    employment('1', 'Acme', 'HQ'),
    employment('2', 'Beta', 'Branch'),
  ];

  Future<void> punchOnce(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirmPunch')));
    await settle(tester);
  }

  testWidgets(
    'several employments: choice is sent, remembered and shows the marker',
    (tester) async {
      final bodies = <Map<String, dynamic>>[];
      await tester.pumpWidget(
        app(
          employmentClient(
            employments: two,
            bodies: bodies,
            refuse: () => '',
            listed: [
              {
                'Type': 'clock_in',
                'OccurredAt': DateTime.now().toUtc().toIso8601String(),
                'NSR': 7,
                'Flags': ['outside_geofence'],
                'OutsideGeofence': 1,
              },
            ],
          ),
        ),
      );
      await settle(tester);
      expect(find.byKey(const Key('punchEmployment')), findsOneWidget);
      expect(find.text('Outside the geofence'), findsWidgets);
      await tester.tap(find.byKey(const Key('punchEmployment')));
      await settle(tester);
      await tester.tap(find.textContaining('Beta').last);
      await settle(tester);
      await punchOnce(tester);
      expect(bodies.single['employmentUUID'], '2');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pulse.employment.account-1'), '2');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'EMPLOYMENT_REQUIRED keeps the mark, shows the banner and assigns later',
    (tester) async {
      final bodies = <Map<String, dynamic>>[];
      var refuse = 'PULSE_EMPLOYMENT_REQUIRED';
      await tester.pumpWidget(
        app(
          employmentClient(
            employments: two,
            bodies: bodies,
            refuse: () => refuse,
            meEmployments: () => two,
          ),
        ),
      );
      await settle(tester);
      await punchOnce(tester);
      expect(find.textContaining('more than one employment'), findsOneWidget);
      final queued = await PunchQueue('account-1').load();
      expect(queued, hasLength(1));
      expect(queued.single.needsEmployment, isTrue);
      expect(find.byKey(const Key('employmentBanner')), findsOneWidget);

      // Waiting marks are not resent by the periodic pass.
      final sent = bodies.length;
      await tester.pump(const Duration(seconds: 31));
      await settle(tester);
      expect(bodies.length, sent);

      refuse = '';
      await tester.ensureVisible(find.byKey(const Key('assignEmploymentSend')));
      await tester.tap(find.byKey(const Key('assignEmploymentSend')));
      await settle(tester);
      expect(bodies.last['employmentUUID'], '1');
      expect(await PunchQueue('account-1').load(), isEmpty);
      expect(find.byKey(const Key('employmentBanner')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'EMPLOYMENT_INVALID with one employment left retries without it',
    (tester) async {
      final bodies = <Map<String, dynamic>>[];
      await tester.pumpWidget(
        app(
          employmentClient(
            employments: two,
            bodies: bodies,
            refuse: () => bodies.length == 1 ? 'PULSE_EMPLOYMENT_INVALID' : '',
            meEmployments: () => [employment('1', 'Acme', 'HQ')],
          ),
        ),
      );
      await settle(tester);
      await punchOnce(tester);
      expect(bodies, hasLength(2));
      expect(bodies.first['employmentUUID'], '1');
      expect(bodies.last.containsKey('employmentUUID'), isFalse);
      expect(await PunchQueue('account-1').load(), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a queued mark waiting for an employment is never resent', (
    tester,
  ) async {
    await PunchQueue('account-1').add(
      QueuedPunch(
        idempotencyKey: 'waiting-1',
        type: 'clock_in',
        occurredAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        needsEmployment: true,
      ),
    );
    final bodies = <Map<String, dynamic>>[];
    await tester.pumpWidget(
      app(employmentClient(employments: two, bodies: bodies, refuse: () => '')),
    );
    await settle(tester);
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
    expect(bodies, isEmpty);
    expect(find.byKey(const Key('employmentBanner')), findsOneWidget);
    final kept = (await PunchQueue('account-1').load()).single;
    expect(kept.needsEmployment, isTrue);
    expect(
      kept.body(offline: true, source: 'web').containsKey('needsEmployment'),
      isFalse,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the offline profile keeps the employments', (tester) async {
    final bodies = <Map<String, dynamic>>[];
    await tester.pumpWidget(
      app(employmentClient(employments: two, bodies: bodies, refuse: () => '')),
    );
    await settle(tester);
    final raw = await SecretVault.instance.read('pulse.offline.profile');
    final stored = PulseAccount.fromJson(
      jsonDecode(raw!) as Map<String, dynamic>,
    );
    expect(stored.employments.map((e) => e.employmentUUID), ['1', '2']);
    expect(stored.employments.first.registrationNumber, 'R1');
    await tester.pumpWidget(const SizedBox());

    // A cold start without connection restores the selector from the profile.
    await tester.pumpWidget(
      app(MockClient((_) async => throw http.ClientException('offline'))),
    );
    await settle(tester);
    expect(find.byKey(const Key('offlineEntry')), findsOneWidget);
    expect(find.byKey(const Key('punchEmployment')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one employment is shown read-only and sends no employmentUUID', (
    tester,
  ) async {
    final bodies = <Map<String, dynamic>>[];
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/auth/refresh')) {
        return json(session([employment('1', 'Acme', 'HQ')]));
      }
      if (path.endsWith('/time')) {
        return json({
          'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
        });
      }
      if (path.endsWith('/punches') && request.method == 'POST') {
        bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return json({
          'data': {
            'item': {'NSR': 1, 'Duplicate': 0},
          },
        });
      }
      if (path.endsWith('/punches')) {
        return json({
          'data': {'items': []},
        });
      }
      return json({'code': 'requestError'}, 400);
    });
    await tester.pumpWidget(app(client));
    await settle(tester);
    expect(find.byKey(const Key('punchEmployment')), findsNothing);
    expect(find.textContaining('Acme · HQ · Reg. R1'), findsOneWidget);
    expect(find.textContaining('Example Company'), findsNothing);
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirmPunch')));
    await settle(tester);
    expect(bodies.single.containsKey('employmentUUID'), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('timesheet selector passes the employment to the API', (
    tester,
  ) async {
    final queries = <String>[];
    final client = MockClient((request) async {
      queries.add(request.url.query);
      return json({
        'data': {
          'header': {
            'employer': {'Name': 'Acme'},
            'employee': {
              'Name': 'Emp',
              'RegistrationNumber': '555',
              'LocationName': 'HQ',
            },
          },
          'days': <Object>[],
          'totals': <String, dynamic>{},
          'unassignedPunches': <Object>[],
        },
      });
    });
    final api = PulseApi(client: client);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: TimesheetView(
            api: api,
            clock: ServerClock(),
            onSessionEnded: (_) {},
            employments: [
              PulseEmployment.fromJson(employment('1', 'Acme', 'HQ')),
              PulseEmployment.fromJson(employment('2', 'Beta', 'Branch')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(queries.last, contains('employmentUUID=1'));
    expect(find.textContaining('Registration no.: 555'), findsOneWidget);
    await tester.tap(find.byKey(const Key('timesheetEmployment')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Beta').last);
    await tester.pumpAndSettle();
    expect(queries.last, contains('employmentUUID=2'));
  });
}
