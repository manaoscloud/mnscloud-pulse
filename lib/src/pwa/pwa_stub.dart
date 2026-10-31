import 'pwa.dart';

PwaInstallState pwaInstallState() => PwaInstallState.unavailable;

Future<bool> pwaPromptInstall() async => false;

void pwaOnInstallChange(void Function() listener) {}

/// Activates a waiting web revision and reloads; nothing to do outside the browser.
Future<void> pwaApplyUpdate() async {}

/// Native storage is not evicted by the platform; nothing to ask.
Future<void> pwaPersistStorage() async {}
