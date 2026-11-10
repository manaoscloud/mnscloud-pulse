import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/ids.dart';
import '../core/location.dart';
import '../core/punch_camera.dart';
import '../core/pulse_api.dart';
import '../core/punch_queue.dart';
import '../core/server_clock.dart';
import '../offline/punch_sync.dart';
import '../timesheet/today_card.dart';
import 'punch_labels.dart';

/// Employee home: official time, the suggested next mark (every mark stays available), the
/// delivery state of marks taken without connection and the recent marks with their receipt.
class PunchWorkspace extends StatefulWidget {
  const PunchWorkspace({
    super.key,
    required this.api,
    required this.account,
    required this.clock,
    required this.sync,
    required this.onSessionEnded,
    this.locate,
    this.ensurePermissions,
  });

  final PulseApi api;

  /// The single sender of queued marks (session, or the offline grant of this device).
  final PunchSync sync;
  final PulseAccount account;
  final ServerClock clock;
  final void Function(String code) onSessionEnded;

  /// Position of the mark; [punchLocator] when not given.
  final Future<PunchLocation?> Function()? locate;

  /// Checked before every mark: false when a permission Pulse needs was turned off (the
  /// permission gate opens again and nothing is recorded).
  final Future<bool> Function()? ensurePermissions;

  @override
  State<PunchWorkspace> createState() => _PunchWorkspaceState();
}

class _PunchWorkspaceState extends State<PunchWorkspace> {
  late final PunchQueue _queue = PunchQueue(
    widget.account.timeClockAccountUUID,
  );
  List<Map<String, dynamic>> _punches = [];
  List<QueuedPunch> _pending = [];
  bool _online = true;
  bool _busy = false;
  bool _flushing = false;
  bool _showOthers = false;
  bool _confirming = false;
  String? _message;
  bool _messageError = false;
  Timer? _retry;

  /// Bumped when a mark reaches the API, so the today summary reads the new state.
  final _delivered = ValueNotifier<int>(0);

  AppLocalizations get l => AppLocalizations.of(context)!;
  String get _source => kIsWeb ? 'web' : 'mobile';

  @override
  void initState() {
    super.initState();
    widget.sync.addListener(_synced);
    unawaited(_start());
  }

  @override
  void dispose() {
    widget.sync.removeListener(_synced);
    _retry?.cancel();
    _delivered.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final serverTime = await widget.api.serverTime();
    if (serverTime != null) widget.clock.accept(serverTime);
    _pending = await _queue.load();
    await _flush();
    await _reload();
  }

  void _scheduleRetry() {
    _retry?.cancel();
    if (_pending.isEmpty || !mounted) return;
    _retry = Timer(const Duration(seconds: 30), () => unawaited(_flush()));
  }

  bool _handleFailure(PulseFailure failure) {
    if (failure.sessionEnded) {
      widget.onSessionEnded(failure.code);
      return true;
    }
    return false;
  }

  Future<void> _reload() async {
    try {
      final items = await widget.api.listPunches();
      if (!mounted) return;
      setState(() {
        _punches = items;
        _online = true;
      });
    } on PulseFailure catch (failure) {
      if (_handleFailure(failure) || !mounted) return;
      setState(() => _online = failure.code != 'networkError');
    }
  }

  /// Marks delivered by another pass (tick, reconnection, foreground): refresh the state.
  Future<void> _synced() async {
    _pending = await _queue.load();
    if (!mounted) return;
    setState(() {});
    _delivered.value++;
    if (widget.api.signedIn) await _reload();
  }

