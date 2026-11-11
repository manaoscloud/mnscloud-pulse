import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser full screen of the time clock (needs a tap); the operating system pins the browser.
bool get fullscreenAvailable => web.document.fullscreenEnabled;

void requestFullscreen() {
  try {
    if (web.document.fullscreenElement != null) return;
    web.document.documentElement?.requestFullscreen().toDart.catchError(
      (_) => null,
    );
  } catch (_) {
    // Refused by the browser: the app keeps running in the window.
  }
}
