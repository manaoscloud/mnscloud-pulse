import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_en.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_print.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_view.dart';

final l = AppLocalizationsEn();

Map<String, dynamic> fullBody() => {
  'month': '2026-10',
  'header': {
    'employer': {
      'Name': 'Posto <b>X</b> & Cia',
      'Document': '12.345.678/0001-90',
    },
    'employee': {
      'Name': 'Ana "A" <script>',
      'Document': '123.456.789-09',
      'HireDate': '2024-03-05',
      'PositionName': 'Attendant',
      'DepartmentName': null,
    },
    'schedules': [
      {
        'Name': 'Escala 6x1',
        'Kind': 'weekly',
        'Days': [
          {
            'Position': 1,
            'Start': '08:00',
            'BreakStart': '12:00',
            'BreakEnd': '13:00',
            'End': '17:00',
          },
        ],
      },
    ],
    'period': {'From': '2026-10-01', 'To': '2026-10-31'},
    'IssuedAt': '2026-11-12T15:00:00Z',
    'Timezone': 'America/Manaus',
  },
  'days': [
    {
      'Date': '2026-10-01',
      'DayKind': 'work',
      'WorkedMinutes': 480,
      'BalanceMinutes': -15,
      'Flags': ['late'],
      'punches': [
        {
          'Type': 'clock_in',
          'LocalTime': '08:00',
          'NSR': 10,
          'Disregarded': false,
        },
        {
          'Type': 'clock_out',
          'LocalTime': '17:30',
          'NSR': 11,
          'Disregarded': true,
        },
      ],
      'adjustments': [
        {
          'Kind': 'include',
          'PunchType': 'clock_out',
          'LocalTime': '17:00',
          'Reason': '<img onerror=x>',
        },
        {
          'Kind': 'disregard',
          'PunchType': 'clock_out',
          'LocalTime': '17:30',
          'Reason': 'Duplicated',
        },
      ],
    },
  ],
  'totals': {'WorkedMinutes': 480, 'BalanceMinutes': -15},
  'unassignedPunches': <Object>[],
};

class _FakeApi extends PulseApi {
  @override
  Future<Map<String, dynamic>> timesheet(String month) async => fullBody();
}

void main() {
  test('html escapes every API value', () {
    final html = timesheetHtml(fullBody(), l, language: 'en');
    expect(html, isNot(contains('<script>')));
    expect(html, isNot(contains('<img onerror')));
    expect(html, contains('Posto &lt;b&gt;X&lt;/b&gt; &amp; Cia'));
    expect(
      escapeHtml('<a href="x">\'</a>'),
      '&lt;a href=&quot;x&quot;&gt;&#39;&lt;/a&gt;',
    );
  });

  test('html carries the art. 84 content, NSR and I/D markers', () {
    final html = timesheetHtml(fullBody(), l, language: 'en');
    expect(html, contains('12.345.678/0001-90'));
    expect(html, contains('05/03/2024'));
    expect(html, contains('Escala 6x1'));
    expect(html, contains('Monday'));
    expect(html, contains('NSR 10'));
    expect(html, contains('<b>D</b>17:30 NSR 11'));
    expect(html, contains('<b>I</b>17:00'));
    expect(html, contains('Duplicated'));
    expect(html, contains('12/11/2026 15:00:00 UTC'));
    expect(html, contains('-00:15'));
  });

  test('parsing tolerates an API without the new fields', () {
    final old = <String, dynamic>{
      'days': [
        {
          'Date': '2026-10-02',
          'DayKind': 'off',
          'punches': [
            {'LocalTime': '08:00', 'NSR': 1},
          ],
        },
      ],
      'totals': <String, dynamic>{},
    };
    expect(TimesheetHeader.fromJson(old['header']).isEmpty, isTrue);
    expect(
      adjustmentsOf((old['days']! as List).first as Map<String, dynamic>),
      isEmpty,
    );
    final html = timesheetHtml(old, l);
    expect(html, contains('08:00 NSR 1'));
    expect(html, isNot(contains(l.tspLegend)));
    expect(TimesheetHeader.fromJson('garbage').isEmpty, isTrue);
    expect(timesheetHtml(<String, dynamic>{}, l), contains('</html>'));
  });

  test('all new texts exist in every language', () {
    for (final locale in ['en', 'es', 'pt']) {
      final t = lookupAppLocalizations(Locale(locale));
      expect(t.tspPrint, isNotEmpty);
      expect(t.tspWeekdays.split('|'), hasLength(7));
    }
  });

  testWidgets('the view shows header, markers and prints the same page', (
    tester,
  ) async {
    final api = _FakeApi();
    String? printed;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TimesheetView(
            api: api,
            clock: ServerClock(),
            onSessionEnded: (_) {},
            printAvailable: true,
            printer: (html) async => printed = html,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('timesheetHeader')), findsOneWidget);
    expect(find.textContaining('D 17:30'), findsWidgets);
    await tester.tap(find.byKey(const Key('printTimesheet')));
    await tester.pumpAndSettle();
    expect(printed, contains('NSR 10'));
  });

  testWidgets('no print button when printing is unavailable', (tester) async {
    final api = _FakeApi();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TimesheetView(
            api: api,
            clock: ServerClock(),
            onSessionEnded: (_) {},
            printAvailable: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('printTimesheet')), findsNothing);
  });
}
