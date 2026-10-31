import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

Future<String> _path() async =>
    '${(await getApplicationSupportDirectory()).path}/pulse-punches.db';

Future<CommonDatabase> openPunchDatabase() async => sqlite3.open(await _path());

/// Native SQLite writes the file synchronously.
Future<void> persistPunchDatabase() async {}

/// Used only when the key in secure storage no longer opens the file (storage reset).
Future<void> deletePunchDatabase() async {
  final path = await _path();
  for (final file in [path, '$path-wal', '$path-shm']) {
    try {
      File(file).deleteSync();
    } catch (_) {
      // Already gone.
    }
  }
}
