import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/src/access/access_preferences.dart';
import 'package:mnscloud_pulse/src/brand/brand.dart';

void main() {
  tearDown(() {
    pulseBrand.value = null;
    accessLocale.value = null;
  });
  testWidgets(
    'locale change preserves typed credentials and fields remain reachable on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const PulseApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'EMP123');
      accessLocale.value = const Locale('pt', 'BR');
      await tester.pumpAndSettle();
      expect(find.text('Acesse seu ponto'), findsOneWidget);
      expect(find.text('EMP123'), findsOneWidget);
      await tester.ensureVisible(find.text('Entrar'));
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Este campo é obrigatório.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'temporary password opens the change form without requesting punches',
    (tester) async {
      final paths = <String>[];
      final client = MockClient((request) async {
        paths.add(request.url.path);
        return http.Response(
          jsonEncode({
            'data': {
              'jwt': 'test-session',
              'account': {
                'mustChangePassword': true,
                'employeeName': 'Test',
                'loginCode': 'TEST',
              },
            },
          }),
          200,
        );
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en', 'US'),
          home: PulseShell(client: client),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'TEST');
      await tester.enterText(find.byType(TextFormField).last, 'temporary-test');
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(paths, ['/api/v1/pulse/auth/signin']);
      expect(find.text('Create your new password'), findsOneWidget);
      expect(find.text('Save new password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('desktop custom copy and compact layout use the public brand', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    pulseBrand.value = const Brand(
      title: 'Example Company',
      login: {
        'layout': 'split',
        'texts': {
          'en-US': {'title': 'Team access'},
        },
      },
    );
    accessLocale.value = const Locale('en', 'US');
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();
    expect(find.text('Team access'), findsOneWidget);
    expect(find.text('Your workday.\nConnected.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    pulseBrand.value = const Brand(
      title: 'Example Company',
      login: {'layout': 'compact'},
    );
    await tester.pumpAndSettle();
    expect(find.text('Your workday.\nConnected.'), findsNothing);
  });
  test('public links reject credentials and executable schemes', () {
    expect(Brand.safeLink('javascript:alert(1)'), isNull);
    expect(Brand.safeLink('https://user:secret@example.com/'), isNull);
    expect(
      Brand.safeLink('https://example.com/help'),
      'https://example.com/help',
    );
  });
}
