import '../../l10n/app_localizations.dart';
import '../punch/punch_labels.dart';
import 'timesheet_labels.dart';

/// Header of the timesheet (Portaria MTP 671/2021 art. 84): employer, employee and schedules.
/// Every field is optional: an API without the header yields an empty one.
class TimesheetHeader {
  const TimesheetHeader({
    this.employerName = '',
    this.employerDocument = '',
    this.employeeName = '',
    this.employeeDocument = '',
    this.hireDate = '',
    this.positionName = '',
    this.departmentName = '',
    this.periodFrom = '',
    this.periodTo = '',
    this.issuedAt = '',
    this.issuedAtLocal = '',
    this.timezone = '',
    this.schedules = const [],
  });

  factory TimesheetHeader.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    Map employer = map['employer'] is Map ? map['employer'] as Map : const {};
    Map employee = map['employee'] is Map ? map['employee'] as Map : const {};
    Map period = map['period'] is Map ? map['period'] as Map : const {};
    String text(Map m, String k) => m[k]?.toString() ?? '';
    return TimesheetHeader(
      employerName: text(employer, 'Name'),
      employerDocument: text(employer, 'Document'),
      employeeName: text(employee, 'Name'),
      employeeDocument: text(employee, 'Document'),
      hireDate: text(employee, 'HireDate'),
      positionName: text(employee, 'PositionName'),
      departmentName: text(employee, 'DepartmentName'),
      periodFrom: text(period, 'From'),
      periodTo: text(period, 'To'),
      issuedAt: text(map, 'IssuedAt'),
      issuedAtLocal: text(map, 'IssuedAtLocal'),
      timezone: text(map, 'Timezone'),
      schedules: [
        for (final s in (map['schedules'] as List?) ?? const [])
          if (s is Map) s.map((k, v) => MapEntry(k.toString(), v)),
      ],
    );
  }

  final String employerName;
  final String employerDocument;
  final String employeeName;
  final String employeeDocument;
  final String hireDate;
  final String positionName;
  final String departmentName;
  final String periodFrom;
  final String periodTo;
  final String issuedAt;
  final String issuedAtLocal;
  final String timezone;
  final List<Map<String, dynamic>> schedules;

  bool get isEmpty =>
      employerName.isEmpty &&
      employeeName.isEmpty &&
      schedules.isEmpty &&
      employerDocument.isEmpty;
}

/// A treatment of the day: `include` (I) or `disregard` (D).
class TimesheetAdjustment {
  const TimesheetAdjustment({
    required this.kind,
    this.punchType = '',
    this.localTime = '',
    this.reason = '',
  });

  factory TimesheetAdjustment.fromJson(Map json) => TimesheetAdjustment(
    kind: json['Kind']?.toString() ?? '',
    punchType: json['PunchType']?.toString() ?? '',
    localTime: json['LocalTime']?.toString() ?? '',
    reason: json['Reason']?.toString() ?? '',
  );

  final String kind;
  final String punchType;
  final String localTime;
  final String reason;

  bool get included => kind == 'include';
  String get marker => included ? 'I' : 'D';
}

/// Treatments of a day; absent or malformed `adjustments` (older API) yield none.
List<TimesheetAdjustment> adjustmentsOf(Map<String, dynamic> day) => [
  for (final a in (day['adjustments'] as List?) ?? const [])
    if (a is Map) TimesheetAdjustment.fromJson(a),
];

/// True when the punch was disregarded by a treatment.
bool isDisregarded(Map<String, dynamic> punch) =>
    punch['Disregarded'] == true || punch['Disregarded'] == 1;

String escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

/// YYYY-MM-DD as DD/MM/YYYY; anything else comes back unchanged.
String dateText(String value) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  return m == null ? value : '${m[3]}/${m[2]}/${m[1]}';
}

/// ISO instant as `DD/MM/YYYY HH:MM:SS UTC`; unreadable values show a dash.
String issuedText(String iso) {
  final at = DateTime.tryParse(iso)?.toUtc();
  if (at == null) return '—';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(at.day)}/${two(at.month)}/${at.year} '
      '${two(at.hour)}:${two(at.minute)}:${two(at.second)} UTC';
}

