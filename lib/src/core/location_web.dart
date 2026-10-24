import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'location.dart';

/// One browser position read for the punch (permission asked by the browser, 5 s at most). A
/// refusal, an error or a timeout records the punch without location.
Future<PunchLocation?> currentPunchLocation() {
  final completer = Completer<PunchLocation?>();
  void done(PunchLocation? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  try {
    web.window.navigator.geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        final coords = position.coords;
        done(PunchLocation(coords.latitude, coords.longitude, coords.accuracy));
      }).toJS,
      ((web.GeolocationPositionError _) => done(null)).toJS,
      web.PositionOptions(
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 60000,
      ),
    );
  } catch (_) {
    done(null);
  }
  return completer.future.timeout(
    const Duration(seconds: 6),
    onTimeout: () => null,
  );
}
