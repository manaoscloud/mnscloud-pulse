import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import '../notifications/notifications_view.dart' show pushLocale;
import '../pwa/pwa.dart';
import 'device_permissions.dart';

/// Pulse opens only with the permissions it needs (the camera when the policy asks for a photo,
/// notifications where the platform has them; location is asked but never required) and checks them again when the app
/// comes back to the foreground and before every mark. One tap asks all that is missing; the
/// browser or the system keeps the answer, so the employee is not asked at every punch.
///
/// The server still decides what a mark is worth: a missing location or photo is flagged for HR.
/// A mark is never refused for lack of location (Portaria MTP 671, art. 74).
class PermissionGate extends StatefulWidget {
  const PermissionGate({
    super.key,
    required this.api,
    required this.child,
    this.onSignOut,
    this.camera,
    this.notifications = true,
  });

  final PulseApi api;
  final Widget child;
  final VoidCallback? onSignOut;

  /// Camera requirement decided by the caller (the time clock setting); null = the policy.
  final bool? camera;

  /// Notifications are asked for the personal app; the shared time clock does not need them.
  final bool notifications;

  @override
  State<PermissionGate> createState() => PermissionGateState();
}

class PermissionGateState extends State<PermissionGate> {
  DevicePermissionsStatus? _status;
  bool _asking = false;
  bool _lost = false;
  AppLifecycleListener? _lifecycle;

  AppLocalizations get l => AppLocalizations.of(context)!;

  /// The camera is needed unless the policy of this employee is known to take no photo.
  bool get _needsCamera =>
      widget.camera ?? (widget.api.punchPhotoMode ?? 'required') != 'off';

  bool get _ready =>
      _status?.ready(
        needsCamera: _needsCamera,
        needsNotifications: widget.notifications,
      ) ??
      false;

  @override
  void initState() {
    super.initState();
    unawaited(_check(policy: widget.api.punchPhotoMode == null));
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_check(policy: true)),
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _check({bool policy = false}) async {
    if (policy && widget.api.signedIn) {
      try {
        await widget.api.today();
      } catch (_) {
        // Offline or session ending: the last known policy (or the camera) stays.
      }
    }
    final status = await devicePermissions.check();
    if (!mounted) return;
    setState(() => _status = status);
  }

  /// Before a mark: reads the permissions again; false (and the gate shows) when one is off.
  Future<bool> ensure() async {
    await _check();
    if (!_ready && mounted) setState(() => _lost = true);
    return _ready;
  }

  Future<void> _request() async {
    if (_asking) return;
    final before = _status?.notifications;
    setState(() => _asking = true);
    try {
      final status = await devicePermissions.request(camera: _needsCamera);
      if (!mounted) return;
      setState(() => _status = status);
      if (before == PermissionState.prompt &&
          status.notifications == PermissionState.granted) {
        await _subscribePush();
      }
    } catch (_) {
      await _check();
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  /// Notifications just allowed: this browser starts receiving the push of the employee.
  Future<void> _subscribePush() async {
    if (!widget.api.signedIn) return;
    try {
      final key = await widget.api.pushKey();
      final raw = key.isEmpty ? null : await pwaSubscribePush(key);
      if (raw == null || !mounted) return;
      await widget.api.subscribePush(
        jsonDecode(raw) as Map<String, dynamic>,
        pushLocale(Localizations.localeOf(context)),
      );
    } catch (_) {
      // Push stays available in the notifications panel.
    }
  }

  String _stateText(PermissionState state) => switch (state) {
    PermissionState.granted => l.permissionGranted,
    PermissionState.prompt => l.permissionPending,
    PermissionState.denied => l.permissionDenied,
    PermissionState.unavailable => l.permissionUnavailable,
    PermissionState.unsupported => l.permissionUnsupported,
  };

  Widget _row(
    Key key,
    IconData icon,
    String title,
    String help,
    PermissionState state,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final ok =
        state == PermissionState.granted ||
        state == PermissionState.unsupported;
    return ListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text('$help\n${_stateText(state)}'),
      isThreeLine: true,
      trailing: Icon(
        ok ? Icons.check_circle : Icons.error_outline,
        color: ok ? scheme.primary : scheme.error,
      ),
    );
  }

  Widget _gate(DevicePermissionsStatus? status) {
    final scheme = Theme.of(context).colorScheme;
    final needsCamera = _needsCamera;
    final settings =
        status?.blockedInSettings(
          needsCamera: needsCamera,
          needsNotifications: widget.notifications,
        ) ??
        false;
    final unavailable =
        status != null &&
        (needsCamera && status.camera == PermissionState.unavailable);
    return Scaffold(
      key: const Key('permissionGate'),
      appBar: AppBar(
        title: Text(l.permissionsTitle),
        actions: [
          if (widget.onSignOut != null)
            IconButton(
              tooltip: l.signOut,
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: status == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_lost)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            l.permissionsLost,
                            key: const Key('permissionsLost'),
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                      Text(l.permissionsIntro),
                      const SizedBox(height: 16),
                      _row(
                        const Key('permissionLocation'),
                        Icons.location_on_outlined,
                        l.permissionLocation,
                        l.permissionLocationHelp,
                        status.location,
                      ),
                      if (needsCamera)
                        _row(
                          const Key('permissionCamera'),
                          Icons.photo_camera_outlined,
                          l.permissionCamera,
                          l.permissionCameraHelp,
                          status.camera,
                        ),
                      if (widget.notifications)
                        _row(
                          const Key('permissionNotifications'),
                          Icons.notifications_outlined,
                          l.permissionNotifications,
                          l.permissionNotificationsHelp,
                          status.notifications,
                        ),
                      const SizedBox(height: 16),
                      if (settings)
                        Text(
                          l.permissionsDeniedHelp,
                          style: TextStyle(color: scheme.error),
                        )
                      else if (unavailable)
                        Text(
                          l.permissionsUnavailableHelp,
                          style: TextStyle(color: scheme.error),
                        )
                      else
                        Text(
                          l.permissionsAlwaysHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const Key('allowPermissions'),
                        onPressed: _asking ? null : _request,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: Text(l.permissionsAllow),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        key: const Key('recheckPermissions'),
                        onPressed: _asking ? null : () => _check(policy: true),
                        child: Text(l.permissionsRecheck),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ready;
    if (ready) _lost = false;
    // The signed-in app stays mounted under the gate (the punch queue keeps sending), but it is
    // neither painted nor reachable until every permission is back.
    return Stack(
      children: [
        Offstage(
          offstage: !ready,
          child: TickerMode(enabled: ready, child: widget.child),
        ),
        if (!ready) Positioned.fill(child: _gate(_status)),
      ],
    );
  }
}
