import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_en.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_labels.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

final session = {
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
    },
  },
};

Map<String, dynamic> punch(String type, String local) => {
  'TimePunchUUID': '$type-$local',
  'Type': type,
  'OccurredAt': DateTime.now().toUtc().toIso8601String(),
  'LocalTime': local,
  'NSR': 1,
  'Flags': <String>[],
  'Offline': false,
};

/// Pulse API double: session, time and punches answer as F0; `today` and `timesheet` answer the
/// given handlers (null = the endpoint does not exist on this API).
MockClient pulse({
  http.Response Function()? today,
  http.Response Function(String month)? timesheet,
}) => MockClient((request) async {
  final path = request.url.path;
  if (path.endsWith('/auth/refresh')) return json(session);
  if (path.endsWith('/time')) {
    return json({
      'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
    });
  }
  if (path.endsWith('/punches')) {
    return json({
      'data': {'items': <Object>[]},
    });
  }
  if (path.endsWith('/today') && today != null) return today();
  if (path.endsWith('/timesheet') && timesheet != null) {
    return timesheet(request.url.queryParameters['month'] ?? '');
  }
  return json({'code': 'requestError'}, 404);
});

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

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data ?? '';

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('minutes are HH:MM and balances carry their sign', () {
    expect(formatMinutes(0), '00:00');
    expect(formatMinutes(75), '01:15');
    expect(formatMinutes(9600), '160:00');
    expect(formatMinutes(-45), '-00:45');
    expect(formatMinutes(90, signed: true), '+01:30');
    expect(formatMinutes(-90, signed: true), '-01:30');
    expect(formatMinutes(0, signed: true), '00:00');
    expect(minutesOf('12'), 12);
    expect(minutesOf(null), 0);
    expect(minutesOf(7.0), 7);
  });

  test('flags and day kinds have short employee labels', () {
    final l = AppLocalizationsEnUs();
    expect(
      [
        'absence',
        'missing_punch',
        'late',
        'early_leave',
        'short_break',
        'rest_violation',
        'overtime_limit',
        'worked_day_off',
        'flagged_punch',
        'no_schedule',
      ].map((flag) => flagLabel(l, flag)),
      [
        'Absence',
        'Missing punch',
        'Late',
        'Left early',
        'Short break',
        'Rest between shifts',
        'Overtime above limit',
        'Worked on a day off',
        'Flagged punch',
        'No schedule',
      ],
    );
    expect(flagLabel(l, 'internal_rule'), isNull);
    expect(
      dayKindLabel(l, {
        'DayKind': 'work',
        'ExpectedStartLocal': '08:00',
        'ExpectedEndLocal': '17:00',
      }),
      '08:00–17:00',
    );
    expect(dayKindLabel(l, {'DayKind': 'work'}), 'Workday');
    expect(dayKindLabel(l, {'DayKind': 'off'}), 'Day off');
    expect(
      dayKindLabel(l, {'DayKind': 'holiday', 'HolidayName': 'Founders Day'}),
      'Holiday: Founders Day',
    );
    expect(dayKindLabel(l, null), 'No schedule set');
    expect(monthKey(DateTime(2026, 3)), '2026-03');
  });

  testWidgets('today card shows the shift and ticks the worked time live', (
    tester,
  ) async {
    phone(tester);
    var online = true;
    final client = pulse(
      today: () {
        if (!online) throw http.ClientException('offline');
        return json({
          'data': {
            'date': '2026-10-24',
            'timezone': 'America/Sao_Paulo',
            'day': {'DayKind': 'work', 'Flags': <String>[]},
            'punches': [punch('clock_in', '08:00')],
            'working': true,
            'workedMinutes': 125,
            'expected': {
              'startLocal': '08:00',
              'endLocal': '17:00',
              'minutes': 480,
            },
          },
        });
      },
    );
    await tester.pumpWidget(app(client));
    await settle(tester);
    expect(find.byKey(const Key('todayCard')), findsOneWidget);
    expect(textOf(tester, 'todayShift'), '08:00–17:00');
    expect(textOf(tester, 'todayStatus'), 'Working');
    expect(textOf(tester, 'todayWorked'), '02:05');
    // Without connection the last answer keeps ticking every minute.
    online = false;
    await tester.pump(const Duration(seconds: 61));
    await settle(tester);
    expect(textOf(tester, 'todayWorked'), '02:06');
    expect(find.byKey(const Key('nextPunch')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('today card shows days off, holidays and breaks', (tester) async {
    phone(tester);
    var answer = <String, dynamic>{
      'date': '2026-10-24',
      'timezone': 'America/Sao_Paulo',
      'day': {'DayKind': 'off', 'Flags': <String>[]},
      'punches': <Object>[],
      'working': false,
      'workedMinutes': 0,
      'expected': null,
    };
    final client = pulse(today: () => json({'data': answer}));
    await tester.pumpWidget(app(client));
    await settle(tester);
    expect(textOf(tester, 'todayShift'), 'Day off');
    expect(textOf(tester, 'todayStatus'), 'Off duty');
    expect(textOf(tester, 'todayWorked'), '00:00');
    answer = {
      ...answer,
      'day': {
        'DayKind': 'holiday',
        'HolidayName': 'Founders Day',
        'Flags': <String>[],
      },
      'punches': [punch('clock_in', '09:00'), punch('break_start', '12:00')],
      'workedMinutes': 180,
    };
    await tester.pump(const Duration(seconds: 61));
    await settle(tester);
    expect(textOf(tester, 'todayShift'), 'Holiday: Founders Day');
    expect(textOf(tester, 'todayStatus'), 'On break');
    expect(textOf(tester, 'todayWorked'), '03:00');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an API without today hides the card and punching still works', (
    tester,
  ) async {
    phone(tester);
    await tester.pumpWidget(app(pulse()));
    await settle(tester);
    expect(find.byKey(const Key('todayCard')), findsNothing);
    expect(find.byKey(const Key('nextPunch')), findsOneWidget);
    expect(find.text('Clock in'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('timesheet tab shows totals and days and moves between months', (
    tester,
  ) async {
    phone(tester);
    final now = DateTime.now();
    final current = monthKey(DateTime(now.year, now.month));
    final previous = monthKey(DateTime(now.year, now.month - 1));
    final months = <String>[];
    final client = pulse(
      timesheet: (month) {
        months.add(month);
        if (month != current) {
          return json({
            'data': {
              'month': month,
              'days': <Object>[],
              'unassignedPunches': <Object>[],
              'totals': <String, int>{},
            },
          });
        }
        return json({
          'data': {
            'month': month,
            'timezone': 'America/Sao_Paulo',
            'days': [
              {
                'Date': '2026-10-01',
                'DayKind': 'work',
                'ExpectedStartLocal': '08:00',
                'ExpectedEndLocal': '17:00',
                'WorkedMinutes': 490,
                'BalanceMinutes': 10,
                'Flags': ['late'],
                'punches': [
                  punch('clock_in', '08:00'),
                  punch('break_start', '12:00'),
                  punch('break_end', '13:00'),
                  punch('clock_out', '17:10'),
                ],
              },
              {
                'Date': '2026-10-02',
                'DayKind': 'work',
                'ExpectedStartLocal': '08:00',
                'ExpectedEndLocal': '17:00',
                'WorkedMinutes': 0,
                'BalanceMinutes': -480,
                'Flags': ['absence', 'internal_rule'],
                'punches': <Object>[],
              },
            ],
            'unassignedPunches': [punch('clock_in', '07:58')],
            'totals': {
              'ExpectedMinutes': 960,
              'WorkedMinutes': 490,
              'BalanceMinutes': -470,
              'OvertimeMinutes': 30,
              'OvertimeRestMinutes': 10,
              'AbsenceDays': 1,
            },
          },
        });
      },
    );
    await tester.pumpWidget(app(client));
    await settle(tester);
    expect(months, isEmpty);
    await tester.tap(find.byKey(const Key('navTimesheet')));
    await settle(tester);
    expect(months, [current]);
    expect(textOf(tester, 'totalWorked'), '08:10');
    expect(textOf(tester, 'totalExpected'), '16:00');
    expect(textOf(tester, 'totalBalance'), '-07:50');
    expect(textOf(tester, 'totalOvertime'), '00:40');
    expect(textOf(tester, 'totalAbsences'), '1');
    expect(
      textOf(tester, 'unassignedPunches'),
      '1 punch still being processed',
    );
    expect(find.text('08:00  ·  12:00  ·  13:00  ·  17:10'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    expect(find.text('Absence'), findsOneWidget);
    expect(find.text('No punches'), findsOneWidget);
    expect(find.text('+00:10'), findsOneWidget);
    expect(find.text('-08:00'), findsOneWidget);
    // Newest first.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('day-2026-10-02'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('day-2026-10-01'))).dy,
      ),
    );
    IconButton next() =>
        tester.widget<IconButton>(find.byKey(const Key('nextMonth')));
    expect(next().onPressed, isNull);
    await tester.tap(find.byKey(const Key('previousMonth')));
    await settle(tester);
    expect(months.last, previous);
    expect(find.byKey(const Key('timesheetEmpty')), findsOneWidget);
    expect(next().onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('nextMonth')));
    await settle(tester);
    expect(months.last, current);
    expect(next().onPressed, isNull);
    // Back home the punch stays one tap away.
    await tester.tap(find.byKey(const Key('navHome')));
    await settle(tester);
    expect(find.byKey(const Key('nextPunch')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
