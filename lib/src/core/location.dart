export 'location_stub.dart'
    if (dart.library.js_interop) 'location_web.dart'
    if (dart.library.io) 'location_io.dart';

/// Position captured at the moment of a punch (never tracked in the background).
class PunchLocation {
  const PunchLocation(this.latitude, this.longitude, this.accuracyMeters);
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}
