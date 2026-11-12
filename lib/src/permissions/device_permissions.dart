import 'device_permissions_stub.dart'
    if (dart.library.js_interop) 'device_permissions_web.dart'
    if (dart.library.io) 'device_permissions_io.dart'
    as platform;

/// State of one device permission as the platform reports it, without asking.
enum PermissionState {
  /// Allowed: the app may use it without asking again.
  granted,

  /// Never answered (or answered "only this time"): one tap asks it.
  prompt,

  /// Refused: the browser or the system no longer asks; the user turns it on in the settings.
  denied,

  /// Allowed, but the device service is off or missing (GPS off, no camera).
  unavailable,

  /// The platform has no such permission here (for example web push outside an installed app
  /// on iOS); it never blocks.
  unsupported,
}

/// What Pulse needs before it opens and before every mark: the camera when the employee policy
/// asks for a photo, notifications where the platform has them. Location is always asked but never
/// required: a mark is never restricted (Portaria MTP 671, art. 74), one without location is
/// recorded and flagged for HR.
class DevicePermissionsStatus {
  const DevicePermissionsStatus({
    required this.location,
    required this.camera,
    required this.notifications,
  });

  final PermissionState location;
  final PermissionState camera;
  final PermissionState notifications;

  bool cameraReady(bool needsCamera) =>
      !needsCamera ||
      camera == PermissionState.granted ||
      camera == PermissionState.unsupported;

  /// Informational only: it never keeps the app closed.
  bool get locationReady => location == PermissionState.granted;

  bool get notificationsReady =>
      notifications == PermissionState.granted ||
      notifications == PermissionState.unsupported;

  bool ready({required bool needsCamera, bool needsNotifications = true}) =>
      cameraReady(needsCamera) && (!needsNotifications || notificationsReady);

  /// Something only the settings can fix (the browser or the system does not ask again).
  bool blockedInSettings({
    required bool needsCamera,
    bool needsNotifications = true,
  }) =>
      (needsCamera && camera == PermissionState.denied) ||
      (needsNotifications && notifications == PermissionState.denied);
}

/// Reads and asks the permissions of this device. Replaced only by tests.
abstract class DevicePermissions {
  /// Current state, never shows a prompt.
  Future<DevicePermissionsStatus> check();

  /// Asks every missing permission in one go (call it from a tap): notifications, camera (when
  /// [camera]) and location. The browser or the system keeps the answer for the next visits.
  Future<DevicePermissionsStatus> request({required bool camera});
}

class _PlatformPermissions implements DevicePermissions {
  const _PlatformPermissions();

  @override
  Future<DevicePermissionsStatus> check() => platform.checkPermissions();

  @override
  Future<DevicePermissionsStatus> request({required bool camera}) =>
      platform.requestPermissions(camera: camera);
}

DevicePermissions devicePermissions = const _PlatformPermissions();
