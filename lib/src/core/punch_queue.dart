import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../offline/punch_database.dart';
import '../offline/secret_vault.dart';

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

/// Marks waiting for the API, in one SQLite database encrypted with SQLite3MultipleCiphers: a
/// native file on Android, iOS and desktop, IndexedDB through sqlite3mc.wasm on the web. The key
/// lives in secure storage. Only marks live here: never the session, password or tokens.
class PunchStore {
  PunchStore._(this._db) {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS pending_punch (
        idempotency_key TEXT PRIMARY KEY,
        account_uuid TEXT NOT NULL,
        item TEXT NOT NULL,
        occurred_at TEXT NOT NULL,
        created_at TEXT NOT NULL) STRICT;
      CREATE INDEX IF NOT EXISTS pending_punch_account ON pending_punch (account_uuid, occurred_at);
    ''');
  }

  final CommonDatabase _db;

  static const _keyName = 'pulse.db.key';
  static Future<PunchStore>? _opening;

  /// In-memory store (tests and platforms without SQLite); never touches the disk.
  static PunchStore memory(CommonDatabase db) => PunchStore._(db);

  /// The shared store of this device, opened once.
  static Future<PunchStore> open() async =>
      _instance ??= await (_opening ??= _open());
  static PunchStore? _instance;

  /// Replaces the shared store (tests).
  static void use(PunchStore store) {
    _instance = store;
    _opening = null;
  }

  static Future<PunchStore> _open() async {
    final vault = SecretVault.instance;
    var key = await vault.read(_keyName);
    if (key == null || key.isEmpty) {
      final random = Random.secure();
      key = List.generate(
        32,
        (_) => random.nextInt(256),
      ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await vault.write(_keyName, key);
    }
    try {
      return PunchStore._(_keyed(await openPunchDatabase(), key));
    } catch (_) {
      // The key in secure storage no longer opens the file (storage reset): those marks cannot
      // be read by anyone, so the file is recreated with the current key.
      await deletePunchDatabase();
      return PunchStore._(_keyed(await openPunchDatabase(), key));
    }
  }

  static CommonDatabase _keyed(CommonDatabase db, String key) {
    db.execute("PRAGMA key = '$key'");
    // A wrong key fails here, on the first read of the encrypted pages.
    db.select('SELECT count(*) FROM sqlite_master');
    return db;
  }

  /// True when the bundled SQLite encrypts (SQLite3MultipleCiphers answers `PRAGMA cipher`).
  bool get encrypted {
    try {
      return _db.select('PRAGMA cipher').isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  List<QueuedPunch> pending(String accountUUID) => [
    for (final row in _db.select(
      'SELECT item FROM pending_punch WHERE account_uuid = ? ORDER BY occurred_at, created_at',
      [accountUUID],
    ))
      QueuedPunch.fromJson(
        jsonDecode(row['item'] as String) as Map<String, dynamic>,
      ),
  ];

  /// Accounts of this device with marks still waiting (sent even after a sign-out).
  List<String> accounts() => [
    for (final row in _db.select(
      'SELECT DISTINCT account_uuid FROM pending_punch',
    ))
      row['account_uuid'] as String,
  ];

  void add(String accountUUID, QueuedPunch punch) => _db.execute(
    'INSERT OR IGNORE INTO pending_punch (idempotency_key, account_uuid, item, occurred_at, created_at) '
    'VALUES (?, ?, ?, ?, ?)',
    [
      punch.idempotencyKey,
      accountUUID,
      jsonEncode(punch.toJson()),
      punch.occurredAt.toIso8601String(),
      DateTime.now().toUtc().toIso8601String(),
    ],
  );

  void remove(String idempotencyKey) => _db.execute(
    'DELETE FROM pending_punch WHERE idempotency_key = ?',
    [idempotencyKey],
  );
}

/// Queue of one account over the shared [PunchStore]. Marks of earlier versions, kept in plain
/// `shared_preferences`, move into the encrypted store on the first read and leave the old place.
class PunchQueue {
  PunchQueue(this.accountUUID);
  final String accountUUID;

  String get _legacyKey => 'pulse.queue.$accountUUID';

  Future<PunchStore> _store() async {
    final store = await PunchStore.open();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_legacyKey);
      if (raw != null) {
        final decoded = raw.isEmpty ? null : jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<Map<String, dynamic>>()) {
            store.add(accountUUID, QueuedPunch.fromJson(item));
          }
        }
        await persistPunchDatabase();
        await prefs.remove(_legacyKey);
      }
    } catch (_) {
      // Unreadable legacy data: nothing to move.
    }
    return store;
  }

  Future<List<QueuedPunch>> load() async =>
      (await _store()).pending(accountUUID);

  Future<void> add(QueuedPunch punch) async {
    (await _store()).add(accountUUID, punch);
    await persistPunchDatabase();
  }

  Future<void> remove(String idempotencyKey) async {
    (await _store()).remove(idempotencyKey);
    await persistPunchDatabase();
  }
}