  /// Sends the queued marks oldest first (with the session, or signed by this device when there
  /// is none); a network failure stops and retries later.
  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final result = await widget.sync.flush(
        widget.account.timeClockAccountUUID,
      );
      if (result.sessionEnded != null) {
        widget.onSessionEnded(result.sessionEnded!);
        return;
      }
      _pending = await _queue.load();
      if (mounted) setState(() => _online = !result.offline);
    } finally {
      _flushing = false;
      _scheduleRetry();
    }
  }

  Future<void> _record(String type) async {
    if (_busy || _confirming) return;
    try {
      _confirming = true;
      final _PunchDecision? decision;
      try {
        final ensure = widget.ensurePermissions;
        if (ensure != null && !await ensure()) return;
        if (!mounted) return;
        decision = await _confirm(type);
      } finally {
        _confirming = false;
      }
      if (decision == null || !mounted) return;
      await _recordMark(type, decision.photo);
    } catch (_) {
      // The device store or the platform failed: the button never stays waiting.
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'requestError';
        _messageError = true;
      });
    }
  }

  /// Photo at punch of the employee policy; read once from the day summary when still unknown.
  Future<String> _photoMode() async {
    if (widget.api.punchPhotoMode == null && widget.api.signedIn) {
      try {
        await widget.api.today();
      } catch (_) {
        // Unknown (offline, error): no photo is asked, the mark never waits for it.
      }
    }
    return widget.api.punchPhotoMode ?? 'off';
  }

  Future<Uint8List?> _takePhoto() async {
    try {
      return await punchPhotoCapture(context);
    } catch (_) {
      // Camera denied or unavailable: a required photo keeps the confirmation closed, an
      // optional one lets the mark go flagged for HR.
      return null;
    }
  }

  /// Every mark is confirmed first: type, official time and, when the policy asks, the photo.
  Future<_PunchDecision?> _confirm(String type) async {
    final mode = await _photoMode();
    final wantsPhoto = mode == 'optional' || mode == 'required';
    final photo = wantsPhoto ? await _takePhoto() : null;
    if (!mounted) return null;
    return showDialog<_PunchDecision>(
      context: context,
      builder: (_) => _ConfirmPunchDialog(
        type: type,
        icon: _icon(type),
        clock: widget.clock,
        photoMode: mode,
        photo: photo,
        takePhoto: _takePhoto,
      ),
    );
  }

  Future<void> _recordMark(String type, Uint8List? photo) async {
    setState(() {
      _busy = true;
      _message = null;
      _showOthers = false;
    });
    final occurredAt = widget.clock.nowUtc();
    final location = await (widget.locate ?? punchLocator)();
    if (location == null) {
      // Pulse records a mark only with the position of that moment (GPS off, refused, timeout).
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'locationRequired';
        _messageError = true;
      });
      return;
    }
    final punch = QueuedPunch(
      idempotencyKey: uuidV4(),
      type: type,
      occurredAt: occurredAt,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracyMeters: location.accuracyMeters,
    );
    // Kept on the device before sending: a lost answer or no connection never loses the mark.
    await _queue.add(punch);
    String message = 'punchSaved';
    bool error = false;
    if (!widget.api.signedIn) {
      // Opened without a session (offline): the device grant sends it when there is connection.
      await _flush();
      _pending = await _queue.load();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = _pending.any((p) => p.idempotencyKey == punch.idempotencyKey)
            ? (photo == null ? 'punchQueued' : 'punchPhotoOffline')
            : 'punchSaved';
        _messageError = false;
      });
      return;
    }
    try {
      final item = await widget.api.createPunch(
        punch.body(offline: false, source: _source),
      );
      await _queue.remove(punch.idempotencyKey);
      if (item['Duplicate'] == 1) message = 'punchSynced';
      _online = true;
      _delivered.value++;
      final punchUUID = item['TimePunchUUID']?.toString();
      if (photo != null && punchUUID != null && punchUUID.isNotEmpty) {
        message = await _sendPhoto(punchUUID, photo);
      }
    } on PulseFailure catch (failure) {
      if (_handleFailure(failure)) return;
      if (failure.code == 'networkError') {
        _online = false;
        message = photo == null ? 'punchQueued' : 'punchPhotoOffline';
      } else if (failure.versionUnsupported) {
        // This app version is refused: the mark stays queued and goes after the update.
        message = 'punchQueued';
      } else if (failure.code == 'PULSE_RATE_LIMITED') {
        message = 'rateLimited';
        error = true;
      } else {
        await _queue.remove(punch.idempotencyKey);
        message = 'requestError';
        error = true;
      }
    }
    _pending = await _queue.load();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = message;
      _messageError = error;
    });
    _scheduleRetry();
    if (_online) await _reload();
  }

  /// The mark is already recorded: a photo that does not go is reported, never retried later.
  Future<String> _sendPhoto(String punchUUID, Uint8List photo) async {
    try {
      await widget.api.uploadPunchPhoto(punchUUID, uuidV4(), photo);
      return 'punchPhotoSaved';
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) widget.onSessionEnded(failure.code);
      return 'punchPhotoFailed';
    } catch (_) {
      return 'punchPhotoFailed';
    }
  }

  String _text(String key) => switch (key) {
    'punchSaved' => l.punchSaved,
    'punchPhotoSaved' => l.punchPhotoSaved,
    'locationRequired' => l.locationRequired,
    'punchPhotoFailed' => l.punchPhotoFailed,
    'punchPhotoOffline' => l.punchPhotoOffline,
    'punchSynced' => l.punchSynced,
    'punchQueued' => l.punchQueued,
    'rateLimited' => l.rateLimited,
    _ => l.requestError,
  };

  String? get _lastType {
    final candidates = <(DateTime, String)>[
      for (final p in _pending) (p.occurredAt, p.type),
      for (final p in _punches)
        if (DateTime.tryParse(p['OccurredAt']?.toString() ?? '') case final at?)
          (at, p['Type']?.toString() ?? ''),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return candidates.isEmpty ? null : candidates.first.$2;
  }

  String _whenText(BuildContext context, Object? value) {
    final at = DateTime.tryParse(value?.toString() ?? '');
    return at == null ? '' : _when(context, at);
  }

  String _when(BuildContext context, DateTime utc) {
    final local = utc.toLocal();
    final material = MaterialLocalizations.of(context);
    return '${material.formatShortDate(local)} · ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final next = nextPunchType(_lastType);
    final receipt = _punches.where((p) => p['NSR'] != null).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.account.employeeName ?? l.employee,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          [
            widget.account.companyName,
            if (widget.account.hrAccountName != widget.account.companyName)
              widget.account.hrAccountName,
            widget.account.loginCode,
          ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _OfficialClock(clock: widget.clock),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 18,
              color: _online ? scheme.primary : scheme.error,
            ),
            const SizedBox(width: 6),
            Text(_online ? l.onlineStatus : l.offlineStatus),
            if (_pending.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.pendingPunches(_pending.length),
                  key: const Key('pendingPunches'),
                  style: TextStyle(color: scheme.tertiary),
                ),
              ),
            ],
          ],
        ),
        TodayCard(api: widget.api, reload: _delivered),
        const SizedBox(height: 20),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _text(_message!),
                style: TextStyle(
                  color: _messageError ? scheme.error : scheme.primary,
                ),
              ),
            ),
          ),
        Text(l.nextPunch, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: FilledButton.icon(
            key: const Key('nextPunch'),
            onPressed: _busy ? null : () => _record(next),
            icon: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_icon(next)),
            label: Text(
              punchLabel(l, next),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const Key('otherPunch'),
          onPressed: _busy
              ? null
              : () => setState(() => _showOthers = !_showOthers),
          icon: Icon(_showOthers ? Icons.expand_less : Icons.expand_more),
          label: Text(l.otherPunch),
        ),
        if (_showOthers)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in punchTypes)
                if (type != next)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _record(type),
                    icon: Icon(_icon(type)),
                    label: Text(punchLabel(l, type)),
                  ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          l.locationNote,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (receipt != null) ...[
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l.receipt),
              subtitle: Text(
                '${punchLabel(l, receipt['Type']?.toString() ?? '')} · ${l.nsrLabel(receipt['NSR'].toString())}\n'
                '${_shortHash(receipt['Hash'])}…',
              ),
              isThreeLine: true,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(l.recentPunches, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_pending.isEmpty && _punches.isEmpty)
          Text(
            l.noPunchesYet,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        for (final punch in _pending.reversed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.schedule_send_outlined, color: scheme.tertiary),
            title: Text(punchLabel(l, punch.type)),
            subtitle: Text(_when(context, punch.occurredAt)),
            trailing: Text(
              l.pendingSend,
              style: TextStyle(color: scheme.tertiary),
            ),
          ),
        for (final punch in _punches)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_icon(punch['Type']?.toString() ?? '')),
            title: Text(punchLabel(l, punch['Type']?.toString() ?? '')),
            subtitle: Text(_whenText(context, punch['OccurredAt'])),
            trailing: Text(
              [
                if ((punch['Flags'] as List?)?.contains('offline') ?? false)
                  l.sentLater,
                if (punch['NSR'] != null) l.nsrLabel(punch['NSR'].toString()),
                if (punch['HasPhoto'] == true) l.withPhoto,
              ].join('\n'),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  String _shortHash(Object? hash) {
    final text = hash?.toString() ?? '';
    return text.length > 16 ? text.substring(0, 16) : text;
  }

  IconData _icon(String type) => switch (type) {
    'clock_in' => Icons.login,
    'break_start' => Icons.coffee_outlined,
    'break_end' => Icons.work_outline,
    'clock_out' => Icons.logout,
    _ => Icons.schedule,
  };
}

