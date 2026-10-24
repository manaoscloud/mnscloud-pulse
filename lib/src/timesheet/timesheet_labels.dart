import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Minutes as HH:MM; `signed` adds `+` to positive values (balances). Negative values always
/// carry `-`.
String formatMinutes(int minutes, {bool signed = false}) {
  final sign = minutes < 0
      ? '-'
      : signed && minutes > 0
      ? '+'
      : '';
  final value = minutes.abs();
  String two(int v) => v.toString().padLeft(2, '0');
  return '$sign${two(value ~/ 60)}:${two(value % 60)}';
}

/// Integer minutes from an API field (number or numeric text); anything else is zero.
int minutesOf(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

/// Color of a balance: positive primary, negative error, zero neutral.
Color balanceColor(ColorScheme scheme, int minutes) => minutes > 0
    ? scheme.primary
    : minutes < 0
    ? scheme.error
    : scheme.onSurfaceVariant;

/// Short employee-facing label of a day flag; unknown codes are not shown.
String? flagLabel(AppLocalizations l, String flag) => switch (flag) {
  'absence' => l.flagAbsence,
  'missing_punch' => l.flagMissingPunch,
  'late' => l.flagLate,
  'early_leave' => l.flagEarlyLeave,
  'short_break' => l.flagShortBreak,
  'rest_violation' => l.flagRestViolation,
  'overtime_limit' => l.flagOvertimeLimit,
  'worked_day_off' => l.flagWorkedDayOff,
  'flagged_punch' => l.flagFlaggedPunch,
  'no_schedule' => l.flagNoSchedule,
  _ => null,
};

/// What the day is: the expected shift (`08:00–17:00`), day off, holiday or no schedule.
String dayKindLabel(
  AppLocalizations l,
  Map<String, dynamic>? day, {
  String? startLocal,
  String? endLocal,
}) {
  final start = startLocal ?? day?['ExpectedStartLocal']?.toString();
  final end = endLocal ?? day?['ExpectedEndLocal']?.toString();
  final name = day?['HolidayName']?.toString() ?? '';
  return switch (day?['DayKind']) {
    'off' => l.dayOff,
    'holiday' => name.isEmpty ? l.holiday : l.holidayNamed(name),
    'work' when start != null && start.isNotEmpty =>
      end == null || end.isEmpty ? start : '$start–$end',
    'work' => l.workDay,
    _ => l.noSchedule,
  };
}

/// YYYY-MM of a month.
String monthKey(DateTime month) =>
    '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
