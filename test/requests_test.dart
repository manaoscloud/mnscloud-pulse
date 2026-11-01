import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_en.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:mnscloud_pulse/src/requests/requests_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

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
      'loginCode': 'ABCD-EFGH',
      'mustChangePassword': false,
    },
  },
};

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('refusals become translated texts, never the server English', () {
    final l = AppLocalizationsEnUs();
    PulseFailure refused(String message, [List<String> fields = const []]) =>
        PulseFailure(
          'VALIDATION_FAILED',
          status: 400,
          message: message,
          fields: fields,
        );
    expect(
      requestFailureText(
        l,
        refused('A pending request for this mark already exists.'),
      ),
      l.requestDuplicate,
    );
    expect(
      requestFailureText(
        l,
        refused('The date is before the open timesheet period.'),
      ),
      l.requestPeriodClosed,
    );
    expect(
      requestFailureText(l, refused('The absence overlaps another absence.')),
      l.requestOverlap,
    );
    expect(
      requestFailureText(l, refused('Invalid file.', ['file'])),
      l.requestFileInvalid,
    );
    expect(
      requestFailureText(l, const PulseFailure('networkError')),
      l.networkError,
    );
    expect(requestFailureText(l, refused('Something new.')), l.requestError);
    expect(absenceTypeLabel(l, 'medical_certificate'), 'Medical certificate');
    expect(requestStatusLabel(l, 'rejected'), 'Rejected');
  });

  testWidgets(
    'the employee lists requests, sends a forgotten mark once and cancels a pending one',
    (tester) async {
      phone(tester);
      final sent = <Map<String, dynamic>>[];
      final cancelled = <String>[];
      var items = <Map<String, dynamic>>[
        {
          'RequestUUID': 'r1',
          'Type': 'absence',
          'Status': 'rejected',
          'Date': '2026-11-02',
          'EndDate': '2026-11-03',
          'AbsenceType': 'medical_certificate',
          'AttachmentFileName': 'atestado.pdf',
          'Reason': 'CONSULTA',
          'DecisionNote': 'Envie o atestado legível.',
        },
      ];
      final client = MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/auth/refresh')) return json(session);
        if (path.endsWith('/time')) {
          return json({
            'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
          });
        }
        if (path.endsWith('/requests') && request.method == 'GET') {
          return json({
            'data': {'items': items},
          });
        }
        if (path.endsWith('/requests') && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          sent.add(body);
          // First try fails on the network: the retry must reuse the same request UUID.
          if (sent.length == 1) throw http.ClientException('offline');
          items = [
            {
              'RequestUUID': body['uuid'],
              'Type': 'missing_punch',
              'Status': 'pending',
              'Date': body['date'],
              'PunchType': body['punchType'],
              'OccurredAt': DateTime.now().toUtc().toIso8601String(),
              'Reason': body['reason'],
            },
            ...items,
          ];
          return json({
            'data': {'RequestUUID': body['uuid'], 'Duplicate': false},
          });
        }
        if (path.contains('/requests/') && path.endsWith('/cancel')) {
          cancelled.add(path.split('/')[path.split('/').length - 2]);
          return json({
            'data': {'RequestUUID': 'x', 'Status': 'cancelled'},
          });
        }
        if (path.endsWith('/punches') || path.endsWith('/today')) {
          return json({
            'data': {
              'items': <Object>[],
              'date': '2026-11-02',
              'punches': <Object>[],
            },
          });
        }
        return json({'code': 'requestError'}, 404);
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en', 'US'),
          home: PulseShell(client: client),
        ),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('navRequests')));
      await settle(tester);
      expect(find.text('Absence'), findsWidgets);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Answer: Envie o atestado legível.'), findsOneWidget);
      expect(find.text('atestado.pdf'), findsOneWidget);

      await tester.tap(find.byKey(const Key('newRequest')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('sendRequest')));
      await settle(tester);
      expect(find.text('Write the reason.'), findsOneWidget);
      expect(sent, isEmpty);

      await tester.enterText(
        find.byKey(const Key('requestReason')),
        'Esqueci a saída',
      );
      await tester.tap(find.byKey(const Key('sendRequest')));
      await settle(tester);
      expect(find.text('Choose the time of the mark.'), findsOneWidget);
      await tester.tap(find.text('Time'));
      await settle(tester);
      await tester.tap(find.text('OK'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('sendRequest')));
      await settle(tester);
      expect(find.text('Unable to connect. Please try again.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sendRequest')));
      await settle(tester);
      expect(sent.length, 2);
      expect(sent[1]['uuid'], sent[0]['uuid']);
      expect(sent[1]['type'], 'missing_punch');
      expect(sent[1]['punchType'], 'clock_out');
      expect(
        RegExp(r'^\d\d:\d\d$').hasMatch(sent[1]['time'] as String),
        isTrue,
      );
      expect(find.text('Pending'), findsOneWidget);

      await tester.tap(find.text('Cancel request').first);
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel request'));
      await settle(tester);
      expect(cancelled, [sent[1]['uuid']]);
    },
  );
}
