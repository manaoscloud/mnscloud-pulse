import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/core/pulse_api.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/core/server_clock.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:mnscloud_pulse/src/permissions/device_permissions.dart';
import 'package:mnscloud_pulse/src/requests/requests_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import 'flutter_test_config.dart';

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

/// A device that has not allowed anything yet; [request] allows what is asked.
class FakePermissions implements DevicePermissions {
  FakePermissions(this.current);

  DevicePermissionsStatus current;
  final requests = <bool>[];

  @override
  Future<DevicePermissionsStatus> check() async => current;

  @override
  Future<DevicePermissionsStatus> request({required bool camera}) async {
    requests.add(camera);
    current = GrantedPermissions.status;
    return current;
  }
}

const nothingAllowed = DevicePermissionsStatus(
  location: PermissionState.prompt,
  camera: PermissionState.prompt,
  notifications: PermissionState.prompt,
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

MockClient client(List<Map<String, dynamic>> punches, {String mode = 'off'}) =>
    MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/auth/refresh')) return json(session);
      if (path.endsWith('/time')) {
        return json({
          'data': {'serverTime': DateTime.now().toUtc().toIso8601String()},
        });
      }
      if (path.endsWith('/today')) {
        return json({
          'data': {
            'date': '2026-11-10',
            'timezone': 'America/Sao_Paulo',
            'punchPhotoMode': mode,
            'punches': <Object>[],
            'working': false,
            'workedMinutes': 0,
          },
        });
      }
      if (path.endsWith('/punches') && request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        punches.add(body);
        return json({
          'data': {
            'item': {
              'TimePunchUUID': 'punch-${punches.length}',
              'Type': body['type'],
              'OccurredAt': DateTime.now().toUtc().toIso8601String(),
              'Source': 'mobile',
            },
          },
        });
      }
      if (path.endsWith('/punches')) {
        return json({
          'data': {'items': <Object>[]},
        });
      }
      return json({'data': <String, Object>{}});
    });

Widget app(http.Client client) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en', 'US'),
  home: PulseShell(client: client),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });
  tearDown(() => devicePermissions = const GrantedPermissions());

  testWidgets('the app opens only after every permission is allowed once', (
    tester,
  ) async {
    final fake = FakePermissions(nothingAllowed);
    devicePermissions = fake;
    await tester.pumpWidget(app(client([], mode: 'required')));
    await settle(tester);
    expect(find.byKey(const Key('permissionGate')), findsOneWidget);
    expect(find.byKey(const Key('permissionCamera')), findsOneWidget);
    expect(find.byKey(const Key('nextPunch')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('allowPermissions')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('allowPermissions')));
    await settle(tester);
    expect(fake.requests, [true]);
    expect(find.byKey(const Key('permissionGate')), findsNothing);
    expect(find.byKey(const Key('nextPunch')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a policy without photo does not ask for the camera', (
    tester,
  ) async {
    final fake = FakePermissions(
      const DevicePermissionsStatus(
        location: PermissionState.granted,
        camera: PermissionState.prompt,
        notifications: PermissionState.granted,
      ),
    );
    devicePermissions = fake;
    await tester.pumpWidget(app(client([])));
    await settle(tester);
    expect(find.byKey(const Key('permissionGate')), findsNothing);
    expect(find.byKey(const Key('nextPunch')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a camera turned off blocks the next punch and opens the gate', (
    tester,
  ) async {
    final punches = <Map<String, dynamic>>[];
    final fake = FakePermissions(GrantedPermissions.status);
    devicePermissions = fake;
    await tester.pumpWidget(app(client(punches, mode: 'required')));
    await settle(tester);
    fake.current = const DevicePermissionsStatus(
      location: PermissionState.granted,
      camera: PermissionState.denied,
      notifications: PermissionState.granted,
    );
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    expect(find.byKey(const Key('confirmPunchDialog')), findsNothing);
    expect(find.byKey(const Key('permissionGate')), findsOneWidget);
    expect(find.byKey(const Key('permissionsLost')), findsOneWidget);
    expect(punches, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('location turned off never closes the app or blocks a punch', (
    tester,
  ) async {
    final punches = <Map<String, dynamic>>[];
    final fake = FakePermissions(GrantedPermissions.status);
    devicePermissions = fake;
    await tester.pumpWidget(app(client(punches)));
    await settle(tester);
    fake.current = const DevicePermissionsStatus(
      location: PermissionState.denied,
      camera: PermissionState.granted,
      notifications: PermissionState.granted,
    );
    await tester.tap(find.byKey(const Key('nextPunch')));
    await settle(tester);
    expect(find.byKey(const Key('permissionGate')), findsNothing);
    expect(find.byKey(const Key('confirmPunchDialog')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('readiness ignores location but keeps the camera and notifications', () {
    const noLocation = DevicePermissionsStatus(
      location: PermissionState.denied,
      camera: PermissionState.granted,
      notifications: PermissionState.granted,
    );
    expect(noLocation.ready(needsCamera: true), isTrue);
    expect(noLocation.blockedInSettings(needsCamera: true), isFalse);
    const noCamera = DevicePermissionsStatus(
      location: PermissionState.granted,
      camera: PermissionState.denied,
      notifications: PermissionState.granted,
    );
    expect(noCamera.ready(needsCamera: true), isFalse);
    expect(noCamera.ready(needsCamera: false), isTrue);
  });

  testWidgets(
    'the requests title keeps its width beside the new request button',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = PulseApi(
        client: MockClient(
          (_) async => json({
            'data': {'items': <Object>[]},
          }),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt', 'BR'),
          // Same full-width filled buttons as the app theme.
          theme: ThemeData(
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          home: Scaffold(
            body: RequestsView(
              api: api,
              clock: ServerClock(),
              onSessionEnded: (_) {},
            ),
          ),
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      final title = tester.getSize(find.text('Solicitações').first);
      expect(title.height, lessThan(60));
      expect(find.byKey(const Key('newRequest')), findsOneWidget);
      final button = tester.getRect(find.byKey(const Key('newRequest')));
      expect(button.right, lessThanOrEqualTo(1280));
      expect(button.width, lessThan(400));
    },
  );
}
