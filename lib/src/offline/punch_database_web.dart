import 'package:sqlite3/wasm.dart';

const _fileSystemName = 'mnscloud-pulse';
const _path = '/pulse-punches.db';
WasmSqlite3? _sqlite;
IndexedDbFileSystem? _fileSystem;

/// SQLite3MultipleCiphers compiled to WebAssembly (web/sqlite3mc.wasm, same version as
/// pubspec.lock) over an IndexedDB file system, so the browser copy is encrypted like the native one.
Future<(WasmSqlite3, IndexedDbFileSystem)> _open() async {
  final sqlite = _sqlite ??= await WasmSqlite3.loadFromUrl(
    Uri.base.resolve('sqlite3mc.wasm'),
  );
  final fileSystem = _fileSystem ??= await IndexedDbFileSystem.open(
    dbName: _fileSystemName,
  );
  sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return (sqlite, fileSystem);
}

Future<CommonDatabase> openPunchDatabase() async {
  final (sqlite, _) = await _open();
  return sqlite.open(_path);
}

/// Used only when the key in secure storage no longer opens the file (storage reset).
Future<void> deletePunchDatabase() async {
  final (_, fileSystem) = await _open();
  for (final file in [_path, '$_path-journal']) {
    try {
      fileSystem.xDelete(file, 0);
    } catch (_) {
      // Already gone.
    }
  }
  await fileSystem.flush();
}
