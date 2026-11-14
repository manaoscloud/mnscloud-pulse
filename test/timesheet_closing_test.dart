import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/timesheet/closing_cards.dart';
import 'package:mnscloud_pulse/src/timesheet/closing_models.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_labels.dart';
import 'package:mnscloud_pulse/src/timesheet/timesheet_view.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

String get thisMonth => monthKey(DateTime.now().toUtc().toLocal());

Map<String, dynamic> closingJson({bool acked = false, String mode = 'bank'}) =>
    {
      'ClosingUUID': 'c1',
      'MonthKey': thisMonth,
      'ClosedAt': '2026-11-02T12:00:00.000Z',
      'WorkedMinutes': 9600,
      'OvertimeMinutes': 120,
      'OvertimeRestMinutes': 60,
      'AbsenceDays': 1,
      'DsrLostDays': 1,
      'OvertimeMode': mode,
      'BankCreditMinutes': 120,
      'BankDebitMinutes': 30,
      'BankPaidMinutes': 0,
      'BankBalanceMinutes': 90,
      'Acknowledged': acked,
      'AcknowledgedAt': acked ? '2026-11-03T15:30:00.000Z' : null,
    };

class Fake {
  Fake({this.mode = 'bank', this.emptyBank = false});
  final String mode;
  final bool emptyBank;
  bool acked = false;
  int acks = 0;
  bool offline = false;

  http.Client get client => MockClient((request) async {
    final path = request.url.path;
    if (offline) throw http.ClientException('offline');
    if (path.endsWith('/pulse/timesheet')) {
      return json({
        'data': {
          'days': <Object>[],
          'totals': {'WorkedMinutes': 0},
        },
      });
    }
    if (path.endsWith('/timesheet-closings') && request.method == 'GET') {
      return json({
        'data': {
          'items': [closingJson(acked: acked, mode: mode)],
          'total': 1,
        },
      });
    }
    if (path.endsWith('/acknowledge')) {
      acks++;
      acked = true;
      return json({
        'data': {'ClosingUUID': 'c1', 'Duplicate': false},
      });
    }
    if (path.endsWith('/pulse/hour-bank')) {
      return json({
        'data': {
          'OvertimeMode': mode,
          'BalanceMinutes': emptyBank ? 0 : 90,
          'NextExpiresOn': '2027-04-30',
          'Entries': emptyBank
              ? []
              : [
                  {'MonthKey': thisMonth, 'Kind': 'credit', 'Minutes': 120},
                  {'MonthKey': thisMonth, 'Kind': 'expire_paid', 'Minutes': 30},
                ],
        },
      });
    }
    return json({'code': 'requestError'}, 404);
  });
}

