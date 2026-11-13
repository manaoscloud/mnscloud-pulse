import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../offline/punch_database.dart';
import 'pulse_api.dart' show PulseFailure;
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
    this.employmentUUID,
    this.needsEmployment = false,
  });

  factory QueuedPunch.fromJson(Map<String, dynamic> json) => QueuedPunch(
    idempotencyKey: json['idempotencyKey'] as String,
    type: json['type'] as String,
    occurredAt: DateTime.parse(json['occurredAt'] as String).toUtc(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
    employmentUUID: _nonEmpty(json['employmentUUID']),
    needsEmployment: json['needsEmployment'] == true,
  );

  final String idempotencyKey;
  final String type;
  final DateTime occurredAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  /// Employment the mark belongs to (chosen at the tap when the employee has several).
  final String? employmentUUID;

  /// The API refused the mark for its employment and the employee has several: it waits on the
  /// device, never resent, until one is assigned.
  final bool needsEmployment;

  QueuedPunch withEmployment(String? employmentUUID) => QueuedPunch(
    idempotencyKey: idempotencyKey,
    type: type,
    occurredAt: occurredAt,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
    employmentUUID: employmentUUID,
  );

  QueuedPunch waitingForEmployment() => QueuedPunch(
    idempotencyKey: idempotencyKey,
    type: type,
    occurredAt: occurredAt,
    latitude: latitude,
    longitude: longitude,
    accuracyMeters: accuracyMeters,
    employmentUUID: employmentUUID,
    needsEmployment: true,
  );

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'type': type,
    'occurredAt': occurredAt.toIso8601String(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
    if (employmentUUID != null) 'employmentUUID': employmentUUID,
    if (needsEmployment) 'needsEmployment': true,
  };

  /// Body of POST /pulse/punches. A first attempt is online (server clock); a mark sent from the
  /// queue later is offline and keeps the corrected device time of the tap.
  Map<String, dynamic> body({required bool offline, required String source}) =>
      {
        ...toJson()..remove('needsEmployment'),
        'offline': offline,
        'source': source,
      };
}

String? _nonEmpty(Object? value) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? null : text;
}

/// Owner of the photos of the shared time clock in [PunchStore] (accounts use their own uuid).
const kioskPhotoOwner = 'kiosk';

/// The API refuses the photo of a mark after this long.
const pendingPhotoMaxAge = Duration(hours: 24);

/// A photo kept on the device until its mark is recorded and the upload is accepted.
class PendingPhoto {
  const PendingPhoto({
    required this.punchKey,
    required this.punchUUID,
    required this.photoUUID,
    required this.contentType,
    required this.bytes,
    required this.createdAt,
  });

  final String punchKey;
  final String punchUUID;
  final String photoUUID;
  final String contentType;
  final Uint8List bytes;
  final DateTime createdAt;
}

/// A refusal that no retry can fix: the mark is not found (404), the photo is malformed (400) or
/// too large (413), or this device key is invalid or revoked. Everything else (network, 5xx, 403,
/// 408, 429, clock skew, storage or module unavailable, session ended) keeps the photo.
bool photoUploadDefinitive(PulseFailure failure) {
  final status = failure.status;
  return status == 400 || status == 404 || status == 413;
}

/// Keep the photo and try again later.
bool photoUploadRetry(PulseFailure failure) => !photoUploadDefinitive(failure);

