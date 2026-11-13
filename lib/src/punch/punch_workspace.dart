import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/employment_choice.dart';
import '../core/ids.dart';
import '../core/location.dart';
import '../core/punch_camera.dart';
import '../core/pulse_api.dart';
import '../core/punch_queue.dart';
import '../core/server_clock.dart';
import '../offline/punch_sync.dart';
import '../timesheet/today_card.dart';
import 'punch_labels.dart';
import '../receipt/receipt.dart';

/// Receipts are listed for this long after the mark.
const receiptWindow = Duration(hours: 48);

/// Marks with a receipt (NSR) recorded in the last 48 h before [now], newest first.
List<Map<String, dynamic>> receiptsOfLast48h(
  List<Map<String, dynamic>> punches,
  DateTime now,
) {
  final since = now.subtract(receiptWindow);
  final kept = <(DateTime, Map<String, dynamic>)>[];
  for (final punch in punches) {
    final at = DateTime.tryParse(punch['OccurredAt']?.toString() ?? '');
    if (punch['NSR'] != null && at != null && !at.isBefore(since)) {
      kept.add((at, punch));
    }
  }
  kept.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, punch) in kept) punch];
}

/// The API flagged the mark as taken outside the geofence of its location.
bool isOutsideGeofence(Map<String, dynamic> punch) =>
    punch['OutsideGeofence'] == true ||
    punch['OutsideGeofence'] == 1 ||
    ((punch['Flags'] as List?)?.contains('outside_geofence') ?? false);

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

  /// Marks with receipt (NSR) of the last 48 hours, newest first.
  List<Map<String, dynamic>> _receipts = [];
  List<QueuedPunch> _pending = [];
  bool _online = true;
  bool _busy = false;
  bool _flushing = false;
  bool _showOthers = false;
  bool _confirming = false;
  bool _noLocation = false;
  String? _message;
  bool _messageError = false;
  Timer? _retry;

  /// Employment of the next mark; chosen by the employee when there are several.
  String? _employmentUUID;

  /// Bumped when a mark reaches the API, so the today summary reads the new state.
  final _delivered = ValueNotifier<int>(0);

  AppLocalizations get l => AppLocalizations.of(context)!;
  String get _source => kIsWeb ? 'web' : 'mobile';

  @override
  void initState() {
    super.initState();
    widget.sync.addListener(_synced);
    _employmentUUID = EmploymentChoice.resolve(
      widget.account.employments,
      null,
    );
    unawaited(_loadEmployment());
    unawaited(_start());
  }

  @override
  void dispose() {
    widget.sync.removeListener(_synced);
    _retry?.cancel();
    _delivered.dispose();
    super.dispose();
  }

  Future<void> _loadEmployment() async {
    final employments = widget.account.employments;
    if (employments.length < 2) return;
    final saved = await EmploymentChoice.read(
      widget.account.timeClockAccountUUID,
    );
    if (!mounted) return;
    setState(
      () => _employmentUUID = EmploymentChoice.resolve(employments, saved),
    );
  }

  void _chooseEmployment(String uuid) {
    setState(() {
      _employmentUUID = uuid;
      if (_message == 'employmentRequired' || _message == 'employmentInvalid') {
        _message = null;
      }
    });
    unawaited(
      EmploymentChoice.write(widget.account.timeClockAccountUUID, uuid),
    );
  }

  Future<void> _start() async {
    final serverTime = await widget.api.serverTime();
    if (serverTime != null) widget.clock.accept(serverTime);
    _pending = await _queue.load();
    await _flush();
    await _reload();
  }

  void _scheduleRetry({bool force = false}) {
    _retry?.cancel();
    if ((_pending.isEmpty && !force) || !mounted) return;
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
      var receipts = _receipts;
      try {
        receipts = receiptsOfLast48h(
          await widget.api.listPunches(
            limit: 200,
            startAt: widget.clock.nowUtc().subtract(receiptWindow),
          ),
          widget.clock.nowUtc(),
        );
      } on PulseFailure catch (failure) {
        if (failure.sessionEnded) rethrow;
        // The recent list is enough; the receipts are read again at the next refresh.
      }
      if (!mounted) return;
      setState(() {
        _punches = items;
        _receipts = receipts;
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
      _noLocation = false;
      _showOthers = false;
    });
    final occurredAt = widget.clock.nowUtc();
    PunchLocation? location;
    try {
      location = await (widget.locate ?? punchLocator)();
    } catch (_) {
      location = null;
    }
    // A mark is never restricted for lack of location (Portaria MTP 671, art. 74): it is
    // recorded without it and HR sees it flagged.
    final punch = QueuedPunch(
      idempotencyKey: uuidV4(),
      type: type,
      occurredAt: occurredAt,
      latitude: location?.latitude,
      longitude: location?.longitude,
      accuracyMeters: location?.accuracyMeters,
      employmentUUID: _employmentUUID,
    );
    // Kept on the device before sending: a lost answer or no connection never loses the mark.
    await _queue.add(punch);
    final photoUUID = uuidV4();
    // The photo is kept as well until the API accepts it: it goes later when there is no
    // connection (the API takes it for 24 h after the mark).
    if (photo != null) {
      await _queue.addPhoto(punch.idempotencyKey, photoUUID, photo);
    }
    if (mounted) setState(() => _noLocation = location == null);
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
      final punchUUID = item['TimePunchUUID']?.toString();
      final linked = punchUUID != null && punchUUID.isNotEmpty;
      // Bound before the mark leaves the queue, so the photo is never seen as orphaned.
      if (linked) {
        await _queue.bindPhoto(punch.idempotencyKey, punchUUID);
      } else {
        await _queue.removePhoto(punch.idempotencyKey);
      }
      await _queue.remove(punch.idempotencyKey);
      if (item['Duplicate'] == 1) message = 'punchSynced';
      _online = true;
      _delivered.value++;
      if (photo != null && linked) {
        message = await _sendPhoto(
          punch.idempotencyKey,
          punchUUID,
          photoUUID,
          photo,
        );
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
      } else if (failure.code == 'PULSE_EMPLOYMENT_REQUIRED' ||
          failure.code == 'PULSE_EMPLOYMENT_INVALID') {
        // Nothing was recorded: the employee chooses the employment and punches again.
        await _queue.remove(punch.idempotencyKey);
        await _queue.removePhoto(punch.idempotencyKey);
        message = failure.code == 'PULSE_EMPLOYMENT_REQUIRED'
            ? 'employmentRequired'
            : 'employmentInvalid';
        error = true;
      } else {
        await _queue.remove(punch.idempotencyKey);
        await _queue.removePhoto(punch.idempotencyKey);
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

  /// The mark is already recorded: a photo that does not go for lack of connection stays on the
  /// device and is sent by the next pass; one refused for good is dropped and reported.
  Future<String> _sendPhoto(
    String punchKey,
    String punchUUID,
    String photoUUID,
    Uint8List photo,
  ) async {
    try {
      await widget.api.uploadPunchPhoto(punchUUID, photoUUID, photo);
      await _queue.removePhoto(punchKey);
      return 'punchPhotoSaved';
    } on PulseFailure catch (failure) {
      if (photoAlreadyStored(failure)) {
        await _queue.removePhoto(punchKey);
        return 'punchPhotoSaved';
      }
      if (failure.sessionEnded) {
        // Kept: the device grant or the next session sends it.
        widget.onSessionEnded(failure.code);
        return 'punchPhotoOffline';
      }
      if (photoUploadRetry(failure)) {
        _scheduleRetry(force: true);
        return 'punchPhotoOffline';
      }
      await _queue.removePhoto(punchKey);
      return 'punchPhotoFailed';
    } catch (_) {
      return 'punchPhotoFailed';
    }
  }

  String _text(String key) => switch (key) {
    'punchSaved' => l.punchSaved,
    'punchPhotoSaved' => l.punchPhotoSaved,
    'punchPhotoFailed' => l.punchPhotoFailed,
    'punchPhotoOffline' => l.punchPhotoOffline,
    'punchSynced' => l.punchSynced,
    'punchQueued' => l.punchQueued,
    'rateLimited' => l.rateLimited,
    'employmentRequired' => l.employmentRequired,
    'employmentInvalid' => l.employmentInvalid,
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
            if (widget.account.employments.length == 1)
              widget.account.employments.first.label(
                l.employmentRegistrationShort,
              )
            else
              widget.account.companyName,
            if (widget.account.employments.length != 1 &&
                widget.account.hrAccountName != widget.account.companyName)
              widget.account.hrAccountName,
            widget.account.loginCode,
          ].whereType<String>().where((part) => part.isNotEmpty).join(' · '),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        if (widget.account.employments.length > 1) ...[
          const SizedBox(height: 12),
          EmploymentSelector(
            key: const Key('punchEmployment'),
            employments: widget.account.employments,
            selected: _employmentUUID,
            enabled: !_busy,
            onChanged: _chooseEmployment,
          ),
        ],
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
        if (_noLocation)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l.punchNoLocationNotice,
                key: const Key('punchNoLocationNotice'),
                style: TextStyle(color: scheme.tertiary),
              ),
            ),
          ),
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
        const SizedBox(height: 20),
        Text(l.receiptsLast48h, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_receipts.isEmpty)
          Text(
            l.receiptsLast48hEmpty,
            key: const Key('receiptsEmpty'),
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        for (final punch in _receipts)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              key: Key('receiptTile-${punch['NSR']}'),
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(punchLabel(l, punch['Type']?.toString() ?? '')),
              subtitle: Text(_whenText(context, punch['OccurredAt'])),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.nsrLabel(punch['NSR'].toString())),
                  if (isOutsideGeofence(punch))
                    Text(
                      l.outsideGeofence,
                      key: Key('outsideGeofence-${punch['NSR']}'),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.error),
                    ),
                ],
              ),
              onTap:
                  widget.api.signedIn &&
                      (punch['TimePunchUUID']?.toString() ?? '').isNotEmpty
                  ? () => _openReceipt(punch['TimePunchUUID'].toString())
                  : null,
            ),
          ),
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
                if (isOutsideGeofence(punch)) l.outsideGeofence,
              ].join('\n'),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _openReceipt(String punchUUID) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ReceiptSheet(
      load: () async =>
          PunchReceipt.fromJson(await widget.api.receipt(punchUUID)),
      email: () => widget.api.emailReceipt(punchUUID),
    ),
  );

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
