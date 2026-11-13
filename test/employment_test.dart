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

  testWidgets(
    'several employments: choice is sent, remembered and errors guide',
    (tester) async {
      final bodies = <Map<String, dynamic>>[];
      var refuse = 'PULSE_EMPLOYMENT_REQUIRED';
      final client = MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/auth/refresh')) {
          return json(
            session([
              employment('1', 'Acme', 'HQ'),
              employment('2', 'Beta', 'Branch'),
            ]),
          );
        }
        if (path.endsWith('/time')) {
          return json({
            'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
          });
        }
        if (path.endsWith('/punches') && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          bodies.add(body);
          if (refuse.isNotEmpty) {
            return json({
              'code': refuse,
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
            'data': {
              'items': [
                {
                  'Type': 'clock_in',
                  'OccurredAt': DateTime.now().toUtc().toIso8601String(),
                  'NSR': 7,
                  'Flags': ['outside_geofence'],
                  'OutsideGeofence': 1,
                },
              ],
            },
          });
        }
        return json({'code': 'requestError'}, 400);
      });
      await tester.pumpWidget(app(client));
      await settle(tester);
      expect(find.byKey(const Key('punchEmployment')), findsOneWidget);
      expect(find.text('Outside the geofence'), findsWidgets);

      await tester.tap(find.byKey(const Key('nextPunch')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirmPunch')));
      await settle(tester);
      expect(bodies.single['employmentUUID'], '1');
      expect(find.textContaining('Choose the employment'), findsOneWidget);
      expect(await PunchQueue('account-1').load(), isEmpty);

      await tester.tap(find.byKey(const Key('punchEmployment')));
      await settle(tester);
      await tester.tap(find.textContaining('Beta').last);
      await settle(tester);
      refuse = 'PULSE_EMPLOYMENT_INVALID';
      await tester.tap(find.byKey(const Key('nextPunch')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirmPunch')));
      await settle(tester);
      expect(bodies.last['employmentUUID'], '2');
      expect(find.textContaining('not valid for you'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pulse.employment.account-1'), '2');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('one employment is shown read-only and still sent', (
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
    expect(bodies.single['employmentUUID'], '1');
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
