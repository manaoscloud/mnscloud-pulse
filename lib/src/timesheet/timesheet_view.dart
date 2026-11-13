import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import '../core/server_clock.dart';
import '../punch/punch_labels.dart';
import '../receipt/receipt_print.dart';
import 'timesheet_labels.dart';
import 'timesheet_print.dart';

/// Monthly timesheet of the employee: totals and the consolidated days with their marks. The API
/// computes every value; the client only shows them (results, never the rules behind them).
class TimesheetView extends StatefulWidget {
  const TimesheetView({
    super.key,
    required this.api,
    required this.clock,
    required this.onSessionEnded,
    this.printer = printReceiptHtml,
    this.printAvailable,
  });

  final PulseApi api;
  final ServerClock clock;
  final void Function(String code) onSessionEnded;

  /// Opens the browser print dialog with the page (web only); tests replace it.
  final Future<void> Function(String html) printer;

  /// Overrides [receiptPrintAvailable] (tests).
  final bool? printAvailable;

  @override
  State<TimesheetView> createState() => _TimesheetViewState();
}

class _TimesheetViewState extends State<TimesheetView> {
  late DateTime _month = _currentMonth;
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = false;
  bool _visible = false;
  int _request = 0;

  AppLocalizations get l => AppLocalizations.of(context)!;

