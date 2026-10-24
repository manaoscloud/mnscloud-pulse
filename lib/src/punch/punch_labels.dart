import '../../l10n/app_localizations.dart';

const punchTypes = ['clock_in', 'break_start', 'break_end', 'clock_out'];

String punchLabel(AppLocalizations l, String type) => switch (type) {
  'clock_in' => l.clockIn,
  'break_start' => l.breakStart,
  'break_end' => l.breakEnd,
  'clock_out' => l.clockOut,
  _ => type,
};

/// Suggested next mark from the last one; every other mark stays available (never blocked).
String nextPunchType(String? lastType) => switch (lastType) {
  'clock_in' => 'break_start',
  'break_start' => 'break_end',
  'break_end' => 'clock_out',
  _ => 'clock_in',
};