/// hh:mm:ss of the official clock, ticking on its own so the rest of the page does not rebuild.
class _OfficialClock extends StatefulWidget {
  const _OfficialClock({required this.clock});
  final ServerClock clock;

  @override
  State<_OfficialClock> createState() => _OfficialClockState();
}

class _OfficialClockState extends State<_OfficialClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final now = widget.clock.nowUtc().toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.officialTime, style: Theme.of(context).textTheme.labelLarge),
        Text(
          '${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
          key: const Key('officialClock'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(MaterialLocalizations.of(context).formatFullDate(now)),
      ],
    );
  }
}

class _PunchDecision {
  const _PunchDecision(this.photo);
  final Uint8List? photo;
}

/// Confirmation of one mark: what will be recorded, the official time and the photo (if asked).
class _ConfirmPunchDialog extends StatefulWidget {
  const _ConfirmPunchDialog({
    required this.type,
    required this.icon,
    required this.clock,
    required this.photoMode,
    required this.photo,
    required this.takePhoto,
  });

  final String type;
  final IconData icon;
  final ServerClock clock;
  final String photoMode;
  final Uint8List? photo;
  final Future<Uint8List?> Function() takePhoto;

  @override
  State<_ConfirmPunchDialog> createState() => _ConfirmPunchDialogState();
}

