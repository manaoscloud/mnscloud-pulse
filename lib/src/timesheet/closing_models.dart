import 'timesheet_labels.dart';

/// Closed month of the employee as the API reports it (results only; the client never computes).
class TimesheetClosing {
  const TimesheetClosing(this.json);
  final Map<String, dynamic> json;

  String get uuid => json['ClosingUUID']?.toString() ?? '';
  String get monthKey => json['MonthKey']?.toString() ?? '';
  String get closedAt => json['ClosedAt']?.toString() ?? '';
  String get overtimeMode => json['OvertimeMode']?.toString() ?? 'payment';
  bool get isBank => overtimeMode == 'bank';
  bool get acknowledged =>
      json['Acknowledged'] == true || json['Acknowledged'] == 1;
  String get acknowledgedAt => json['AcknowledgedAt']?.toString() ?? '';
  int minutes(String field) => minutesOf(json[field]);

  static List<TimesheetClosing> parseAll(List<Map<String, dynamic>> items) => [
    for (final item in items)
      if ((item['ClosingUUID']?.toString() ?? '').isNotEmpty)
        TimesheetClosing(item),
  ];
}

/// Closing of [monthKey] (`YYYY-MM`) among [closings], or null.
TimesheetClosing? closingOfMonth(
  List<TimesheetClosing> closings,
  String monthKey,
) {
  for (final c in closings) {
    if (c.monthKey == monthKey) return c;
  }
  return null;
}

/// Closed months waiting for the employee's acknowledgement, oldest first.
List<TimesheetClosing> pendingClosings(List<TimesheetClosing> closings) => [
  for (final c in closings)
    if (!c.acknowledged) c,
]..sort((a, b) => a.monthKey.compareTo(b.monthKey));

/// Entry of the hour bank ledger.
class HourBankEntry {
  const HourBankEntry(this.json);
  final Map<String, dynamic> json;
  String get kind => json['Kind']?.toString() ?? '';
  String get monthKey => json['MonthKey']?.toString() ?? '';
  int get minutes => minutesOf(json['Minutes']);
  String get expiresOn => json['ExpiresOn']?.toString() ?? '';
}

/// Hour bank of the employee. [enabled] only in `bank` mode (hidden in `payment` mode).
class HourBank {
  const HourBank(this.json);
  final Map<String, dynamic> json;
  bool get enabled => json['OvertimeMode']?.toString() == 'bank';
  int get balance => minutesOf(json['BalanceMinutes']);
  String get nextExpiresOn => json['NextExpiresOn']?.toString() ?? '';
  List<HourBankEntry> get entries => [
    for (final e in (json['Entries'] as List?) ?? const [])
      if (e is Map<String, dynamic>) HourBankEntry(e),
  ];
}

/// ISO instant as local `DD/MM/YYYY HH:MM`; unreadable values show a dash.
String dateTimeText(String iso) {
  final at = DateTime.tryParse(iso)?.toLocal();
  if (at == null) return '—';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(at.day)}/${two(at.month)}/${at.year} ${two(at.hour)}:${two(at.minute)}';
}

/// `YYYY-MM` as `MM/YYYY`.
String monthText(String monthKey) {
  final m = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(monthKey);
  return m == null ? monthKey : '${m[2]}/${m[1]}';
}
