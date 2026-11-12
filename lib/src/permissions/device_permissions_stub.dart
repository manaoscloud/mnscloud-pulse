import 'device_permissions.dart';

const _none = DevicePermissionsStatus(
  location: PermissionState.unavailable,
  camera: PermissionState.unsupported,
  notifications: PermissionState.unsupported,
);

/// Platforms without location record the mark without it (flagged for HR).
Future<DevicePermissionsStatus> checkPermissions() async => _none;

Future<DevicePermissionsStatus> requestPermissions({
  required bool camera,
}) async => _none;
