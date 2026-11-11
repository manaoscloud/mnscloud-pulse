import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../brand/brand.dart';
import '../core/ids.dart';
import '../core/location.dart';
import '../core/punch_camera.dart';
import '../core/pulse_api.dart';
import '../core/server_clock.dart';
import '../punch/punch_labels.dart';
import '../receipt/receipt.dart';
import 'fullscreen.dart';
import 'kiosk_client.dart';

const kioskPunchTypes = ['clock_in', 'break_start', 'break_end', 'clock_out'];

IconData kioskPunchIcon(String type) => switch (type) {
  'clock_in' => Icons.login,
  'break_start' => Icons.coffee_outlined,
  'break_end' => Icons.work_outline,
  'clock_out' => Icons.logout,
  _ => Icons.schedule,
};

enum _Step { code, pin, confirm, done }

/// The company time clock: many employees punch on this device with their access code, their
/// personal PIN and a live photo. Nothing of an employee stays on screen after the mark.
class KioskShell extends StatefulWidget {
  const KioskShell({
    super.key,
    required this.client,
    required this.profile,
    required this.onExit,
    this.checkEvery = const Duration(minutes: 5),
    this.idleAfter = const Duration(seconds: 45),
    this.doneAfter = const Duration(seconds: 10),
  });

  final KioskClient client;
  final KioskProfile profile;

  /// Called after the administrator PIN, once the key was forgotten.
  final VoidCallback onExit;
  final Duration checkEvery;
  final Duration idleAfter;
  final Duration doneAfter;

  @override
  State<KioskShell> createState() => _KioskShellState();
}

