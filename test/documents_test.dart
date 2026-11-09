import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/l10n/app_localizations_en.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/documents/documents_view.dart';
import 'package:mnscloud_pulse/src/requests/requests_view.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// A fake Pulse API with one payslip, one warning, one notice and a vacation balance.
class FakePulse {
  final acknowledged = <String>[];
  final opened = <String>[];
  final sent = <Map<String, String>>[];
  final marks = <Map<String, dynamic>>[];
  final requests = <Map<String, dynamic>>[];
  var viewed = false;
  var vacationRequestable = 20;

  late final documents = <Map<String, dynamic>>[
    {
      'DocumentUUID': 'p1',
      'Kind': 'payslip',
      'Title': 'Holerite outubro',
      'Competence': '2026-10',
      'RequiresAck': true,
      'HasFile': true,
      'FileName': 'holerite.pdf',
      'State': 'pending',
      'ViewedAt': null,
      'AcknowledgedAt': null,
      'DateCreated': '2026-11-05T12:00:00.000Z',
    },
    {
      'DocumentUUID': 'w1',
      'Kind': 'warning',
      'Title': 'Advertência por atraso',
      'Description': 'Atrasos recorrentes sem justificativa.',
      'RequiresAck': true,
      'HasFile': false,
      'State': 'pending',
      'ViewedAt': null,
      'AcknowledgedAt': null,
      'DateCreated': '2026-11-04T12:00:00.000Z',
    },
  ];
  final notices = <Map<String, dynamic>>[
    {
      'NoticeUUID': 'n1',
      'Title': 'Recesso de fim de ano',
      'Body': 'O expediente termina às 14h no dia 24.',
      'RequiresAck': true,
      'PublishAt': '2026-11-01T12:00:00.000Z',
      'ReadAt': null,
      'AcknowledgedAt': null,
    },
  ];

  http.Client get client => MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/pulse/documents') && request.method == 'GET') {
      return json({
        'data': {'items': documents, 'total': documents.length},
      });
    }
    if (path.endsWith('/pulse/documents') && request.method == 'POST') {
      final body = request.headers['content-type'] ?? '';
      sent.add({'type': body});
      documents.add({
        'DocumentUUID': 'e1',
        'Kind': 'employee',
        'Title': 'Comprovante',
        'RequiresAck': false,
        'HasFile': true,
        'State': 'received',
        'DateCreated': '2026-11-09T12:00:00.000Z',
      });
      return json({
        'data': {'DocumentUUID': 'e1', 'Duplicate': false},
      });
    }
    if (path.endsWith('/file')) {
      opened.add(path.split('/')[path.split('/').length - 2]);
      viewed = true;
      documents.first['ViewedAt'] = '2026-11-09T12:00:00.000Z';
      documents.first['State'] = 'pending';
      return http.Response.bytes(
        utf8.encode('%PDF-1.7'),
        200,
        headers: {'content-type': 'application/pdf'},
      );
    }
    if (path.endsWith('/acknowledge')) {
      final uuid = path.split('/')[path.split('/').length - 2];
      acknowledged.add(uuid);
      final doc = documents.firstWhere((d) => d['DocumentUUID'] == uuid);
      doc['State'] = 'acknowledged';
      doc['AcknowledgedAt'] = '2026-11-09T12:00:00.000Z';
      return json({
        'data': {
          'DocumentUUID': uuid,
          'AcknowledgedAt': '2026-11-09T12:00:00.000Z',
        },
      });
    }
    if (path.endsWith('/pulse/notices')) {
      return json({
        'data': {'items': notices},
      });
    }
    if (path.contains('/pulse/notices/') && path.endsWith('/read')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      marks.add(body);
      return json({
        'data': {
          'NoticeUUID': 'n1',
          'ReadAt': '2026-11-09T12:00:00.000Z',
          'AcknowledgedAt': body['acknowledge'] == true
              ? '2026-11-09T12:01:00.000Z'
              : null,
        },
      });
    }
    if (path.endsWith('/pulse/vacation')) {
      return json({
        'data': {
          'hireDate': '2024-03-01',
          'availableDays': 30,
          'pendingDays': 10,
          'accruingDays': 17,
          'requestableDays': vacationRequestable,
          'periods': [
            {
              'start': '2024-03-01',
              'end': '2025-02-28',
              'deadline': '2026-02-28',
              'entitledDays': 30,
              'takenDays': 30,
              'remainingDays': 0,
              'status': 'used',
            },
            {
              'start': '2025-03-01',
              'end': '2026-02-28',
              'deadline': '2027-02-28',
              'entitledDays': 30,
              'takenDays': 0,
              'remainingDays': 30,
              'status': 'available',
            },
          ],
        },
      });
    }
    if (path.endsWith('/pulse/requests') && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      requests.add(body);
      return json({
        'data': {'RequestUUID': body['uuid'], 'Duplicate': false},
      });
    }
    return json({'code': 'requestError'}, 404);
  });
}