Widget host(Fake fake, {List<int>? changes}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en', 'US'),
  home: Scaffold(
    body: TimesheetView(
      api: PulseApi(client: fake.client, baseUrl: 'https://pulse.test/api/v1'),
      clock: ServerClock(),
      onSessionEnded: (_) {},
      onClosingsChanged: () => changes?.add(1),
    ),
  ),
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  test('closing and hour bank payloads parse', () {
    final closings = TimesheetClosing.parseAll([
      closingJson(),
      {'MonthKey': '2026-09'},
    ]);
    expect(closings, hasLength(1));
    expect(closings.single.isBank, isTrue);
    expect(closings.single.acknowledged, isFalse);
    expect(closings.single.minutes('BankBalanceMinutes'), 90);
    expect(pendingClosings(closings), hasLength(1));
    expect(closingOfMonth(closings, thisMonth), isNotNull);
    expect(closingOfMonth(closings, '1999-01'), isNull);
    expect(monthText('2026-10'), '10/2026');
    expect(dateTimeText('nope'), '—');
    final bank = HourBank({
      'OvertimeMode': 'payment',
      'Entries': [
        {'Kind': 'credit'},
      ],
    });
    expect(bank.enabled, isTrue);
    expect(bank.entries, hasLength(1));
    expect(
      HourBank({'OvertimeMode': 'payment', 'BalanceMinutes': 30}).enabled,
      isTrue,
    );
    expect(
      HourBank({'OvertimeMode': 'payment', 'BalanceMinutes': 0, 'Entries': []})
          .enabled,
      isFalse,
    );
    expect(HourBank({'OvertimeMode': 'bank'}).enabled, isTrue);
  });

  test('api calls hit the closing endpoints', () async {
    final seen = <String>[];
    final api = PulseApi(
      client: MockClient((request) async {
        seen.add('${request.method} ${request.url.path}?${request.url.query}');
        return json({
          'data': {
            'items': [closingJson()],
            'ClosingUUID': 'c1',
            'OvertimeMode': 'bank',
          },
        });
      }),
      baseUrl: 'https://pulse.test/api/v1',
    );
    expect(await api.listTimesheetClosings(limit: 5), hasLength(1));
    expect((await api.acknowledgeTimesheetClosing('c1'))['ClosingUUID'], 'c1');
    expect((await api.hourBank())['OvertimeMode'], 'bank');
    expect(seen, [
      'GET /api/v1/pulse/timesheet-closings?limit=5&offset=0',
      'POST /api/v1/pulse/timesheet-closings/c1/acknowledge?',
      'GET /api/v1/pulse/hour-bank?',
    ]);
  });

  testWidgets('closed month asks for confirmation, then shows the ciencia', (
    tester,
  ) async {
    phone(tester);
    final fake = Fake();
    final changes = <int>[];
    await tester.pumpWidget(host(fake, changes: changes));
    await settle(tester);
    expect(find.byKey(const Key('closingCard')), findsOneWidget);
    expect(find.byKey(const Key('closingAwaiting')), findsOneWidget);
    expect(find.byKey(const Key('closingBankBalance')), findsOneWidget);
    await tester.tap(find.byKey(const Key('closingAckButton')));
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('closingAckConfirmBody'))).data,
      contains(monthText(thisMonth)),
    );
    expect(fake.acks, 0);
    await tester.tap(find.byKey(const Key('closingAckConfirm')));
    await settle(tester);
    expect(fake.acks, 1);
    expect(changes, hasLength(1));
    expect(find.byKey(const Key('closingAckButton')), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('closingAcked'))).data,
      startsWith('Acknowledged on '),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('offline acknowledgement is refused and never queued', (
    tester,
  ) async {
    phone(tester);
    final fake = Fake();
    await tester.pumpWidget(host(fake));
    await settle(tester);
    fake.offline = true;
    await tester.tap(find.byKey(const Key('closingAckButton')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('closingAckConfirm')));
    await settle(tester);
    expect(fake.acks, 0);
    expect(find.text('Unable to connect. Please try again.'), findsOneWidget);
    expect(find.byKey(const Key('closingAckButton')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'hour bank shows in bank mode or while a payment-mode bank has balance',
    (tester) async {
      phone(tester);
      await tester.pumpWidget(host(Fake()));
      await settle(tester);
      expect(find.byKey(const Key('hourBankCard')), findsOneWidget);
      expect(textOf(tester, 'hourBankBalance'), 'Balance: +01:30');
      expect(find.textContaining('Paid (expired)'), findsOneWidget);
      expect(textOf(tester, 'hourBankExpires'), 'Expires on 30/04/2027');
      await tester.pumpWidget(const SizedBox());

      await tester.pumpWidget(host(Fake(mode: 'payment')));
      await settle(tester);
      expect(find.byKey(const Key('hourBankCard')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await tester.pumpWidget(host(Fake(mode: 'payment', emptyBank: true)));
      await settle(tester);
      expect(find.byKey(const Key('closingCard')), findsOneWidget);
      expect(find.byKey(const Key('hourBankCard')), findsNothing);
      expect(find.byKey(const Key('closingBankBalance')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('main screen notice lists pending months and opens one', (
    tester,
  ) async {
    phone(tester);
    final fake = Fake();
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: ClosingNoticeHost(
            api: PulseApi(
              client: fake.client,
              baseUrl: 'https://pulse.test/api/v1',
            ),
            refresh: ValueNotifier<int>(0),
            onOpen: (m) => opened = m,
            onSessionEnded: (_) {},
          ),
        ),
      ),
    );
    await settle(tester);
    expect(
      find.text('1 closed month waiting for your acknowledgement'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('closingNotice')));
    expect(opened, thisMonth);
    await tester.pumpWidget(const SizedBox());
  });
}

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data ?? '';
