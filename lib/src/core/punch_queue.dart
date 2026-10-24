import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One mark captured on this device and not yet acknowledged by the API. Its idempotency key is
/// created at the tap and never changes, so a retry after a lost answer is recorded once.
class QueuedPunch {
  const QueuedPunch({
    required this.idempotencyKey,
    required this.type,
    required this.occurredAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  factory QueuedPunch.fromJson(Map<String, dynamic> json) => QueuedPunch(
    idempotencyKey: json['idempotencyKey'] as String,
    type: json['type'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String).toUtc(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
  );

  final String idempotencyKey;
  final String type;
  final DateTime occurredAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'type': type,
    'occurredAt': occurredAt.toIso8601String(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
  };

  /// Body of POST /pulse/punches. A first attempt is online (server clock); a mark sent from the
  /// queue later is offline and keeps the corrected device time of the tap.
  Map<String, dynamic> body({required bool offline, required String source}) =>
      {...toJson(), 'offline': offline, 'source': source};
}

/// Marks waiting for the API, kept per account on this device until acknowledged. Only marks
/// live here: never the session, password or tokens.
class PunchQueue {
  PunchQueue(this.accountUUID);
  final String accountUUID;

  String get _key => 'pulse.queue.$accountUUID';

  Future<List<QueuedPunch>> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      return decoded is List
          ? decoded
                .whereType<Map<String, dynamic>>()
                .map(QueuedPunch.fromJson)
                .toList()
          : [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<QueuedPunch> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (items.isEmpty) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(
          _key,
          jsonEncode(items.map((item) => item.toJson()).toList()),
        );
      }
    } catch (_) {
      // Storage denied: the mark stays in memory for this page only.
    }
  }

  Future<void> add(QueuedPunch punch) async {
    final items = await load();
    if (items.every((item) => item.idempotencyKey != punch.idempotencyKey)) {
      items.add(punch);
    }
    await _save(items);
  }

  Future<void> remove(String idempotencyKey) async {
    final items = await load();
    items.removeWhere((item) => item.idempotencyKey == idempotencyKey);
    await _save(items);
  }
}
