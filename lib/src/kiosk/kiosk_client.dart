import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../core/pulse_api.dart';
import '../core/server_clock.dart';
import '../offline/device_lock.dart';
import '../offline/p256.dart';
import '../offline/secret_vault.dart';
import '../version/client_identity.dart';

/// What the time clock shows about itself (from the API, refreshed on every check).
class KioskProfile {
  const KioskProfile({
    required this.kioskUUID,
    required this.name,
    this.companyName,
    this.hrAccountName,
    this.photoRequired = true,
    this.emailReceipt = true,
  });

  factory KioskProfile.fromJson(Map<String, dynamic> json) => KioskProfile(
    kioskUUID: json['KioskUUID']?.toString() ?? '',
    name: json['Name']?.toString() ?? '',
    companyName: json['CompanyName']?.toString(),
    hrAccountName: json['HrAccountName']?.toString(),
    photoRequired: json['PhotoRequired'] != false,
    emailReceipt: json['EmailReceipt'] != false,
  );

  final String kioskUUID;
  final String name;
  final String? companyName;
  final String? hrAccountName;
  final bool photoRequired;
  final bool emailReceipt;

  Map<String, dynamic> toJson() => {
    'KioskUUID': kioskUUID,
    'Name': name,
    'CompanyName': companyName,
    'HrAccountName': hrAccountName,
    'PhotoRequired': photoRequired,
    'EmailReceipt': emailReceipt,
  };
}

/// This device as a shared time clock: its key (secure storage only), the monotonic counter and
/// the hash of the local administrator PIN that unlocks the exit.
class KioskState {
  const KioskState({
    required this.privateKey,
    required this.counter,
    required this.profile,
    required this.adminSalt,
    required this.adminHash,
  });

