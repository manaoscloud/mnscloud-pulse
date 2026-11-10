import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../core/location_web.dart' as location;
import 'device_permissions.dart';

/// Browsers without the Permissions API for a name (older Safari, Firefox for the camera) keep
/// the last answer obtained through a real request here, so the gate does not reopen on every
/// visit; the mark itself still proves location and camera at the moment it is taken.
const _rememberKey = 'pulse.permissions.granted';

Set<String> _remembered() {
  try {
    final raw = web.window.localStorage.getItem(_rememberKey);
    return raw == null || raw.isEmpty ? <String>{} : raw.split(',').toSet();
  } catch (_) {
    return <String>{};
  }
}

void _remember(String name, bool granted) {
  try {
    final names = _remembered();
    granted ? names.add(name) : names.remove(name);
    web.window.localStorage.setItem(_rememberKey, names.join(','));
  } catch (_) {
    // Private mode: the gate asks again on the next visit.
  }
}

/// granted | prompt | denied, or null when the browser cannot tell.
Future<String?> _query(String name) async {
  try {
    final permissions = web.window.navigator.permissions;
    final status = await permissions
        .query({'name': name}.jsify()! as JSObject)
        .toDart;
    return status.state;
  } catch (_) {
    return null;
  }
}

PermissionState _parse(String? state, String name) => switch (state) {
  'granted' => PermissionState.granted,
  'denied' => PermissionState.denied,
  'prompt' => PermissionState.prompt,
  _ =>
    _remembered().contains(name)
        ? PermissionState.granted
        : PermissionState.prompt,
};

bool get _hasNotification => globalContext.has('Notification');

PermissionState _notifications() {
  if (!_hasNotification) return PermissionState.unsupported;
  return switch (web.Notification.permission) {
    'granted' => PermissionState.granted,
    'denied' => PermissionState.denied,
    _ => PermissionState.prompt,
  };
}

bool get _hasMediaDevices {
  try {
    return web.window.navigator.has('mediaDevices');
  } catch (_) {
    return false;
  }
}

Future<bool> _hasCamera() async {
  if (!_hasMediaDevices) return false;
  try {
    final devices = await web.window.navigator.mediaDevices
        .enumerateDevices()
        .toDart;
    return devices.toDart.any((device) => device.kind == 'videoinput');
  } catch (_) {
    return true;
  }
}

Future<PermissionState> _camera() async {
  if (!_hasMediaDevices) return PermissionState.unavailable;
  final state = _parse(await _query('camera'), 'camera');
  if (state == PermissionState.denied) return state;
  if (!await _hasCamera()) return PermissionState.unavailable;
  return state;
}

Future<PermissionState> _location() async {
  if (!web.window.navigator.has('geolocation')) {
    return PermissionState.unavailable;
  }
  return _parse(await _query('geolocation'), 'geolocation');
}

Future<DevicePermissionsStatus> checkPermissions() async =>
    DevicePermissionsStatus(
      location: await _location(),
      camera: await _camera(),
      notifications: _notifications(),
    );

/// Notifications first: some browsers accept their prompt only right after the tap.
Future<DevicePermissionsStatus> requestPermissions({
  required bool camera,
}) async {
  if (_notifications() == PermissionState.prompt) {
    try {
      await web.Notification.requestPermission().toDart;
    } catch (_) {
      // Refused or not allowed outside an installed app: the state below tells.
    }
  }
  if (camera && await _camera() == PermissionState.prompt) {
    try {
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(
            web.MediaStreamConstraints(
              video: {'facingMode': 'user'}.jsify()!,
              audio: false.toJS,
            ),
          )
          .toDart;
      for (final track in stream.getTracks().toDart) {
        track.stop();
      }
      _remember('camera', true);
    } catch (_) {
      _remember('camera', false);
    }
  }
  if (await _location() == PermissionState.prompt) {
    final position = await location.currentPunchLocation();
    _remember('geolocation', position != null);
  }
  return checkPermissions();
}
