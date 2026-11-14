import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import 'closing_models.dart';
import 'timesheet_labels.dart';

/// Summary of a closed month and its acknowledgement (ciência). [onAcknowledge] is null while a
/// request is running; the action always needs the network.
class ClosingCard extends StatelessWidget {
  const ClosingCard({
    super.key,
    required this.closing,
    required this.onAcknowledge,
  });
  final TimesheetClosing closing;
  final VoidCallback? onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    Widget stat(String key, String label, String value, [Color? color]) =>
        SizedBox(
          width: 104,
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
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        );
    final bank = closing.isBank;
    return Card(
      key: const Key('closingCard'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l.closingTitle} · ${monthText(closing.monthKey)}',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Text(
              l.closingClosedAt(dateTimeText(closing.closedAt)),
              key: const Key('closingClosedAt'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                stat(
                  'closingWorked',
                  l.closingWorked,
                  formatMinutes(closing.minutes('WorkedMinutes')),
                ),
                stat(
                  'closingOvertime50',
                  l.closingOvertime50,
                  formatMinutes(closing.minutes('OvertimeMinutes')),
                ),
                stat(
                  'closingOvertime100',
                  l.closingOvertime100,
                  formatMinutes(closing.minutes('OvertimeRestMinutes')),
                ),
                stat(
                  'closingAbsences',
                  l.closingAbsences,
                  closing.minutes('AbsenceDays').toString(),
                ),
                stat(
                  'closingDsrLost',
                  l.closingDsrLost,
                  closing.minutes('DsrLostDays').toString(),
                ),
                if (bank) ...[
                  stat(
                    'closingBankCredit',
                    l.bankCredit,
                    formatMinutes(closing.minutes('BankCreditMinutes')),
                  ),
                  stat(
                    'closingBankDebit',
                    l.bankDebit,
                    formatMinutes(closing.minutes('BankDebitMinutes')),
                  ),
                  stat(
                    'closingBankPaid',
                    l.bankPaid,
                    formatMinutes(closing.minutes('BankPaidMinutes')),
                  ),
                  stat(
                    'closingBankBalance',
                    l.bankBalance,
                    formatMinutes(
                      closing.minutes('BankBalanceMinutes'),
                      signed: true,
                    ),
                    balanceColor(scheme, closing.minutes('BankBalanceMinutes')),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (closing.acknowledged)
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.closingAcked(dateTimeText(closing.acknowledgedAt)),
                      key: const Key('closingAcked'),
                    ),
                  ),
                ],
              )
            else ...[
              Text(
                l.closingAwaiting,
                key: const Key('closingAwaiting'),
                style: TextStyle(color: scheme.tertiary),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('closingAckButton'),
                onPressed: onAcknowledge,
                child: Text(l.closingAck),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hour bank of the employee: balance, next expiry and the latest ledger entries.
class HourBankCard extends StatelessWidget {
  const HourBankCard({super.key, required this.bank});
  final HourBank bank;

  static String kindLabel(AppLocalizations l, String kind) => switch (kind) {
    'credit' => l.bankKindCredit,
    'debit' => l.bankKindDebit,
    'expire_paid' => l.bankKindExpirePaid,
    'manual_paid' => l.bankKindManualPaid,
    _ => kind,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final entries = bank.entries.take(5).toList();
    return Card(
      key: const Key('hourBankCard'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l.bankTitle,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l.bankBalance}: ${formatMinutes(bank.balance, signed: true)}',
              key: const Key('hourBankBalance'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: balanceColor(scheme, bank.balance),
              ),
            ),
            if (bank.nextExpiresOn.isNotEmpty)
              Text(
                '${l.bankExpires} ${dateOnly(bank.nextExpiresOn)}',
                key: const Key('hourBankExpires'),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 8),
            Text(
              l.bankEntries,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (entries.isEmpty)
              Text(l.bankNoEntries, key: const Key('hourBankEmpty')),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${monthText(e.monthKey)} · ${kindLabel(l, e.kind)}',
                      ),
                    ),
                    Text(
                      formatMinutes(
                        e.kind == 'credit' ? e.minutes : -e.minutes.abs(),
                        signed: true,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `YYYY-MM-DD...` as `DD/MM/YYYY`.
String dateOnly(String value) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  return m == null ? value : '${m[3]}/${m[2]}/${m[1]}';
}

/// Notice on the main screen: closed months waiting for the employee's acknowledgement.
class ClosingNotice extends StatelessWidget {
  const ClosingNotice({super.key, required this.pending, required this.onOpen});
  final List<TimesheetClosing> pending;
  final void Function(String monthKey) onOpen;

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('closingNotice'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onOpen(pending.first.monthKey),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.lock_clock, color: scheme.onTertiaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.closingNotice(pending.length),
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                ),
                Text(
                  l.closingNoticeOpen,
                  style: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loads the closed months and shows [ClosingNotice] for those not yet acknowledged. It reads again
/// when the tab becomes visible or [refresh] notifies (after an acknowledgement). A failure (offline,
/// older API) shows nothing: the notice is never cached or queued.
class ClosingNoticeHost extends StatefulWidget {
  const ClosingNoticeHost({
    super.key,
    required this.api,
    required this.refresh,
    required this.onOpen,
    required this.onSessionEnded,
  });
  final PulseApi api;
  final Listenable refresh;
  final void Function(String monthKey) onOpen;
  final void Function(String code) onSessionEnded;

  @override
  State<ClosingNoticeHost> createState() => _ClosingNoticeHostState();
}

class _ClosingNoticeHostState extends State<ClosingNoticeHost> {
  List<TimesheetClosing> _pending = const [];
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.refresh.addListener(_load);
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_load);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) Future.microtask(_load);
    _visible = visible;
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final items = await widget.api.listTimesheetClosings();
      if (!mounted) return;
      setState(
        () => _pending = pendingClosings(TimesheetClosing.parseAll(items)),
      );
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) widget.onSessionEnded(failure.code);
    }
  }

  @override
  Widget build(BuildContext context) =>
      ClosingNotice(pending: _pending, onOpen: widget.onOpen);
}
