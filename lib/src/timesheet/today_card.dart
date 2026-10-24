import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import 'timesheet_labels.dart';

/// Compact summary of today: expected shift, worked time (live while working) and the current
/// state. It is a convenience only: any failure hides it and punching never depends on it.
class TodayCard extends StatefulWidget {
  const TodayCard({super.key, required this.api, required this.reload});

  final PulseApi api;

  /// Notified after a mark reaches the API (online or from the offline queue).
  final Listenable reload;

  @override
  State<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard> with WidgetsBindingObserver {
  Map<String, dynamic>? _today;

  /// Minutes ticked locally since the last answer (added while working).
  int _elapsed = 0;
  bool _visible = true;
  bool _loading = false;
  bool _again = false;
  Timer? _refresh;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.reload.addListener(_load);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setVisible(TickerMode.valuesOf(context).enabled && _appVisible);
  }

  @override
  void didUpdateWidget(TodayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reload != widget.reload) {
      oldWidget.reload.removeListener(_load);
      widget.reload.addListener(_load);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _setVisible(TickerMode.valuesOf(context).enabled && _appVisible);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.reload.removeListener(_load);
    _refresh?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  bool get _appVisible {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  /// Refreshes on open and every 60 s while visible; the worked time ticks every minute.
  void _setVisible(bool visible) {
    if (visible == _visible && (_refresh != null || !visible)) return;
    _visible = visible;
    _refresh?.cancel();
    _tick?.cancel();
    _refresh = null;
    _tick = null;
    if (!visible) return;
    unawaited(_load());
    _refresh = Timer.periodic(const Duration(seconds: 60), (_) => _load());
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _today?['working'] == true) setState(() => _elapsed++);
    });
  }

  Future<void> _load() async {
    if (_loading) {
      // A mark landed while a read was in flight: read once more afterwards.
      _again = true;
      return;
    }
    _loading = true;
    try {
      final today = await widget.api.today();
      if (!mounted) return;
      setState(() {
        _today = today;
        _elapsed = 0;
      });
    } on PulseFailure catch (failure) {
      // Without connection the last answer keeps ticking; any other failure (an older API, an
      // ended session handled by the punch workspace) hides the card.
      if (mounted && failure.code != 'networkError') {
        setState(() => _today = null);
      }
    } catch (_) {
      if (mounted) setState(() => _today = null);
    } finally {
      _loading = false;
      if (_again && mounted) {
        _again = false;
        unawaited(_load());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    if (today == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final working = today['working'] == true;
    final day = today['day'] is Map<String, dynamic>
        ? today['day'] as Map<String, dynamic>
        : null;
    final expected = today['expected'] is Map<String, dynamic>
        ? today['expected'] as Map<String, dynamic>
        : null;
    final punches = (today['punches'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .toList();
    final lastType = punches == null || punches.isEmpty
        ? null
        : punches.last['Type']?.toString();
    var worked = minutesOf(today['workedMinutes']);
    if (working) worked += _elapsed;
    final (status, icon, color) = working
        ? (l.statusWorking, Icons.work_outline, scheme.primary)
        : lastType == 'break_start'
        ? (l.statusOnBreak, Icons.coffee_outlined, scheme.tertiary)
        : (l.statusOffDuty, Icons.bedtime_outlined, scheme.onSurfaceVariant);
    final shift = dayKindLabel(
      l,
      day ?? (expected == null ? null : const {'DayKind': 'work'}),
      startLocal: expected?['startLocal']?.toString(),
      endLocal: expected?['endLocal']?.toString(),
    );
    return Card(
      key: const Key('todayCard'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(l.today, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          key: const Key('todayStatus'),
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              shift,
              key: const Key('todayShift'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(l.workedToday)),
                Text(
                  formatMinutes(worked),
                  key: const Key('todayWorked'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
