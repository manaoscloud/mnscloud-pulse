import 'package:geolocator/geolocator.dart';

import 'location.dart';

/// One native position read for the punch (5 s at most). Disabled location services, a refused
/// permission, an error or a timeout record the punch without location; the app never tracks the
/// position in the background.
Future<PunchLocation?> currentPunchLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      ),
    ).timeout(const Duration(seconds: 6));
    return PunchLocation(
      position.latitude,
      position.longitude,
      position.accuracy,
    );
  } catch (_) {
    return null;
  }
}
