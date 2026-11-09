import 'pwa.dart';

PwaInstallState pwaInstallState() => PwaInstallState.unavailable;

Future<bool> pwaPromptInstall() async => false;

void pwaOnInstallChange(void Function() listener) {}

/// Activates a waiting web revision and reloads; nothing to do outside the browser.
Future<void> pwaApplyUpdate() async {}

/// Native storage is not evicted by the platform; nothing to ask.
Future<void> pwaPersistStorage() async {}

/// Web Push exists only in the browser build.
String pwaPushPermission() => 'unsupported';

Future<String?> pwaSubscribePush(String publicKey) async => null;

Future<String?> pwaCurrentPush() async => null;

Future<String?> pwaUnsubscribePush() async => null;

void pwaOnNotificationClick(void Function(String url) listener) {}