class _ConfirmPunchDialogState extends State<_ConfirmPunchDialog> {
  late Uint8List? _photo = widget.photo;
  bool _taking = false;

  bool get _asksPhoto =>
      widget.photoMode == 'optional' || widget.photoMode == 'required';

  /// A required photo is the confirmation itself: no photo, no mark.
  bool get _blocked => widget.photoMode == 'required' && _photo == null;

  Future<void> _retake() async {
    setState(() => _taking = true);
    final photo = await widget.takePhoto();
    if (!mounted) return;
    setState(() {
      _taking = false;
      if (photo != null) _photo = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = punchLabel(l, widget.type);
    return AlertDialog(
      key: const Key('confirmPunchDialog'),
      icon: Icon(widget.icon),
      title: Text(l.confirmPunchTitle(label)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OfficialClock(clock: widget.clock),
            if (_asksPhoto) ...[
              const SizedBox(height: 16),
              if (_photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _photo!,
                    key: const Key('punchPhotoPreview'),
                    height: 180,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                )
              else
                Text(
                  widget.photoMode == 'required'
                      ? l.punchPhotoRequired
                      : l.punchPhotoMissing,
                  key: const Key('punchPhotoMissing'),
                  style: TextStyle(color: scheme.error),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('retakePhoto'),
                onPressed: _taking ? null : _retake,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(_photo == null ? l.takePhoto : l.retakePhoto),
              ),
              const SizedBox(height: 8),
              Text(
                l.punchPhotoNote,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancelPunch'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('confirmPunch'),
          onPressed: _taking || _blocked
              ? null
              : () => Navigator.of(context).pop(_PunchDecision(_photo)),
          child: Text(l.confirmPunch),
        ),
      ],
    );
  }
}
