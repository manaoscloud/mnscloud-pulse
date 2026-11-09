import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/notifications/notifications_view.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  test('push texts use the app language the API knows', () {
    expect(pushLocale(const Locale('pt', 'BR')), 'pt-BR');
    expect(pushLocale(const Locale('en', 'US')), 'en-US');
    expect(pushLocale(const Locale('es')), 'es-ES');
    expect(pushLocale(const Locale('fr')), 'pt-BR');
  });

  testWidgets(
    'a notification opens the request conversation and a message is sent once',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final read = <Object?>[];
      final sent = <Map<String, dynamic>>[];
      final messages = <Map<String, dynamic>>[
        {
          'MessageUUID': 'm1',
          'AuthorKind': 'portal',
          'AuthorName': null,
          'Mine': false,
          'Body': 'Pode enviar o horário?',
          'DateCreated': '2026-11-02T12:00:00.000Z',
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
        if (path.endsWith('/notifications') && request.method == 'GET') {
          return json({
            'data': {
              'unread': read.isEmpty ? 2 : 1,
              'items': [
                {
                  'NotificationUUID': 'n1',
                  'Type': 'request_message',
                  'RequestUUID': 'R1',
                  'RequestType': 'missing_punch',
                  'RequestStatus': 'pending',
                  'RequestDate': '2026-11-02',
                  'Read': read.isNotEmpty,
                },
                {
                  'NotificationUUID': 'n2',
                  'Type': 'request_decided',
                  'RequestUUID': 'R2',
                  'RequestType': 'absence',
                  'RequestStatus': 'approved',
                  'RequestDate': '2026-11-01',
                  'Read': false,
                },
              ],
            },
          });
        }
        if (path.endsWith('/notifications/read')) {
          read.add((jsonDecode(request.body) as Map)['notificationUUID']);
          return json({
            'data': {'Updated': 1},
          });
        }
        if (path.endsWith('/preferences')) {
          return json({
            'data': {
              'MarkReminders': false,
              'RemindersAvailable': false,
              'PushDevices': 0,
            },
          });
        }
        if (path.endsWith('/requests') && request.method == 'GET') {
          return json({
            'data': {
              'items': [
                {
                  'RequestUUID': 'r1',
                  'Type': 'missing_punch',
                  'Status': 'pending',
                  'Date': '2026-11-02',
                  'PunchType': 'clock_out',
                  'OccurredAt': '2026-11-02T20:00:00.000Z',
                  'Reason': 'Esqueci a saída',
                  'MessageCount': messages.length,
                },
              ],
            },
          });
        }
        if (path.endsWith('/messages') && request.method == 'GET') {
          return json({
            'data': {'items': messages},
          });
        }
        if (path.endsWith('/messages') && request.method == 'POST') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          sent.add(body);
          // The first try is lost on the network: the retry keeps the message identifier.
          if (sent.length == 1) throw http.ClientException('offline');
          messages.add({
            'MessageUUID': body['uuid'],
            'AuthorKind': 'employee',
            'AuthorName': 'Test Employee',
            'Mine': true,
            'Body': body['body'],
            'DateCreated': '2026-11-02T12:05:00.000Z',
          });
          return json({
            'data': {'MessageUUID': body['uuid'], 'Duplicate': false},
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
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byKey(const Key('notifications')));
      await settle(tester);
      expect(find.text('New message on a request'), findsOneWidget);
      expect(find.text('Request approved'), findsOneWidget);
      expect(
        find.text('Your company has not turned on mark reminders.'),
        findsOneWidget,
      );
      final reminders = tester.widget<SwitchListTile>(
        find.byKey(const Key('remindersSwitch')),
      );
      expect(reminders.onChanged, isNull);

      await tester.tap(find.text('New message on a request'));
      await settle(tester);
      expect(read, ['n1']);
      expect(find.text('Pode enviar o horário?'), findsOneWidget);
      expect(find.text('Manager'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('conversationInput')),
        'Saí às 18h',
      );
      await tester.tap(find.byKey(const Key('conversationSend')));
      await settle(tester);
      expect(find.text('Unable to connect. Please try again.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('conversationSend')));
      await settle(tester);
      expect(sent.length, 2);
      expect(sent[1]['uuid'], sent[0]['uuid']);
      expect(sent[1]['body'], 'Saí às 18h');
      expect(find.text('You'), findsOneWidget);
    },
  );
}
