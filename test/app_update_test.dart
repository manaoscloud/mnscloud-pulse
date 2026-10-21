import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/src/version/app_update_controller.dart';
import 'package:mnscloud_pulse/src/version/app_update_overlay.dart';
import 'package:mnscloud_pulse/src/version/runtime_version.dart';

void main() {
  final t0 = DateTime(2026, 10, 16, 12);
  late DateTime now;

  AppUpdateController controller() => AppUpdateController(
    reader: () async => null,
    runningVersion: '1.0.3',
    clock: () => now,
  );

  setUp(() => now = t0);

  test('announces a new release only after two reads agree 45 s apart', () {
    final update = controller();
    update.observe(const RuntimeReleaseInfo(version: '1.0.4'), t0);
    expect(update.updateAvailable, isFalse);
    update.observe(
      const RuntimeReleaseInfo(version: '1.0.4'),
      t0.add(AppUpdateController.confirmDelay),
    );
    expect(update.noticeVisible, isTrue);
    update.postpone();
    expect(update.noticeVisible, isFalse);
    update.dispose();
  });

  test('stays quiet on the running version', () {
    final update = controller();
    update.observe(const RuntimeReleaseInfo(version: 'v1.0.3'), t0);
    expect(update.updateAvailable, isFalse);
    update.dispose();
  });

  testWidgets('shows the notice over the app and hides it on "Later"', (
    tester,
  ) async {
    final update = controller();
    addTearDown(update.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppUpdateOverlay(
          controller: update,
          child: const Scaffold(body: Text('content')),
        ),
      ),
    );
    expect(find.text('New version available'), findsNothing);

    update.observe(const RuntimeReleaseInfo(version: '1.0.4'), t0);
    update.observe(
      const RuntimeReleaseInfo(version: '1.0.4'),
      t0.add(AppUpdateController.confirmDelay),
    );
    await tester.pump();
    expect(find.textContaining('New version available'), findsOneWidget);
    expect(find.textContaining('sign in again'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pump();
    expect(find.textContaining('New version available'), findsNothing);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('a critical release shows no "Later"', (tester) async {
    final update = controller();
    addTearDown(update.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppUpdateOverlay(
          controller: update,
          child: const Scaffold(body: Text('content')),
        ),
      ),
    );
    const critical = RuntimeReleaseInfo(
      version: '1.0.5',
      minimumVersion: '1.0.5',
    );
    update.observe(critical, t0);
    update.observe(critical, t0.add(AppUpdateController.confirmDelay));
    await tester.pump();
    expect(find.textContaining('Important update'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
    update.postpone();
    await tester.pump();
    expect(find.textContaining('Important update'), findsOneWidget);
  });
  testWidgets(
    'hovering the close button above the Navigator shows its tooltip',
    (tester) async {
      // Mounted like lib/main.dart: MaterialApp.builder, outside the Navigator.
      final update = controller();
      addTearDown(update.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              AppUpdateOverlay(controller: update, child: child!),
          home: const Scaffold(body: Text('content')),
        ),
      );
      update.observe(const RuntimeReleaseInfo(version: '1.0.4'), t0);
      update.observe(
        const RuntimeReleaseInfo(version: '1.0.4'),
        t0.add(AppUpdateController.confirmDelay),
      );
      await tester.pump();

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.close)));
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      expect(find.byType(Tooltip), findsOneWidget);
      expect(find.text('Later'), findsNWidgets(2));
      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    },
  );
}