const _style = '''
@page { size: A4; margin: 10mm; }
* { box-sizing: border-box; }
body { font: 10px/1.35 Arial, Helvetica, sans-serif; color: #000; margin: 0; }
h1 { font-size: 15px; margin: 0 0 6px; text-align: center; }
h2 { font-size: 11px; margin: 10px 0 3px; text-transform: uppercase; }
table { width: 100%; border-collapse: collapse; }
th, td { border: 1px solid #888; padding: 2px 4px; text-align: left; vertical-align: top; }
th { background: #eee; }
td.n, th.n { text-align: right; white-space: nowrap; }
.kv th { width: 22%; }
.mark { white-space: nowrap; margin-right: 6px; display: inline-block; }
.mark b { border: 1px solid #000; padding: 0 2px; margin-right: 2px; }
.d { text-decoration: line-through; }
.foot { margin-top: 8px; display: flex; justify-content: space-between; }
tr { page-break-inside: avoid; }
''';

/// Self-contained A4 page of the timesheet, same content as the customer portal print. Every API
/// value is escaped; absent header or adjustments simply leave their blocks out.
String timesheetHtml(
  Map<String, dynamic> data,
  AppLocalizations l, {
  String language = 'pt-BR',
}) {
  final header = TimesheetHeader.fromJson(data['header']);
  final days =
      (data['days'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
      <Map<String, dynamic>>[];
  final totals = data['totals'] is Map
      ? (data['totals'] as Map).cast<String, dynamic>()
      : <String, dynamic>{};
  String e(Object? v) => escapeHtml(v?.toString() ?? '');
  String dash(String v) => v.isEmpty ? '—' : escapeHtml(v);
  String min(Object? v, {bool signed = false}) =>
      formatMinutes(minutesOf(v), signed: signed);
  final period = data['month'] != null && header.periodFrom.isEmpty
      ? e(data['month'])
      : '${dateText(header.periodFrom)} – ${dateText(header.periodTo)}';
  final weekdays = l.tspWeekdays.split('|');

  final scheduleRows = StringBuffer();
  for (final s in header.schedules) {
    final cycle = s['Kind'] == 'cycle';
    final start = s['StartDate']?.toString() ?? '';
    final end = s['EndDate']?.toString() ?? '';
    final range = start.isEmpty && end.isEmpty
        ? ''
        : ' (${dateText(start)} – ${end.isEmpty ? '…' : dateText(end)})';
    scheduleRows.write(
      '<tr><th colspan="2">${e(s['Name'])} · ${e(cycle ? l.tspKindCycle : l.tspKindWeekly)}${escapeHtml(range)}</th></tr>',
    );
    for (final d in (s['Days'] as List?) ?? const []) {
      if (d is! Map) continue;
      final position = minutesOf(d['Position']);
      final label = cycle
          ? '${l.tspCycleDay} $position'
          : (position >= 1 && position <= weekdays.length
                ? weekdays[position - 1]
                : '$position');
      final startTime = d['Start']?.toString() ?? '';
      final times = startTime.isEmpty
          ? e(l.dayOff)
          : '${e(d['Start'])} – ${e(d['BreakStart'] ?? '—')} / ${e(d['BreakEnd'] ?? '—')} – ${e(d['End'] ?? '—')}';
      scheduleRows.write('<tr><td>${e(label)}</td><td>$times</td></tr>');
    }
  }

  final legend = StringBuffer();
  final dayRows = StringBuffer();
  final ordered = [...days]
    ..sort(
      (a, b) =>
          (a['Date']?.toString() ?? '').compareTo(b['Date']?.toString() ?? ''),
    );
  for (final day in ordered) {
    final dateStr = dateText(day['Date']?.toString() ?? '');
    final marks = <String>[];
    for (final p in (day['punches'] as List?) ?? const []) {
      if (p is! Map<String, dynamic>) continue;
      final nsr = p['NSR'] == null ? '' : ' NSR ${e(p['NSR'])}';
      final text = '${e(p['LocalTime'])}$nsr';
      marks.add(
        isDisregarded(p)
            ? '<span class="mark d"><b>D</b>$text</span>'
            : '<span class="mark">$text</span>',
      );
    }
    for (final a in adjustmentsOf(day)) {
      if (a.included) {
        marks.add('<span class="mark"><b>I</b>${e(a.localTime)}</span>');
      }
      legend.write(
        '<tr><td>${e(dateStr)}</td><td>${a.marker}</td><td>${dash(a.localTime)}</td>'
        '<td>${e(punchLabel(l, a.punchType))}</td><td>${dash(a.reason)}</td></tr>',
      );
    }
    final flags = [
      for (final f in (day['Flags'] as List?) ?? const [])
        ?flagLabel(l, f.toString()),
    ].join(', ');
    final overtime =
        minutesOf(day['OvertimeMinutes']) +
        minutesOf(day['OvertimeRestMinutes']);
    dayRows.write(
      '<tr><td>${e(dateStr)}</td><td>${e(dayKindLabel(l, day))}</td>'
      '<td>${marks.isEmpty ? '—' : marks.join(' ')}</td>'
      '<td class="n">${min(day['ExpectedMinutes'])}</td><td class="n">${min(day['WorkedMinutes'])}</td>'
      '<td class="n">${formatMinutes(overtime)}</td><td class="n">${min(day['AbsenceMinutes'])}</td>'
      '<td class="n">${min(day['LateMinutes'])}</td><td class="n">${min(day['NightMinutes'])}</td>'
      '<td class="n">${min(day['BalanceMinutes'], signed: true)}</td><td>${e(flags)}</td></tr>',
    );
  }

  final heads = [
    (l.tspDate, false),
    (l.tspDayCol, false),
    (l.tspMarks, false),
    (l.tspExpected, true),
    (l.tspWorked, true),
    (l.tspOvertime, true),
    (l.tspAbsence, true),
    (l.tspLate, true),
    (l.tspNight, true),
    (l.tspBalance, true),
    (l.tspIssues, false),
  ];
  final headRow = heads
      .map((h) => '<th${h.$2 ? ' class="n"' : ''}>${e(h.$1)}</th>')
      .join();
  final totalOvertime =
      minutesOf(totals['OvertimeMinutes']) +
      minutesOf(totals['OvertimeRestMinutes']);
  final legendHtml = legend.isEmpty
      ? ''
      : '<h2>${e(l.tspLegend)}</h2><p>${e(l.tspLegendText)}</p><table><tr><th>${e(l.tspDate)}</th><th></th><th>${e(l.tspTime)}</th><th>${e(l.tspType)}</th><th>${e(l.tspReason)}</th></tr>$legend</table>';
  final issued = header.issuedAtLocal.isNotEmpty
      ? header.issuedAtLocal
      : issuedText(header.issuedAt);
  final tz = header.issuedAtLocal.isNotEmpty && header.timezone.isNotEmpty
      ? ' (${e(header.timezone)})'
      : '';
  return '''<!doctype html><html lang="${e(language)}"><head><meta charset="utf-8"><title>${e(l.tspTitle)}</title><style>$_style</style></head><body>
<h1>${e(l.tspTitle)}</h1>
<table class="kv">
<tr><th>${e(l.tspEmployer)}</th><td>${dash(header.employerName)}</td><th>${e(l.tspEmployerDocument)}</th><td>${dash(header.employerDocument)}</td></tr>
<tr><th>${e(l.tspEmployee)}</th><td>${dash(header.employeeName)}</td><th>${e(l.tspCpf)}</th><td>${dash(header.employeeDocument)}</td></tr>
<tr><th>${e(l.tspHireDate)}</th><td>${dash(dateText(header.hireDate))}</td><th>${e(l.tspPosition)}</th><td>${dash(header.positionName)}</td></tr>
<tr><th>${e(l.tspPeriod)}</th><td>$period</td><th>${e(l.tspDepartment)}</th><td>${dash(header.departmentName)}</td></tr>
</table>
${scheduleRows.isEmpty ? '' : '<h2>${e(l.tspSchedules)}</h2><table>$scheduleRows</table>'}
<h2>${e(l.tspDays)}</h2>
<table><thead><tr>$headRow</tr></thead><tbody>$dayRows</tbody>
<tfoot><tr><th colspan="3">${e(l.tspTotals)}</th><th class="n">${min(totals['ExpectedMinutes'])}</th><th class="n">${min(totals['WorkedMinutes'])}</th><th class="n">${formatMinutes(totalOvertime)}</th><th class="n">${min(totals['AbsenceMinutes'])}</th><th class="n">${min(totals['LateMinutes'])}</th><th class="n">${min(totals['NightMinutes'])}</th><th class="n">${min(totals['BalanceMinutes'], signed: true)}</th><th></th></tr></tfoot></table>
$legendHtml
<div class="foot"><span>${e(l.tspIssuedAt)}: ${e(issued)}$tz</span><span>${e(l.tspPeriod)}: $period</span></div>
</body></html>''';
}