  factory KioskState.fromJson(Map<String, dynamic> json) => KioskState(
    privateKey: json['privateKey']?.toString() ?? '',
    counter: (json['counter'] as num?)?.toInt() ?? 0,
    profile: KioskProfile.fromJson(
      (json['profile'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    adminSalt: json['adminSalt']?.toString() ?? '',
    adminHash: json['adminHash']?.toString() ?? '',
  );

  final String privateKey;
  final int counter;
  final KioskProfile profile;
  final String adminSalt;
  final String adminHash;

  KioskState copyWith({int? counter, KioskProfile? profile}) => KioskState(
    privateKey: privateKey,
    counter: counter ?? this.counter,
    profile: profile ?? this.profile,
    adminSalt: adminSalt,
    adminHash: adminHash,
  );

  Map<String, dynamic> toJson() => {
    'privateKey': privateKey,
    'counter': counter,
    'profile': profile.toJson(),
    'adminSalt': adminSalt,
    'adminHash': adminHash,
  };
}

/// The employee a kiosk identified (code + PIN), before the mark.
class KioskEmployee {
  const KioskEmployee({
    required this.employeeName,
    required this.nextPunchType,
    this.companyName,
    this.lastPunchType,
    this.hasEmail = false,
  });

  factory KioskEmployee.fromJson(Map<String, dynamic> json) => KioskEmployee(
    employeeName: json['EmployeeName']?.toString() ?? '',
    companyName: json['CompanyName']?.toString(),
    hasEmail: json['HasEmail'] == true,
    lastPunchType: json['LastPunchType']?.toString(),
    nextPunchType: json['NextPunchType']?.toString() ?? 'clock_in',
  );

  final String employeeName;
  final String? companyName;
  final bool hasEmail;
  final String? lastPunchType;
  final String nextPunchType;
}

/// Activation code as typed: 8 symbols of the code alphabet (no 0, O, 1 or I), dash optional.
String? normalizeKioskCode(String value) {
  final code = value.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(code) ? code : null;
}

String _hash(String salt, String pin) =>
    sha256.convert(utf8.encode('pulse-kiosk-admin:$salt:$pin')).toString();

/// Canonical message of a signed kiosk request; identical to the API (MNSCLOUD-PULSE-KIOSK-V1).
String pulseKioskSignatureMessage(
  String method,
  String path,
  String timestamp,
  String counter,
  String bodySha256,
) => [
  'MNSCLOUD-PULSE-KIOSK-V1',
  method.toUpperCase(),
  path,
  timestamp,
  counter,
  bodySha256,
].join('\n');

/// Signed client of the shared time clock (`/pulse/kiosk/*`). Every request carries the kiosk
/// id, the time, a counter stored before sending (a lost answer never reuses it) and the ECDSA
/// P-256 signature over the method, path, time, counter and the SHA-256 of the exact body.
class KioskClient {
  KioskClient({
    this.httpClient,
    String? baseUrl,
    SecretVault? vault,
    ServerClock? clock,
  }) : _base = normalizedApiBase(baseUrl),
       _vaultOverride = vault,
       clock = clock ?? ServerClock();

  static const _stateKey = 'pulse.kiosk';

  final http.Client? httpClient;
  final String _base;
  final SecretVault? _vaultOverride;
  final ServerClock clock;

  SecretVault get _vault => _vaultOverride ?? SecretVault.instance;

  Future<KioskState?> read() async {
    try {
      final raw = await _vault.read(_stateKey);
      if (raw == null) return null;
      final state = KioskState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return state.privateKey.isEmpty || state.profile.kioskUUID.isEmpty
          ? null
          : state;
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(KioskState state) =>
      _vault.write(_stateKey, jsonEncode(state.toJson()));

  /// Leaves the kiosk mode on this device: the key is forgotten (HR revokes the kiosk in the App).
  Future<void> forget() => _vault.delete(_stateKey);

  /// Local administrator PIN (unlocks leaving the kiosk mode); never sent anywhere.
  Future<bool> checkAdminPin(String pin) async {
    final state = await read();
    return state != null && _hash(state.adminSalt, pin) == state.adminHash;
  }

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

  Future<Map<String, dynamic>> _post(http.BaseRequest request) async {
    late http.Response response;
    try {
      final streamed = await (httpClient?.send(request) ?? request.send())
          .timeout(const Duration(seconds: 20));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw const PulseFailure('networkError');
    }
    Map<String, dynamic> data = {};
    try {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = data['code'];
      final server = data['serverTime'];
      if (server is String) {
        final parsed = DateTime.tryParse(server);
        if (parsed != null) clock.accept(parsed);
      }
      throw PulseFailure(
        code is String && code.isNotEmpty
            ? code
            : response.statusCode == 429
            ? 'PULSE_RATE_LIMITED'
            : 'requestError',
        status: response.statusCode,
        message: data['error']?.toString(),
      );
    }
    final server = (data['data'] as Map?)?['serverTime'];
    if (server is String) {
      final parsed = DateTime.tryParse(server);
      if (parsed != null) clock.accept(parsed);
    }
    return data;
  }

  /// Binds this device to the kiosk of the one-time [code] and keeps the key with the local
  /// administrator PIN.
  Future<KioskProfile> activate(String code, String adminPin) async {
    final normalized = normalizeKioskCode(code);
    if (normalized == null) {
      throw const PulseFailure('PULSE_KIOSK_ACTIVATION_INVALID');
    }
    await _syncTime();
    final key = P256Key.generate();
    final timestamp = _timestamp();
    final request =
        http.Request('POST', Uri.parse('$_base/pulse/kiosk/activate'))
          ..headers['content-type'] = 'application/json'
          ..headers.addAll(clientHeaders(platform: clientPlatformName()))
          ..body = jsonEncode({
            'activationCode': normalized,
            'publicKey': key.spkiBase64,
            'platform': clientPlatformName(),
            'timestamp': timestamp,
            'signature': key.sign(
              [
                'MNSCLOUD-PULSE-KIOSK-ACTIVATE-V1',
                normalized,
                timestamp,
              ].join('\n'),
            ),
          });
    final data = await _post(request);
    final item = (data['data'] as Map?)?['item'];
    final profile = KioskProfile.fromJson(
      item is Map<String, dynamic> ? item : const {},
    );
    final random = Random.secure();
    final salt = base64Encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    await _save(
      KioskState(
        privateKey: key.privateBase64,
        counter: 0,
        profile: profile,
        adminSalt: salt,
        adminHash: _hash(salt, adminPin),
      ),
    );
    return profile;
  }

  /// Official time before signing anything (the API accepts at most 10 minutes of difference).
  Future<void> _syncTime() async {
    try {
      final request = http.Request('GET', Uri.parse('$_base/pulse/time'))
        ..headers.addAll(clientHeaders(platform: clientPlatformName()));
      final data = await _post(request);
      final server = (data['data'] as Map?)?['serverTime'];
      if (server is String) {
        final parsed = DateTime.tryParse(server);
        if (parsed != null) clock.accept(parsed);
      }
    } catch (_) {
      // The device clock is used as is; a large difference is answered with the server time.
    }
  }

  Future<Map<String, dynamic>> _signed(
    String method,
    String path, {
    Map<String, dynamic>? json,
    Uint8List? bytes,
    Map<String, String> headers = const {},
  }) => withDeviceLock(() async {
    final state = await read();
    if (state == null) throw const PulseFailure('PULSE_KIOSK_INVALID');
    final counter = state.counter + 1;
    await _save(state.copyWith(counter: counter));
    final body =
        bytes ??
        Uint8List.fromList(utf8.encode(json == null ? '' : jsonEncode(json)));
    final timestamp = _timestamp();
    final signature = P256Key.fromPrivateBase64(state.privateKey).sign(
      pulseKioskSignatureMessage(
        method,
        '/pulse$path',
        timestamp,
        '$counter',
        sha256.convert(body).toString(),
      ),
    );
    final request = http.Request(method, Uri.parse('$_base/pulse$path'))
      ..headers.addAll(clientHeaders(platform: clientPlatformName()))
      ..headers.addAll({
        'X-Kiosk-Id': state.profile.kioskUUID,
        'X-Kiosk-Timestamp': timestamp,
        'X-Kiosk-Counter': '$counter',
        'X-Kiosk-Signature': signature,
        if (bytes != null) 'content-type': 'image/jpeg',
        if (json != null) 'content-type': 'application/json',
        ...headers,
      });
    if (method != 'GET') request.bodyBytes = body;
    return _post(request);
  });

  /// Profile and official time; a revoked kiosk answers PULSE_KIOSK_INVALID.
  Future<KioskProfile> me() async {
    final data = await _signed('GET', '/kiosk/me');
    final item = (data['data'] as Map?)?['item'];
    final profile = KioskProfile.fromJson(
      item is Map<String, dynamic> ? item : const {},
    );
    final state = await read();
    if (state != null && profile.kioskUUID.isNotEmpty) {
      await withDeviceLock(() async {
        final current = await read();
        if (current != null) await _save(current.copyWith(profile: profile));
      });
    }
    return profile;
  }

  Future<KioskEmployee> identify(String loginCode, String pin) async {
    final data = await _signed(
      'POST',
      '/kiosk/identify',
      json: {'loginCode': loginCode, 'pin': pin},
    );
    final item = (data['data'] as Map?)?['item'];
    return KioskEmployee.fromJson(
      item is Map<String, dynamic> ? item : const {},
    );
  }

  /// Records the mark; returns the recorded punch (NSR, hash) and the employee after it.
  Future<({Map<String, dynamic> punch, KioskEmployee employee})> punch({
    required String loginCode,
    required String pin,
    required String idempotencyKey,
    required String type,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  }) async {
    final data = await _signed(
      'POST',
      '/kiosk/punches',
      json: {
        'loginCode': loginCode,
        'pin': pin,
        'idempotencyKey': idempotencyKey,
        'type': type,
        'occurredAt': clock.nowUtc().toIso8601String(),
        'latitude': ?latitude,
        'longitude': ?longitude,
        'accuracyMeters': ?accuracyMeters,
      },
    );
    final body = data['data'] as Map?;
    final item = body?['item'];
    final employee = body?['employee'];
    return (
      punch: item is Map<String, dynamic> ? item : <String, dynamic>{},
      employee: KioskEmployee.fromJson(
        employee is Map<String, dynamic> ? employee : const {},
      ),
    );
  }

  /// Receipt of a mark this time clock collected (CPF masked).
  Future<Map<String, dynamic>> receipt(String punchUUID) async {
    final data = await _signed('GET', '/kiosk/punches/$punchUUID/receipt');
    final item = (data['data'] as Map?)?['item'];
    return item is Map<String, dynamic> ? item : <String, dynamic>{};
  }

  /// Sends the receipt to the registry e-mail of the employee; answers the masked recipient.
  Future<String?> emailReceipt(String punchUUID) async {
    final data = await _signed(
      'POST',
      '/kiosk/punches/$punchUUID/receipt/email',
      json: const {},
    );
    return ((data['data'] as Map?)?['item'] as Map?)?['EmailRecipient']
        ?.toString();
  }

  Future<void> uploadPhoto(
    String punchUUID,
    String photoUUID,
    Uint8List bytes,
  ) => _signed(
    'POST',
    '/kiosk/punches/$punchUUID/photo',
    bytes: bytes,
    headers: {'X-Photo-Id': photoUUID},
  );
}