Widget app(FakePulse fake, {List<String>? openedFiles, DateTimeRange? range}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en', 'US'),
      home: Scaffold(
        body: DocumentsView(
          api: PulseApi(client: fake.client, baseUrl: 'https://pulse.test/api/v1'),
          onSessionEnded: (_) {},
          pickFile: () async => (utf8.encode('%PDF-1.7 comprovante'), 'c.pdf'),
          openFile: (bytes, type, name) async {
            openedFiles?.add('$name:$type');
            return true;
          },
          pickRange: (context, from) async => range,
        ),
      ),
    );

void main() {
  test('vacation is an absence label', () {
    expect(absenceTypeLabel(AppLocalizationsEnUs(), 'vacation'), 'Vacation');
  });

  testWidgets(
    'a payslip is opened before the acknowledgement; a warning is acknowledged with its text',
    (tester) async {
      phone(tester);
      final fake = FakePulse();
      final files = <String>[];
      await tester.pumpWidget(app(fake, openedFiles: files));
      await settle(tester);
      expect(find.text('Advertência por atraso'), findsOneWidget);
      expect(
        find.text('Atrasos recorrentes sem justificativa.'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('doc-ack-w1')));
      await settle(tester);
      expect(find.byKey(const Key('ackDialog')), findsOneWidget);
      expect(
        find.text('I declare that I read this document and acknowledge it.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('confirmAck')));
      await settle(tester);
      expect(fake.acknowledged, ['w1']);
      expect(find.byKey(const Key('doc-ack-w1')), findsNothing);

      await tester.tap(find.byKey(const Key('tabPayslips')));
      await settle(tester);
      expect(find.text('Holerite outubro'), findsOneWidget);
      await tester.tap(find.byKey(const Key('doc-ack-p1')));
      await settle(tester);
      expect(
        find.text('Open the document before acknowledging it.'),
        findsOneWidget,
      );
      expect(fake.acknowledged, ['w1']);

      await tester.tap(find.byKey(const Key('doc-open-p1')));
      await settle(tester);
      expect(fake.opened, ['p1']);
      expect(files, ['holerite.pdf:application/pdf']);
      await tester.tap(find.byKey(const Key('doc-ack-p1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirmAck')));
      await settle(tester);
      expect(fake.acknowledged, ['w1', 'p1']);
    },
  );

  testWidgets('the employee sends a document to HR', (tester) async {
    phone(tester);
    final fake = FakePulse();
    await tester.pumpWidget(app(fake));
    await settle(tester);
    await tester.tap(find.byKey(const Key('sendDocumentOpen')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('sendDocument')));
    await settle(tester);
    expect(find.text('This field is required.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('sendTitle')), 'Comprovante');
    await tester.tap(find.byKey(const Key('sendPick')));
    await settle(tester);
    expect(find.text('c.pdf'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sendDocument')));
    await settle(tester);
    expect(fake.sent.single['type'], startsWith('multipart/form-data'));
    expect(find.text('Document sent to HR.'), findsOneWidget);
    expect(find.text('Sent to HR'), findsOneWidget);
  });

  testWidgets('a notice is read when opened and acknowledged when asked', (
    tester,
  ) async {
    phone(tester);
    final fake = FakePulse();
    await tester.pumpWidget(app(fake));
    await settle(tester);
    await tester.tap(find.byKey(const Key('tabNotices')));
    await settle(tester);
    await tester.tap(find.text('Recesso de fim de ano'));
    await settle(tester);
    expect(fake.marks, [
      {'acknowledge': false},
    ]);
    expect(find.text('O expediente termina às 14h no dia 24.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notice-ack-n1')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirmAck')));
    await settle(tester);
    expect(fake.marks.last, {'acknowledge': true});
    expect(find.byKey(const Key('notice-ack-n1')), findsNothing);
  });

  testWidgets('vacation balance and a request within the balance', (
    tester,
  ) async {
    phone(tester);
    final fake = FakePulse();
    final start = DateTime.now().add(const Duration(days: 40));
    final today = DateTime(start.year, start.month, start.day);
    await tester.pumpWidget(
      app(
        fake,
        range: DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 9)),
        ),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('tabVacation')));
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('vacationAvailable'))).data,
      '30',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('vacationPending'))).data,
      '10',
    );
    expect(find.text('Available'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vacationRequest')));
    await settle(tester);
    expect(find.text('10 days'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vacationSend')));
    await settle(tester);
    final sent = fake.requests.single;
    expect(sent['type'], 'absence');
    expect(sent['absenceType'], 'vacation');
    expect(sent['reason'], 'Vacation');
    expect(
      find.text('Vacation request sent. Follow it in Requests.'),
      findsOneWidget,
    );
  });

  testWidgets('a request over the balance is refused before sending', (
    tester,
  ) async {
    phone(tester);
    final fake = FakePulse()..vacationRequestable = 5;
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    await tester.pumpWidget(
      app(
        fake,
        range: DateTimeRange(start: day, end: day.add(const Duration(days: 9))),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('tabVacation')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('vacationRequest')));
    await settle(tester);
    expect(
      find.text('The chosen days go beyond your available balance.'),
      findsOneWidget,
    );
    expect(fake.requests, isEmpty);
  });
}
