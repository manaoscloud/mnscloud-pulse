import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/ids.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_grant.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/punch_sync.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:mnscloud_pulse/src/version/app_build_info.dart';
import 'package:mnscloud_pulse/src/version/app_update_controller.dart';
import 'package:mnscloud_pulse/src/version/app_update_overlay.dart';
import 'package:mnscloud_pulse/src/version/client_identity.dart';
import 'package:mnscloud_pulse/src/version/client_policy.dart';
import 'package:mnscloud_pulse/src/version/runtime_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

Map<String, dynamic> policy(Map<String, String?> minimum) => {
  'status': 'success',
  'data': {
    'app': 'pulse',
    'product': 'mnscloud-pulse',
    'latest': '9.9.9',
    'minimum': {
      'android': null,
      'ios': null,
      'windows': null,
      'macos': null,
      'linux': null,
      ...minimum,
    },
  },
};

final unsupported = {
  'status': 'error',
  'code': 'CLIENT_VERSION_UNSUPPORTED',
  'error': 'Update the app',
};

void main() {
  setUp(() {
    clientVersionRejected.value = false;
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  AppUpdateController native({
    String platform = 'android',
    String? minimum,
    Object? error,
    ValueListenable<bool>? rejection,
  }) => AppUpdateController(
    reader: () async => const RuntimeReleaseInfo(version: '9.9.9'),
    minimumReader: () async {
      if (error != null) throw error;
      return minimum;
    },
    runningVersion: '1.0.3',
    web: false,
    clientPlatform: platform,
    rejection: rejection,
  );

  group('installed app policy', () {
    test('below the minimum of its platform is critical and visible', () async {
      for (final platform in ['android', 'ios', 'windows', 'macos', 'linux']) {
        final update = native(platform: platform, minimum: '1.0.4');
        await update.checkPolicy();
        expect(update.critical, isTrue, reason: platform);
        expect(update.noticeVisible, isTrue, reason: platform);
        update.postpone();
        expect(update.noticeVisible, isTrue, reason: platform);
        update.dispose();
      }
    });

    test(
      'at or above the minimum shows nothing, not even a new version',
      () async {
        for (final minimum in ['1.0.3', '1.0.2', 'v1.0.3']) {
          final update = native(minimum: minimum);
          await update.checkPolicy();
          update.observe(
            const RuntimeReleaseInfo(version: '9.9.9'),
            DateTime(2026),
          );
          expect(update.critical, isFalse, reason: minimum);
          expect(update.noticeVisible, isFalse, reason: minimum);
          update.dispose();
        }
      },
    );

    test('no minimum or a failed read fails open', () async {
      final none = native();
      await none.checkPolicy();
      expect(none.noticeVisible, isFalse);
      none.dispose();
      final failed = native(error: Exception('offline'));
      await failed.checkPolicy();
      expect(failed.noticeVisible, isFalse);
      failed.dispose();
    });

    testWidgets('an API 426 marks it critical', (tester) async {
      final rejection = ValueNotifier<bool>(false);
      final update = native(rejection: rejection);
      update.start();
      await tester.pump();
      expect(update.noticeVisible, isFalse);
      rejection.value = true;
      expect(update.critical, isTrue);
      expect(update.noticeVisible, isTrue);
      update.dispose();
    });

    testWidgets(
      'the native critical notice has the store text and no buttons',
      (tester) async {
        final update = native(minimum: '2.0.0');
        await update.checkPolicy();
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) =>
                AppUpdateOverlay(controller: update, child: child!),
            home: const Scaffold(body: Text('content')),
          ),
        );
        await tester.pump();
        expect(
          find.text(
            'Esta versão do app não é mais aceita. Atualize o app pela loja ou com o administrador para continuar.',
          ),
          findsOneWidget,
        );
        expect(find.byType(FilledButton), findsNothing);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(find.text('content'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        update.dispose();
      },
    );

    test('the web build ignores the client policy', () async {
      var reads = 0;
      final update = AppUpdateController(
        reader: () async => null,
        minimumReader: () async {
          reads++;
          return '9.0.0';
        },
        runningVersion: '1.0.3',
        web: true,
        clientPlatform: 'web',
      );
      expect(update.critical, isFalse);
      expect(update.noticeVisible, isFalse);
      expect(reads, 0);
      update.dispose();
    });
  });

  group('policy endpoint', () {
    test('reads the minimum of the platform from the API base', () async {
      late http.Request seen;
      final client = MockClient((request) async {
        seen = request;
        return json(policy({'android': '1.2.0', 'ios': '1.1.0'}));
      });
      expect(
        await fetchClientMinimum(
          platform: 'android',
          client: client,
          baseUrl: 'https://pulse.test/api/v1/',
        ),
        '1.2.0',
      );
      expect(
        seen.url.toString(),
        'https://pulse.test/api/v1/public/clients/pulse/policy',
      );
      expect(seen.headers['X-Mns-Client-Platform'], 'android');
      expect(
        await fetchClientMinimum(
          platform: 'windows',
          client: client,
          baseUrl: 'https://pulse.test/api/v1',
        ),
        isNull,
      );
    });

    test('fails open and skips without an absolute API base', () async {
      var calls = 0;
      final failing = MockClient((request) async {
        calls++;
        return http.Response('oops', 500);
      });
      expect(
        await fetchClientMinimum(
          platform: 'android',
          client: failing,
          baseUrl: 'https://pulse.test/api/v1',
        ),
        isNull,
      );
      expect(
        await fetchClientMinimum(
          platform: 'android',
          client: failing,
          baseUrl: '/api/v1',
        ),
        isNull,
      );
      expect(calls, 1);
    });
  });

  group('API client', () {
    test('every call carries the client identity headers', () async {
      final seen = <http.BaseRequest>[];
      final client = MockClient((request) async {
        seen.add(request);
        return json({
          'data': {'items': []},
        });
      });
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await api.listPunches();
      await api.createDevicePunch('{}', {'x-pulse-device': 'd'});
      await api.serverTime();
      expect(seen, hasLength(3));
      for (final request in seen) {
        expect(
          request.headers['X-Mns-Client'],
          'mnscloud-pulse/${appBuildInfo.version}',
        );
        expect(request.headers['X-Mns-Client-Platform'], api.platform);
      }
      expect(clientHeaders(platform: 'ios')['X-Mns-Client-Platform'], 'ios');
    });

    test('a 426 CLIENT_VERSION_UNSUPPORTED raises the rejection', () async {
      final client = MockClient((request) async => json(unsupported, 426));
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await expectLater(
        api.listPunches(),
        throwsA(
          isA<PulseFailure>().having(
            (f) => f.versionUnsupported,
            'unsupported',
            isTrue,
          ),
        ),
      );
      expect(clientVersionRejected.value, isTrue);
    });

    test('another 426 or error code does not', () async {
      final client = MockClient(
        (request) async => json({'code': 'OTHER'}, 426),
      );
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await expectLater(api.listPunches(), throwsA(isA<PulseFailure>()));
      expect(clientVersionRejected.value, isFalse);
    });

    test('queued offline marks are kept when the version is refused', () async {
      final store = await PunchStore.open();
      final punch = QueuedPunch(
        idempotencyKey: uuidV4(),
        type: 'clock_in',
        occurredAt: DateTime.now().toUtc(),
      );
      store.add('account-1', punch);
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/signin')) {
          return json({
            'data': {
              'accessToken': 'access-token',
              'account': {'timeClockAccountUUID': 'account-1'},
            },
          });
        }
        return json(unsupported, 426);
      });
      final api = PulseApi(
        client: client,
        baseUrl: 'https://pulse.test/api/v1',
      );
      await api.signIn('ABCD-EFGH', 'secret');
      final grants = DeviceGrants(
        api: api,
        clock: ServerClock(),
        vault: SecretVault.instance,
      );
      final sync = PunchSync(api: api, grants: grants, source: 'mobile');
      final result = await sync.flush('account-1');
      expect(result.sent, 0);
      expect(
        store.pending('account-1').single.idempotencyKey,
        punch.idempotencyKey,
      );
      expect(clientVersionRejected.value, isTrue);
    });
  });
}
