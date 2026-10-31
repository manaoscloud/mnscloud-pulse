import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../core/ids.dart';
import '../core/pulse_api.dart';
import '../core/punch_queue.dart';
import '../core/server_clock.dart';
import 'device_lock.dart';
import 'p256.dart';
import 'secret_vault.dart';

/// State of the offline grant of one account on this device, kept as one secure-storage entry.
class DeviceGrantState {
  const DeviceGrantState({
    required this.deviceUUID,
    required this.privateKey,
    required this.counter,
    this.expiresAt,
    this.renewedAt,
  });

  factory DeviceGrantState.fromJson(Map<String, dynamic> json) =>
      DeviceGrantState(
        deviceUUID: json['deviceUUID'] as String,
        privateKey: json['privateKey'] as String,
        counter: (json['counter'] as num?)?.toInt() ?? 0,
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        renewedAt: DateTime.tryParse(json['renewedAt']?.toString() ?? ''),
      );

  final String deviceUUID;
  final String privateKey;
  final int counter;
  final DateTime? expiresAt;
  final DateTime? renewedAt;

  bool valid(DateTime now) => expiresAt != null && expiresAt!.isAfter(now);

  DeviceGrantState copyWith({
    int? counter,
    DateTime? expiresAt,
    DateTime? renewedAt,
    bool clearGrant = false,
  }) => DeviceGrantState(
    deviceUUID: deviceUUID,
    privateKey: privateKey,
    counter: counter ?? this.counter,
    expiresAt: clearGrant ? null : expiresAt ?? this.expiresAt,
    renewedAt: clearGrant ? null : renewedAt ?? this.renewedAt,
  );

  Map<String, dynamic> toJson() => {
    'deviceUUID': deviceUUID,
    'privateKey': privateKey,
    'counter': counter,
    if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
    if (renewedAt != null) 'renewedAt': renewedAt!.toUtc().toIso8601String(),
  };
}

/// Offline grant of this installed client: an ECDSA P-256 key per account (private key only in
/// secure storage) registered with the API while a session is live. Queued marks are then sent
/// signed, even after the session ended (expired, closed app, sign-out). Every signed request
/// uses a higher counter, under a lock shared by the browser tabs: a repeated counter would
/// revoke the device.
class DeviceGrants {
  DeviceGrants({required this.api, required this.clock, SecretVault? vault})
    : _vault = vault ?? SecretVault.instance;

  final PulseApi api;
  final ServerClock clock;
  final SecretVault _vault;

  /// A grant is renewed at most once a day while sessions keep opening.
  static const renewEvery = Duration(hours: 20);

  String _name(String accountUUID) => 'pulse.device.$accountUUID';

  Future<DeviceGrantState?> read(String accountUUID) async {
    final raw = await _vault.read(_name(accountUUID));
    if (raw == null || raw.isEmpty) return null;
    try {
      return DeviceGrantState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(String accountUUID, DeviceGrantState state) =>
      _vault.write(_name(accountUUID), jsonEncode(state.toJson()));

  /// True when queued marks of [accountUUID] can be sent without a session.
  Future<bool> available(String accountUUID) async =>
      (await read(accountUUID))?.valid(DateTime.now().toUtc()) ?? false;

  String _timestamp() {
    final now = clock.nowUtc();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    ).toIso8601String();
  }

  /// Registers (or renews) the grant of [accountUUID]; needs the live session of that account. A
  /// key the API refuses (revoked or bound elsewhere) is replaced by a new one once.
  Future<void> ensure(
    String accountUUID, {
    bool force = false,
  }) => withDeviceLock(() async {
    var state = await read(accountUUID);
    final now = DateTime.now().toUtc();
    if (!force &&
        state != null &&
        state.valid(now) &&
        state.renewedAt != null &&
        now.difference(state.renewedAt!) < renewEvery) {
      return;
    }
    for (var attempt = 0; attempt < 2; attempt++) {
      if (!api.signedIn || api.accountUUID != accountUUID) return;
      state ??= DeviceGrantState(
        deviceUUID: uuidV4(),
        privateKey: P256Key.generate().privateBase64,
        counter: 0,
      );
      await _save(accountUUID, state);
      final key = P256Key.fromPrivateBase64(state.privateKey);
      final timestamp = _timestamp();
      try {
        final item = await api.registerDevice({
          'deviceUUID': state.deviceUUID,
          'publicKey': key.spkiBase64,
          'platform': api.platform,
          'timestamp': timestamp,
          'signature': key.sign(
            pulseDeviceRegisterMessage(
              state.deviceUUID,
              accountUUID,
              timestamp,
            ),
          ),
        });
        final serverCounter = (item['lastCounter'] as num?)?.toInt() ?? 0;
        await _save(
          accountUUID,
          state.copyWith(
            counter: state.counter > serverCounter
                ? state.counter
                : serverCounter,
            expiresAt: DateTime.tryParse(
              item['grantExpiresAt']?.toString() ?? '',
            )?.toUtc(),
            renewedAt: now,
          ),
        );
        return;
      } on PulseFailure catch (failure) {
        if (failure.code != 'PULSE_DEVICE_KEY_REJECTED') return;
        // Revoked or bound to another account: a new key and device id, once.
        state = null;
      }
    }
  });

  /// The grant is no longer accepted: its marks wait for a session (and a new registration).
  Future<void> invalidate(String accountUUID) => withDeviceLock(() async {
    final state = await read(accountUUID);
    if (state != null) {
      await _save(accountUUID, state.copyWith(clearGrant: true));
    }
  });

  /// Sends one queued mark signed by this device (no session needed).
  Future<Map<String, dynamic>> send(
    String accountUUID,
    QueuedPunch punch,
    String source,
  ) => withDeviceLock(() async {
    final state = await read(accountUUID);
    if (state == null || !state.valid(DateTime.now().toUtc())) {
      throw const PulseFailure('PULSE_DEVICE_INVALID');
    }
    // The counter is stored before the request: a lost answer never reuses it.
    final counter = state.counter + 1;
    await _save(accountUUID, state.copyWith(counter: counter));
    final body = jsonEncode(punch.body(offline: true, source: source));
    final timestamp = _timestamp();
    final signature = P256Key.fromPrivateBase64(state.privateKey).sign(
      pulseDeviceSignatureMessage(
        'POST',
        '/pulse/device/punches',
        timestamp,
        '$counter',
        sha256.convert(utf8.encode(body)).toString(),
      ),
    );
    return api.createDevicePunch(body, {
      'X-Device-Id': state.deviceUUID,
      'X-Device-Timestamp': timestamp,
      'X-Device-Counter': '$counter',
      'X-Device-Signature': signature,
    });
  });
}
