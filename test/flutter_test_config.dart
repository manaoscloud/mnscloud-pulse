import 'dart:async';

import 'package:mnscloud_pulse/src/core/location.dart';
import 'package:mnscloud_pulse/src/permissions/device_permissions.dart';

/// Every widget test starts on a device that already allowed what Pulse needs and has a
/// position; the permission tests replace these with their own fakes.
class GrantedPermissions implements DevicePermissions {
  const GrantedPermissions();

  static const status = DevicePermissionsStatus(
    location: PermissionState.granted,
    camera: PermissionState.granted,
    notifications: PermissionState.granted,
  );

  @override
  Future<DevicePermissionsStatus> check() async => status;

  @override
  Future<DevicePermissionsStatus> request({required bool camera}) async =>
      status;
}

Future<PunchLocation?> testLocation() async =>
    const PunchLocation(-3.1, -60.0, 12);

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  devicePermissions = const GrantedPermissions();
  punchLocator = testLocation;
  await testMain();
}
