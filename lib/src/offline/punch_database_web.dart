import 'package:sqlite3/wasm.dart';

const _fileSystemName = 'mnscloud-pulse';
const _vfsName = 'mnscloud-pulse-idb';
const _path = '/pulse-punches.db';
Future<(WasmSqlite3, IndexedDbFileSystem)>? _loading;

/// SQLite3MultipleCiphers compiled to WebAssembly (web/sqlite3mc.wasm, same version as
/// pubspec.lock) over an IndexedDB file system, so the browser copy is encrypted like the native one.
/// The file system is registered once per page.
Future<(WasmSqlite3, IndexedDbFileSystem)> _open() => _loading ??= () async {
  final sqlite = await WasmSqlite3.loadFromUrl(
    Uri.base.resolve('sqlite3mc.wasm'),
  );
  final fileSystem = await IndexedDbFileSystem.open(
    dbName: _fileSystemName,
    vfsName: _vfsName,
  );
  sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return (sqlite, fileSystem);
}();

Future<CommonDatabase> openPunchDatabase() async {
  final (sqlite, _) = await _open();
  // Only the cipher wrapper of the file system encrypts: opened on the plain VFS (by name or as
  // the default), `PRAGMA key` fails with "Encryption is not supported by the VFS".
  return sqlite.open(_path, vfs: 'multipleciphers-$_vfsName');
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
