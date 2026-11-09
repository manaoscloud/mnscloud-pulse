import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'pwa.dart';

/// `window.mnscloudPwa`, appended to flutter_bootstrap.js by the runtime-kit PWA tooling.
JSObject? get _bridge {
  final value = globalContext['mnscloudPwa'];
  return value.isA<JSObject>() ? value as JSObject : null;
}

PwaInstallState pwaInstallState() {
  final bridge = _bridge;
  if (bridge == null) return PwaInstallState.unavailable;
  try {
    final state = bridge.callMethod<JSString>('installState'.toJS);
    return parsePwaInstallState(state.toDart);
  } catch (_) {
    return PwaInstallState.unavailable;
  }
}

/// Opens the browser install prompt; true when the user accepted.
Future<bool> pwaPromptInstall() async {
  final bridge = _bridge;
  if (bridge == null) return false;
  try {
    final outcome = await bridge
        .callMethod<JSPromise<JSString>>('promptInstall'.toJS)
        .toDart;
    return outcome.toDart == 'accepted';
  } catch (_) {
    return false;
  }
}

void pwaOnInstallChange(void Function() listener) {
  final bridge = _bridge;
  if (bridge == null) return;
  bridge.callMethod<JSAny?>(
    'onInstallChange'.toJS,
    ((JSString _) => listener()).toJS,
  );
}

/// "Update now": activates the waiting service worker revision and reloads (plain reload when the
/// page is not controlled by the MNSCloud service worker).
Future<void> pwaApplyUpdate() async {
  final bridge = _bridge;
  if (bridge == null) {
    web.window.location.reload();
    return;
  }
  try {
    await bridge.callMethod<JSPromise<JSAny?>>('applyUpdate'.toJS).toDart;
  } catch (_) {
    web.window.location.reload();
  }
}

/// Asks the browser to keep this origin's storage (the encrypted punch queue) under pressure.
Future<void> pwaPersistStorage() async {
  final bridge = _bridge;
  if (bridge == null) return;
  try {
    await bridge.callMethod<JSPromise<JSAny?>>('persistStorage'.toJS).toDart;
  } catch (_) {
    // Best effort: the browser decides.
  }
}

/// unsupported | default | granted | denied.
String pwaPushPermission() {
  final bridge = _bridge;
  if (bridge == null || !bridge.has('pushPermission')) return 'unsupported';
  try {
    return bridge.callMethod<JSString>('pushPermission'.toJS).toDart;
  } catch (_) {
    return 'unsupported';
  }
}

Future<String?> _pushCall(String method, [JSAny? argument]) async {
  final bridge = _bridge;
  if (bridge == null || !bridge.has(method)) return null;
  try {
    final result = await bridge
        .callMethod<JSPromise<JSString?>>(method.toJS, argument)
        .toDart;
    return result?.toDart;
  } catch (_) {
    return null;
  }
}

/// Asks permission (call it from a tap) and resolves the `PushSubscription` JSON, or null.
Future<String?> pwaSubscribePush(String publicKey) =>
    _pushCall('subscribePush', publicKey.toJS);

/// The `PushSubscription` JSON of this browser, or null.
Future<String?> pwaCurrentPush() => _pushCall('currentPush');

/// Unsubscribes this browser; resolves the removed endpoint, or null.
Future<String?> pwaUnsubscribePush() => _pushCall('unsubscribePush');

/// [listener] receives the target URL of a notification clicked while the app is open.
void pwaOnNotificationClick(void Function(String url) listener) {
  final bridge = _bridge;
  if (bridge == null || !bridge.has('onNotificationClick')) return;
  bridge.callMethod<JSAny?>(
    'onNotificationClick'.toJS,
    ((JSString url) => listener(url.toDart)).toJS,
  );
}
