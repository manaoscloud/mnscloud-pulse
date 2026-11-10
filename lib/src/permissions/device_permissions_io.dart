import 'package:geolocator/geolocator.dart';

import 'device_permissions.dart';

/// Native apps: location through the system permission and the location service. The camera is
/// asked by the system camera itself at the first photo and notifications have no native channel
/// yet (web push only), so neither blocks here.
Future<DevicePermissionsStatus> checkPermissions() async =>
    _status(await _location(ask: false));

Future<DevicePermissionsStatus> requestPermissions({
  required bool camera,
}) async => _status(await _location(ask: true));

DevicePermissionsStatus _status(PermissionState location) =>
    DevicePermissionsStatus(
      location: location,
      camera: PermissionState.unsupported,
      notifications: PermissionState.unsupported,
    );

Future<PermissionState> _location({required bool ask}) async {
  try {
    var permission = await Geolocator.checkPermission();
    if (ask && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final state = switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => PermissionState.granted,
      LocationPermission.deniedForever => PermissionState.denied,
      _ => PermissionState.prompt,
    };
    if (state != PermissionState.granted) return state;
    return await Geolocator.isLocationServiceEnabled()
        ? PermissionState.granted
        : PermissionState.unavailable;
  } catch (_) {
    return PermissionState.unavailable;
  }
}
