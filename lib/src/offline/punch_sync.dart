import 'package:flutter/foundation.dart';

import '../core/pulse_api.dart';
import '../core/punch_queue.dart';
import 'device_grant.dart';

/// Outcome of one pass over the queue of an account.
class FlushResult {
  const FlushResult({
    this.sent = 0,
    this.photosSent = 0,
    this.offline = false,
    this.sessionEnded,
  });

  final int sent;

  /// Photos of recorded marks accepted by the API in this pass.
  final int photosSent;

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
    var photosSent = 0;
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
          final item = useSession
              ? await api.createPunch(punch.body(offline: true, source: source))
              : await grants.send(accountUUID, punch, source);
          final punchUUID = item['TimePunchUUID']?.toString();
          if (punchUUID != null && punchUUID.isNotEmpty) {
            await queue.bindPhoto(punch.idempotencyKey, punchUUID);
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
            await queue.removePhoto(punch.idempotencyKey);
            index++;
          } else {
            // Access or module refused: the marks stay until access is back.
            break;
          }
        }
      }
      if (!offline) {
        final photos = await _uploadPhotos(accountUUID, useSession, useDevice);
        photosSent = photos.sent;
        offline = photos.offline;
        if (photos.sessionEnded != null) sessionEnded ??= photos.sessionEnded;
      }
    } finally {
      if (sent > 0 || photosSent > 0) notifyListeners();
    }
    return FlushResult(
      sent: sent,
      photosSent: photosSent,
      offline: offline,
      sessionEnded: sessionEnded,
    );
  }

  /// Uploads the kept photos of recorded marks, oldest first, with the session or (without one)
  /// signed by this device. Accepted or definitively refused photos are deleted; a network or
  /// server failure keeps them for the next pass; photos older than 24 h are dropped.
  Future<({int sent, bool offline, String? sessionEnded})> _uploadPhotos(
    String accountUUID,
    bool useSession,
    bool useDevice,
  ) async {
    final queue = PunchQueue(accountUUID);
    await queue.dropOldPhotos();
    var sent = 0;
    String? sessionEnded;
    for (final photo in await queue.readyPhotos()) {
      if (!useSession && !useDevice) break;
      try {
        if (useSession) {
          await api.uploadPunchPhoto(
            photo.punchUUID,
            photo.photoUUID,
            photo.bytes,
          );
        } else {
          await grants.sendPhoto(
            accountUUID,
            photo.punchUUID,
            photo.photoUUID,
            photo.bytes,
          );
        }
        await queue.removePhoto(photo.punchKey);
        sent++;
      } on PulseFailure catch (failure) {
        if (photoAlreadyStored(failure)) {
          await queue.removePhoto(photo.punchKey);
          sent++;
          continue;
        }
        if (failure.code == 'PULSE_DEVICE_CLOCK_SKEW') {
          return (sent: sent, offline: false, sessionEnded: sessionEnded);
        }
        if (useSession && failure.sessionEnded) {
          sessionEnded = failure.code;
          useSession = false;
          if (!useDevice) break;
          try {
            await grants.sendPhoto(
              accountUUID,
              photo.punchUUID,
              photo.photoUUID,
              photo.bytes,
            );
            await queue.removePhoto(photo.punchKey);
            sent++;
          } on PulseFailure catch (again) {
            if (photoAlreadyStored(again)) {
              await queue.removePhoto(photo.punchKey);
              sent++;
            } else if (again.code == 'PULSE_DEVICE_CLOCK_SKEW') {
              return (sent: sent, offline: false, sessionEnded: sessionEnded);
            } else if (again.deviceRefused) {
              await grants.invalidate(accountUUID);
              useDevice = false;
            } else if (photoUploadRetry(again)) {
              return (
                sent: sent,
                offline: again.code == 'networkError',
                sessionEnded: sessionEnded,
              );
            } else {
              await queue.removePhoto(photo.punchKey);
            }
          }
        } else if (!useSession && failure.deviceRefused) {
          await grants.invalidate(accountUUID);
          useDevice = false;
        } else if (failure.sessionEnded || failure.deviceRefused) {
          break;
        } else if (photoUploadRetry(failure)) {
          return (
            sent: sent,
            offline: failure.code == 'networkError',
            sessionEnded: sessionEnded,
          );
        } else {
          // Refused for good (the mark is not the employee's, the photo is not an image, too late).
          await queue.removePhoto(photo.punchKey);
        }
      }
    }
    return (sent: sent, offline: false, sessionEnded: sessionEnded);
  }
}
