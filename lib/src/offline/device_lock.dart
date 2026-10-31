// One writer of the device counter at a time: Web Locks across the tabs of the browser, a
// process-wide queue on native builds.
export 'device_lock_stub.dart'
    if (dart.library.js_interop) 'device_lock_web.dart';