/// The API already holds a photo for that mark (a retry after a lost answer): same as accepted.
bool photoAlreadyStored(PulseFailure failure) =>
    failure.code == 'PULSE_PUNCH_PHOTO_EXISTS';

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
      CREATE TABLE IF NOT EXISTS pending_punch_photo (
        punch_key TEXT PRIMARY KEY,
        owner TEXT NOT NULL,
        punch_uuid TEXT,
        bound_at TEXT,
        photo_uuid TEXT NOT NULL,
        content_type TEXT NOT NULL,
        bytes BLOB NOT NULL,
        created_at TEXT NOT NULL) STRICT;
      CREATE INDEX IF NOT EXISTS pending_punch_photo_owner ON pending_punch_photo (owner, created_at);
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

  /// Accounts of this device with marks or photos still waiting (sent even after a sign-out).
  List<String> accounts() => [
    for (final row in _db.select(
      'SELECT account_uuid AS owner FROM pending_punch '
      "UNION SELECT owner FROM pending_punch_photo WHERE owner <> '$kioskPhotoOwner'",
    ))
      row['owner'] as String,
  ];

  /// Keeps the photo of a mark that is not recorded yet ([punchKey] is its idempotency key) or
  /// whose upload failed ([punchUUID] already known). One photo per mark; a retry keeps the first.
  void addPhoto(
    String owner,
    String punchKey,
    String photoUUID,
    Uint8List bytes, {
    String? punchUUID,
    String contentType = 'image/jpeg',
    DateTime? createdAt,
  }) => _db.execute(
    'INSERT OR IGNORE INTO pending_punch_photo '
    '(punch_key, owner, punch_uuid, bound_at, photo_uuid, content_type, bytes, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      punchKey,
      owner,
      punchUUID,
      punchUUID == null
          ? null
          : (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
      photoUUID,
      contentType,
      bytes,
      (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
    ],
  );

  /// The mark of [punchKey] was recorded as [punchUUID]: its photo can go.
  void bindPhoto(String punchKey, String punchUUID) => _db.execute(
    'UPDATE pending_punch_photo SET punch_uuid = ?, bound_at = ? WHERE punch_key = ?',
    [punchUUID, DateTime.now().toUtc().toIso8601String(), punchKey],
  );

  bool hasPhoto(String punchKey) => _db.select(
    'SELECT 1 FROM pending_punch_photo WHERE punch_key = ?',
    [punchKey],
  ).isNotEmpty;

  /// Photos of [owner] whose mark is recorded (they can be uploaded), oldest first.
  List<PendingPhoto> readyPhotos(String owner) => [
    for (final row in _db.select(
      'SELECT punch_key, punch_uuid, photo_uuid, content_type, bytes, created_at '
      'FROM pending_punch_photo WHERE owner = ? AND punch_uuid IS NOT NULL '
      'ORDER BY created_at',
      [owner],
    ))
      PendingPhoto(
        punchKey: row['punch_key'] as String,
        punchUUID: row['punch_uuid'] as String,
        photoUUID: row['photo_uuid'] as String,
        contentType: row['content_type'] as String,
        bytes: Uint8List.fromList(row['bytes'] as List<int>),
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      ),
  ];

  void removePhoto(String punchKey) => _db.execute(
    'DELETE FROM pending_punch_photo WHERE punch_key = ?',
    [punchKey],
  );

  void removeOwnerPhotos(String owner) =>
      _db.execute('DELETE FROM pending_punch_photo WHERE owner = ?', [owner]);

  /// Drops the photos whose mark was recorded more than [maxAge] ago (the API refuses them).
  /// Photos still waiting for their mark are never dropped here.
  void dropOldPhotos({Duration maxAge = pendingPhotoMaxAge, DateTime? now}) =>
      _db.execute(
        'DELETE FROM pending_punch_photo WHERE bound_at IS NOT NULL AND bound_at < ?',
        [(now ?? DateTime.now()).toUtc().subtract(maxAge).toIso8601String()],
      );

  /// Drops the unbound photos of [owner] whose mark is no longer waiting ([liveKeys], or the
  /// account queue when null): the mark was discarded or refused, so the photo has no destination.
  void dropOrphanPhotos(String owner, {Set<String>? liveKeys}) {
    final live =
        liveKeys ??
        {
          for (final row in _db.select(
            'SELECT idempotency_key FROM pending_punch WHERE account_uuid = ?',
            [owner],
          ))
            row['idempotency_key'] as String,
        };
    for (final row in _db.select(
      'SELECT punch_key FROM pending_punch_photo WHERE owner = ? AND punch_uuid IS NULL',
      [owner],
    )) {
      final key = row['punch_key'] as String;
      if (!live.contains(key)) removePhoto(key);
    }
  }

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

  void update(String accountUUID, QueuedPunch punch) => _db.execute(
    'UPDATE pending_punch SET item = ? WHERE idempotency_key = ? AND account_uuid = ?',
    [jsonEncode(punch.toJson()), punch.idempotencyKey, accountUUID],
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

  Future<void> update(QueuedPunch punch) async {
    (await _store()).update(accountUUID, punch);
    await persistPunchDatabase();
  }

  Future<void> remove(String idempotencyKey) async {
    (await _store()).remove(idempotencyKey);
    await persistPunchDatabase();
  }

  /// Keeps the photo of a mark until the sync uploads it; [punchUUID] is known when the mark was
  /// already recorded and only the upload failed.
  Future<void> addPhoto(
    String punchKey,
    String photoUUID,
    Uint8List bytes, {
    String? punchUUID,
  }) async {
    (await _store()).addPhoto(
      accountUUID,
      punchKey,
      photoUUID,
      bytes,
      punchUUID: punchUUID,
    );
    await persistPunchDatabase();
  }

  Future<void> bindPhoto(String punchKey, String punchUUID) async {
    final store = await _store();
    if (!store.hasPhoto(punchKey)) return;
    store.bindPhoto(punchKey, punchUUID);
    await persistPunchDatabase();
  }

  Future<void> removePhoto(String punchKey) async {
    (await _store()).removePhoto(punchKey);
    await persistPunchDatabase();
  }

  Future<List<PendingPhoto>> readyPhotos() async =>
      (await _store()).readyPhotos(accountUUID);

  Future<void> dropOldPhotos() async {
    final store = await _store();
    store.dropOldPhotos();
    store.dropOrphanPhotos(accountUUID);
    await persistPunchDatabase();
  }
}
