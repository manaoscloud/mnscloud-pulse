import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small secrets kept by the platform secure storage (Keychain, Android Keystore, libsecret,
/// Windows Credential Manager; WebCrypto-encrypted storage on the web): the device key with its
/// counter and grant, the local database key, the native refresh token and the offline profile.
/// Nothing here is written to SQLite or to plain files.
abstract class SecretVault {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// Replaced by [MemoryVault] in tests (no platform channel there).
  static SecretVault instance = SecureStorageVault();
}

class SecureStorageVault implements SecretVault {
  SecureStorageVault([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Already gone or storage unavailable.
    }
  }
}

class MemoryVault implements SecretVault {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
