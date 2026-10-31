import 'package:flutter/foundation.dart';

import '../core/pulse_api.dart';
import '../core/punch_queue.dart';
import 'device_grant.dart';

/// Outcome of one pass over the queue of an account.
class FlushResult {
  const FlushResult({this.sent = 0, this.offline = false, this.sessionEnded});

  final int sent;

  /// No connection (or rate limited): the remaining marks wait for the next pass.
  final bool offline;

  /// The live session ended during the pass (its code); the marks went on with the device grant.
  final String? sessionEnded;
}

/// The single sender of queued marks, oldest first. With the live session of the account it uses
/// the session; otherwise (expired, closed app, sign-out, opened offline) the offline grant of this
/// device signs them. It runs at start, every tick, when the browser regains connection, when the
/// app comes back to the foreground and after every new mark; a pass never runs twice at once.
class PunchSync extends ChangeNotifier {
  PunchSync({required this.api, required this.grants, required this.source});

  final PulseApi api;
  final DeviceGrants grants;
  final String source;
  final _running = <String, Future<FlushResult>>{};

  Future<FlushResult> flush(String accountUUID) =>
      _running[accountUUID] ??= _flush(accountUUID).whenComplete(() {
        _running.remove(accountUUID);
      });

  /// Every account of this device with marks waiting, signed in or not.
  Future<void> flushAll() async {
    final store = await PunchStore.open();
    for (final account in store.accounts()) {
      await flush(account);
    }
  }

  Future<FlushResult> _flush(String accountUUID) async {
    final queue = PunchQueue(accountUUID);
    var sent = 0;
    var offline = false;
    String? sessionEnded;
    var useSession = api.signedIn && api.accountUUID == accountUUID;
    var useDevice = await grants.available(accountUUID);
    final pending = await queue.load();
    var index = 0;
    try {
      while (index < pending.length && (useSession || useDevice)) {
        final punch = pending[index];
        try {
          if (useSession) {
            await api.createPunch(punch.body(offline: true, source: source));
          } else {
            await grants.send(accountUUID, punch, source);
          }
          await queue.remove(punch.idempotencyKey);
          sent++;
          index++;
        } on PulseFailure catch (failure) {
          if (failure.code == 'networkError' ||
              failure.code == 'PULSE_RATE_LIMITED') {
            offline = failure.code == 'networkError';
            break;
          }
          if (useSession && failure.sessionEnded) {
            // The same mark goes again signed by the device; the screen learns the session ended.
            sessionEnded = failure.code;
            useSession = false;
          } else if (!useSession && failure.deviceRefused) {
            // The marks wait for a session (and a new registration).
            await grants.invalidate(accountUUID);
            useDevice = false;
          } else if (failure.code == 'PULSE_INVALID_PUNCH') {
            // The API refused the mark itself; it can never be recorded as it is.
            await queue.remove(punch.idempotencyKey);
            index++;
          } else {
            // Access or module refused: the marks stay until access is back.
            break;
          }
        }
      }
    } finally {
      if (sent > 0) notifyListeners();
    }
    return FlushResult(
      sent: sent,
      offline: offline,
      sessionEnded: sessionEnded,
    );
  }
}