class _KioskShellState extends State<KioskShell> {
  late KioskProfile _profile = widget.profile;
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  String _pin = '';
  _Step _step = _Step.code;
  KioskEmployee? _employee;
  String? _type;
  Map<String, dynamic>? _receipt;
  bool _photoFailed = false;
  bool _busy = false;
  bool _revoked = false;
  bool _offline = false;
  String? _message;
  Timer? _check;
  Timer? _idle;
  Timer? _done;
  int _doneLeft = 0;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
    _check = Timer.periodic(widget.checkEvery, (_) => unawaited(_refresh()));
  }

  @override
  void dispose() {
    _check?.cancel();
    _idle?.cancel();
    _done?.cancel();
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  /// Profile and official time; a kiosk revoked by HR stops at once.
  Future<void> _refresh() async {
    try {
      final profile = await widget.client.me();
      if (!mounted) return;
      setState(() {
        if (profile.kioskUUID.isNotEmpty) _profile = profile;
        _offline = false;
      });
    } on PulseFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        if (failure.code == 'networkError') {
          _offline = true;
        } else if (failure.code.startsWith('PULSE_KIOSK_') ||
            failure.code == 'PULSE_MODULE_UNAVAILABLE') {
          _revoked = true;
        }
      });
    }
  }

  void _touch() {
    _idle?.cancel();
    if (_step == _Step.pin || _step == _Step.confirm) {
      _idle = Timer(widget.idleAfter, _reset);
    }
  }

  void _reset() {
    _idle?.cancel();
    _done?.cancel();
    if (!mounted) return;
    setState(() {
      _step = _Step.code;
      _pin = '';
      _employee = null;
      _type = null;
      _receipt = null;
      _photoFailed = false;
      _busy = false;
      _codeController.clear();
    });
    _codeFocus.requestFocus();
  }

  String _failure(PulseFailure failure) => switch (failure.code) {
    'PULSE_KIOSK_INVALID_PIN' => l.kioskInvalidPin,
    'PULSE_KIOSK_PIN_LOCKED' => l.kioskPinLocked,
    'PULSE_KIOSK_PIN_NOT_SET' => l.kioskPinNotSet,
    'PULSE_ACCESS_DENIED' => l.accessDenied,
    'PULSE_RATE_LIMITED' => l.rateLimited,
    'PULSE_MODULE_UNAVAILABLE' => l.moduleUnavailable,
    'networkError' => l.kioskOffline,
    _ => l.requestError,
  };

  void _fail(PulseFailure failure) {
    if (!mounted) return;
    if (failure.code.startsWith('PULSE_KIOSK_') &&
        !{
          'PULSE_KIOSK_INVALID_PIN',
          'PULSE_KIOSK_PIN_LOCKED',
          'PULSE_KIOSK_PIN_NOT_SET',
        }.contains(failure.code)) {
      setState(() => _revoked = true);
      return;
    }
    setState(() {
      _busy = false;
      _offline = failure.code == 'networkError';
      _message = _failure(failure);
      if (failure.code != 'networkError') {
        _step = _Step.code;
        _pin = '';
        _employee = null;
        _codeController.clear();
      }
    });
  }

  void _codeEntered() {
    if (_codeController.text.trim().isEmpty) return;
    setState(() {
      _message = null;
      _step = _Step.pin;
      _pin = '';
    });
    _touch();
  }

  void _digit(String digit) {
    if (_pin.length >= 6) return;
    setState(() => _pin += digit);
    _touch();
  }

  Future<void> _identify() async {
    if (_busy || _pin.length < 4) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final employee = await widget.client.identify(
        _codeController.text.trim(),
        _pin,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offline = false;
        _employee = employee;
        _type = employee.nextPunchType;
        _step = _Step.confirm;
      });
      _touch();
    } on PulseFailure catch (failure) {
      _fail(failure);
    }
  }

  Future<void> _record() async {
    final type = _type;
    if (_busy || type == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    _idle?.cancel();
    Uint8List? photo;
    if (_profile.photoRequired) {
      try {
        photo = await punchPhotoCapture(context);
      } catch (_) {
        photo = null;
      }
      if (photo == null) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _message = l.kioskPhotoRequired;
        });
        _touch();
        return;
      }
    }
    final location = await punchLocator();
    if (location == null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = l.locationRequired;
      });
      _touch();
      return;
    }
    try {
      final result = await widget.client.punch(
        loginCode: _codeController.text.trim(),
        pin: _pin,
        idempotencyKey: uuidV4(),
        type: type,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters: location.accuracyMeters,
      );
      var photoFailed = false;
      final punchUUID = result.punch['TimePunchUUID']?.toString();
      if (photo != null && punchUUID != null && punchUUID.isNotEmpty) {
        try {
          await widget.client.uploadPhoto(punchUUID, uuidV4(), photo);
        } catch (_) {
          photoFailed = true;
        }
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offline = false;
        _receipt = result.punch;
        _photoFailed = photoFailed;
        _pin = '';
        _step = _Step.done;
        _doneLeft = widget.doneAfter.inSeconds;
      });
      _done?.cancel();
      _done = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        if (_doneLeft <= 1) {
          timer.cancel();
          _reset();
        } else {
          setState(() => _doneLeft--);
        }
      });
    } on PulseFailure catch (failure) {
      _fail(failure);
    }
  }

  Future<void> _exit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ExitDialog(client: widget.client),
    );
    if (ok != true) return;
    await widget.client.forget();
    widget.onExit();
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile.name,
                key: const Key('kioskName'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((_profile.companyName ?? _profile.hrAccountName) != null)
                Text(
                  _profile.companyName ?? _profile.hrAccountName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (_offline)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.cloud_off, color: theme.colorScheme.error),
          ),
        if (kIsWeb && fullscreenAvailable)
          IconButton(
            tooltip: l.kioskFullscreen,
            onPressed: requestFullscreen,
            icon: const Icon(Icons.fullscreen),
          ),
        IconButton(
          key: const Key('kioskExit'),
          tooltip: l.kioskExit,
          onPressed: _exit,
          icon: const Icon(Icons.lock_outline),
        ),
      ],
    );
  }

  Widget _clock(BuildContext context) =>
      _KioskClock(clock: widget.client.clock);

  Widget _codeStep(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(l.kioskEnterCode, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      TextField(
        key: const Key('kioskLoginCode'),
        controller: _codeController,
        focusNode: _codeFocus,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        enableSuggestions: false,
        style: const TextStyle(fontSize: 28, letterSpacing: 4),
        textAlign: TextAlign.center,
        decoration: InputDecoration(labelText: l.employeeCode),
        onSubmitted: (_) => _codeEntered(),
      ),
      const SizedBox(height: 16),
      FilledButton(
        key: const Key('kioskCodeContinue'),
        onPressed: _codeEntered,
        child: Text(l.kioskContinue),
      ),
    ],
  );

  Widget _pinStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget key(String label, VoidCallback? onTap, {Key? k, IconData? icon}) =>
        Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 64,
            child: OutlinedButton(
              key: k,
              onPressed: _busy ? null : onTap,
              child: icon != null
                  ? Icon(icon)
                  : Text(label, style: const TextStyle(fontSize: 26)),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.kioskEnterPin, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          List.filled(_pin.length, '●').join(' ').padRight(1),
          key: const Key('kioskPinDots'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            color: scheme.primary,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            children: [
              for (final d in row)
                Expanded(
                  child: key(d, () => _digit(d), k: Key('kioskDigit$d')),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: key(
                '',
                () => setState(
                  () => _pin = _pin.isEmpty
                      ? ''
                      : _pin.substring(0, _pin.length - 1),
                ),
                icon: Icons.backspace_outlined,
              ),
            ),
            Expanded(
              child: key('0', () => _digit('0'), k: const Key('kioskDigit0')),
            ),
            Expanded(
              child: key(
                '',
                _pin.length >= 4 ? _identify : null,
                k: const Key('kioskPinOk'),
                icon: Icons.check,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _busy ? null : _reset, child: Text(l.cancel)),
      ],
    );
  }

  Widget _confirmStep(BuildContext context) {
    final employee = _employee!;
    final theme = Theme.of(context);
    final suggested = employee.nextPunchType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.kioskHello(employee.employeeName),
          key: const Key('kioskHello'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (employee.companyName != null)
          Text(employee.companyName!, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Text(l.kioskSuggested, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in [
              suggested,
              ...kioskPunchTypes.where((t) => t != suggested),
            ])
              ChoiceChip(
                key: Key('kioskType-$type'),
                avatar: Icon(kioskPunchIcon(type), size: 18),
                label: Text(punchLabel(l, type)),
                selected: _type == type,
                onSelected: _busy
                    ? null
                    : (_) {
                        setState(() => _type = type);
                        _touch();
                      },
              ),
          ],
        ),
        if (_profile.photoRequired) ...[
          const SizedBox(height: 12),
          Text(
            l.kioskPhotoNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('kioskRecord'),
          onPressed: _busy ? null : _record,
          icon: Icon(_profile.photoRequired ? Icons.photo_camera : Icons.check),
          label: Text(l.kioskConfirmPunch),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _busy ? null : _reset, child: Text(l.cancel)),
      ],
    );
  }

  String _time(Object? value) {
    final at = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (at == null) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    final material = MaterialLocalizations.of(context);
    return '${material.formatShortDate(at)} ${two(at.hour)}:${two(at.minute)}:${two(at.second)}';
  }

  Widget _doneStep(BuildContext context) {
    final theme = Theme.of(context);
    final receipt = _receipt ?? const {};
    final hash = receipt['Hash']?.toString() ?? '';
    final type = receipt['Type']?.toString() ?? _type ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          _photoFailed ? l.kioskPhotoFailed : l.kioskPunchSaved,
          key: const Key('kioskSaved'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _employee?.employeeName ?? '',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${punchLabel(l, type)} · ${_time(receipt['OccurredAt'])}',
                ),
                Text(l.nsrLabel(receipt['NSR']?.toString() ?? '—')),
                if (hash.isNotEmpty)
                  Text(
                    '${hash.substring(0, hash.length < 16 ? hash.length : 16)}…',
                    style: theme.textTheme.bodySmall,
                  ),
                Text(_profile.name, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if ((receipt['TimePunchUUID']?.toString() ?? '').isNotEmpty)
          ReceiptActions(
            load: () async => PunchReceipt.fromJson(
              await widget.client.receipt(receipt['TimePunchUUID'].toString()),
            ),
            email: () =>
                widget.client.emailReceipt(receipt['TimePunchUUID'].toString()),
            emailVisible:
                _profile.emailReceipt && (_employee?.hasEmail ?? false),
            onActivity: () =>
                setState(() => _doneLeft = widget.doneAfter.inSeconds * 3),
          ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('kioskDone'),
          onPressed: _reset,
          child: Text(l.kioskDone),
        ),
        const SizedBox(height: 8),
        Text(
          l.kioskReturning(_doneLeft),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_revoked) {
      return Scaffold(
        key: const Key('kioskRevoked'),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.block, size: 56, color: scheme.error),
                    const SizedBox(height: 12),
                    Text(l.kioskRevoked, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      key: const Key('kioskExit'),
                      onPressed: _exit,
                      icon: const Icon(Icons.lock_outline),
                      label: Text(l.kioskExit),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final step = switch (_step) {
      _Step.code => _codeStep(context),
      _Step.pin => _pinStep(context),
      _Step.confirm => _confirmStep(context),
      _Step.done => _doneStep(context),
    };
    return Scaffold(
      key: const Key('kioskShell'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _header(context),
                const SizedBox(height: 16),
                _clock(context),
                const SizedBox(height: 24),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _message!,
                        key: const Key('kioskMessage'),
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ),
                if (_busy) const LinearProgressIndicator(),
                const SizedBox(height: 8),
                step,
                const SizedBox(height: 24),
                Text(
                  pulseBrand.value?.title ?? 'MNSCloud Pulse',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// hh:mm:ss of the official clock, ticking on its own.
class _KioskClock extends StatefulWidget {
  const _KioskClock({required this.clock});
  final ServerClock clock;

  @override
  State<_KioskClock> createState() => _KioskClockState();
}

class _KioskClockState extends State<_KioskClock> {
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
    final material = MaterialLocalizations.of(context);
    return Column(
      children: [
        Text(l.officialTime, style: Theme.of(context).textTheme.labelLarge),
        Text(
          '${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
          key: const Key('kioskClock'),
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        Text(material.formatFullDate(now)),
      ],
    );
  }
}

/// Administrator PIN that unlocks leaving the time clock mode (checked on the device only).
class _ExitDialog extends StatefulWidget {
  const _ExitDialog({required this.client});
  final KioskClient client;

  @override
  State<_ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<_ExitDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final ok = await widget.client.checkAdminPin(_controller.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = AppLocalizations.of(context)!.kioskExitWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.kioskExit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.kioskExitHelp),
          const SizedBox(height: 12),
          TextField(
            key: const Key('kioskExitPin'),
            controller: _controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l.kioskAdminPin,
              errorText: _error,
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('kioskExitConfirm'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _confirm,
          child: Text(l.kioskExit),
        ),
      ],
    );
  }
}
