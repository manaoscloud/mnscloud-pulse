import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'device_lock_stub.dart' as local;

/// Runs [task] while holding the `mnscloud-pulse-device` Web Lock, so two tabs never sign with the
/// same counter (a repeated counter revokes the device). Falls back to the in-page queue when the
/// browser has no Web Locks.
Future<T> withDeviceLock<T>(Future<T> Function() task) {
  final completer = Completer<T>();
  try {
    web.window.navigator.locks
        .request(
          'mnscloud-pulse-device',
          ((web.Lock? _) => (() async {
            try {
              completer.complete(await task());
            } catch (error, stack) {
              completer.completeError(error, stack);
            }
          })().toJS).toJS,
        )
        .toDart
        .ignore();
  } catch (_) {
    return local.withDeviceLock(task);
  }
  return completer.future;
}

/// The browser regained a connection: the queue is flushed at once instead of at the next tick.
void onBrowserOnline(void Function() listener) {
  web.window.addEventListener('online', ((web.Event _) => listener()).toJS);
}

/// Tests only (the in-page queue of the fallback).
void resetDeviceLock() => local.resetDeviceLock();
