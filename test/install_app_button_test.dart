import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/l10n/app_localizations.dart';
import 'package:mnscloud_pulse/src/pwa/install_app_button.dart';

void main() {
  testWidgets('outside an installable browser the install button is hidden', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: InstallAppButton(labeled: true)),
    ));
    expect(find.byKey(const Key('installApp')), findsNothing);
  });
}