  DateTime get _currentMonth {
    final now = widget.clock.nowUtc().toLocal();
    return DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth => !_month.isBefore(_currentMonth);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read again each time the tab becomes visible, so new marks show up.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) {
      Future.microtask(() {
        if (mounted) unawaited(_load());
      });
    }
    _visible = visible;
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.timesheet(monthKey(_month));
      if (!mounted || request != _request) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) {
        widget.onSessionEnded(failure.code);
        return;
      }
      if (!mounted || request != _request) return;
      setState(() {
        _error = failure.code;
        _loading = false;
      });
    }
  }

  Future<void> _print() async {
    final data = _data;
    if (data == null) return;
    final language = Localizations.localeOf(context).toLanguageTag();
    await widget.printer(timesheetHtml(data, l, language: language));
  }

  void _shift(int months) {
    final next = DateTime(_month.year, _month.month + months);
    if (next.isAfter(_currentMonth)) return;
    setState(() {
      _month = next;
      _data = null;
    });
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = _data;
    // Newest first: the days an employee checks most (today, yesterday) stay on top; the month
    // header keeps the calendar context.
    final days =
        ((data?['days'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
              [])
          ..sort(
            (a, b) => (b['Date']?.toString() ?? '').compareTo(
              a['Date']?.toString() ?? '',
            ),
          );
    final unassigned = (data?['unassignedPunches'] as List?)?.length ?? 0;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _header(context),
          if (_loading && data == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    _error == 'networkError' ? l.networkError : l.requestError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.error),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: Text(l.retry)),
                ],
              ),
            ),
          if (data != null) ...[
            _HeaderCard(header: TimesheetHeader.fromJson(data['header'])),
            _Totals(
              totals: data['totals'] is Map<String, dynamic>
                  ? data['totals'] as Map<String, dynamic>
                  : const {},
            ),
            if (unassigned > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, size: 16, color: scheme.tertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l.unassignedPunches(unassigned),
                        key: const Key('unassignedPunches'),
                        style: TextStyle(color: scheme.tertiary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (days.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  l.timesheetEmpty,
                  key: const Key('timesheetEmpty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            for (final day in days) _DayTile(day: day),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final title = MaterialLocalizations.of(context).formatMonthYear(_month);
    return Row(
      children: [
        IconButton(
          key: const Key('previousMonth'),
          tooltip: l.previousMonth,
          onPressed: () => _shift(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            title,
            key: const Key('timesheetMonth'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: const Key('nextMonth'),
          tooltip: l.nextMonth,
          onPressed: _isCurrentMonth ? null : () => _shift(1),
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          key: const Key('refreshTimesheet'),
          tooltip: l.refresh,
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
        if (widget.printAvailable ?? receiptPrintAvailable)
          IconButton(
            key: const Key('printTimesheet'),
            tooltip: l.tspPrint,
            onPressed: _loading || _data == null ? null : _print,
            icon: const Icon(Icons.print_outlined),
          ),
      ],
    );
  }
}

/// Month totals: worked, expected, balance, overtime and absences.
class _Totals extends StatelessWidget {
  const _Totals({required this.totals});
  final Map<String, dynamic> totals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final balance = minutesOf(totals['BalanceMinutes']);
    final overtime =
        minutesOf(totals['OvertimeMinutes']) +
        minutesOf(totals['OvertimeRestMinutes']);
    Widget stat(String key, String label, String value, [Color? color]) =>
        SizedBox(
          width: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(
                value,
                key: Key(key),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            stat(
              'totalWorked',
              l.totalWorked,
              formatMinutes(minutesOf(totals['WorkedMinutes'])),
            ),
            stat(
              'totalExpected',
              l.totalExpected,
              formatMinutes(minutesOf(totals['ExpectedMinutes'])),
            ),
            stat(
              'totalBalance',
              l.totalBalance,
              formatMinutes(balance, signed: true),
              balanceColor(scheme, balance),
            ),
            stat('totalOvertime', l.totalOvertime, formatMinutes(overtime)),
            stat(
              'totalAbsences',
              l.totalAbsences,
              minutesOf(totals['AbsenceDays']).toString(),
            ),
          ],
        ),
      ),
    );
  }
}

/// One consolidated day: date, what the day is, the marks in order, worked time, balance and
/// short labels of anything to review.
class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});
  final Map<String, dynamic> day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final date = DateTime.tryParse(day['Date']?.toString() ?? '');
    final punches =
        (day['punches'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
        const [];
    final times = [
      for (final p in punches)
        if ((p['LocalTime']?.toString() ?? '').isNotEmpty)
          isDisregarded(p) ? 'D ${p['LocalTime']}' : p['LocalTime'].toString(),
      for (final a in adjustmentsOf(day))
        if (a.included && a.localTime.isNotEmpty) 'I ${a.localTime}',
    ];
    final treatments = adjustmentsOf(day);
    final flags = [
      for (final flag in (day['Flags'] as List?) ?? const [])
        ?flagLabel(l, flag.toString()),
    ];
    final balance = minutesOf(day['BalanceMinutes']);
    final dateText = date == null
        ? day['Date']?.toString() ?? ''
        : MaterialLocalizations.of(context).formatMediumDate(date);
    return Card(
      key: ValueKey('day-${day['Date']}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    dayKindLabel(l, day),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    times.isEmpty ? l.noPunchesDay : times.join('  ·  '),
                    style: TextStyle(
                      color: times.isEmpty ? scheme.onSurfaceVariant : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  for (final a in treatments)
                    Text(
                      '${a.marker} ${a.localTime} ${punchLabel(l, a.punchType)}'
                      '${a.reason.isEmpty ? '' : ' · ${a.reason}'}',
                      key: ValueKey(
                        'treatment-${day['Date']}-${a.marker}-${a.localTime}',
                      ),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  if (flags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final flag in flags)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                flag,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: scheme.onErrorContainer),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMinutes(minutesOf(day['WorkedMinutes'])),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  formatMinutes(balance, signed: true),
                  style: TextStyle(
                    color: balanceColor(scheme, balance),
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

/// Art. 84 header: employer, employee and admission. Left out when the API sends no header.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.header});
  final TimesheetHeader header;

  @override
  Widget build(BuildContext context) {
    if (header.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    String join(String a, String b) =>
        [a, b].where((v) => v.isNotEmpty).join(' · ');
    final lines = [
      join(header.employerName, header.employerDocument),
      join(header.employeeName, header.employeeDocument),
      join(
        header.positionName,
        header.hireDate.isEmpty
            ? ''
            : '${l.tspHireDate} ${dateText(header.hireDate)}',
      ),
    ].where((v) => v.isNotEmpty);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        key: const Key('timesheetHeader'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Text(line, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
