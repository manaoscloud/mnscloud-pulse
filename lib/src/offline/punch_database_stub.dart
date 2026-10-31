import 'package:sqlite3/common.dart';

Future<CommonDatabase> openPunchDatabase() async =>
    throw UnsupportedError('SQLite is not available on this platform');

Future<void> deletePunchDatabase() async {}
