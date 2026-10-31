// The encrypted punch queue opens a native file (dart:ffi) on Android, iOS and desktop, and
// sqlite3mc.wasm over IndexedDB on the web.
export 'punch_database_stub.dart'
    if (dart.library.ffi) 'punch_database_io.dart'
    if (dart.library.js_interop) 'punch_database_web.dart';
