import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modfirstpos/core/contants/storage_keys.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> _write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> _read(String key) => _storage.read(key: key);

  static Future<void> _delete(String key) => _storage.delete(key: key);

  /// Wipes all secure-storage values on logout — EXCEPT the DB encryption
  /// key, which must survive logout/login cycles or the local SQLite
  /// database becomes unreadable (wrong/missing passphrase).
  static Future<void> clearAll() async {
    final dbKey = await getOrCreateDbEncryptionKey();
    await _storage.deleteAll();
    await _write(StorageKeys.keyDbEncryptionKey, dbKey);
  }

  /// The local SQLite database's SQLCipher passphrase. Generated once (256
  /// bits of secure randomness) on first app run and kept in Keystore/
  /// Keychain for the lifetime of the install — never sent to the server,
  /// never logged.
  static Future<String> getOrCreateDbEncryptionKey() async {
    final existing = await _read(StorageKeys.keyDbEncryptionKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final randomBytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final key = base64UrlEncode(randomBytes);
    await _write(StorageKeys.keyDbEncryptionKey, key);
    return key;
  }

  /// Per-device random salt for [PinHashUtil] — generated once, reused for
  /// the lifetime of the install (or until logout wipes it, at which point
  /// the next saved PIN hash gets a fresh one together with it).
  static Future<String> getOrCreatePinSalt() async {
    final existing = await _read(StorageKeys.keyPinSalt);
    if (existing != null && existing.isNotEmpty) return existing;

    final randomBytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final salt = base64UrlEncode(randomBytes);
    await _write(StorageKeys.keyPinSalt, salt);
    return salt;
  }

  static Future<void> delete(String key) => _delete(key);

  static Future<void> saveAccessToken(String token) =>
      _write(StorageKeys.keyAccessToken, token);

  static Future<String?> getAccessToken() => _read(StorageKeys.keyAccessToken);

  static Future<void> deleteAccessToken() =>
      _delete(StorageKeys.keyAccessToken);

  static Future<void> saveRefreshToken(String token) =>
      _write(StorageKeys.keyRefreshToken, token);

  static Future<String?> getRefreshToken() =>
      _read(StorageKeys.keyRefreshToken);

  static Future<void> deleteRefreshToken() =>
      _delete(StorageKeys.keyRefreshToken);

  static Future<void> saveLoginEmail(String email) =>
      _write(StorageKeys.keyLoginEmail, email);

  static Future<String?> getLoginEmail() => _read(StorageKeys.keyLoginEmail);

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveProfileData(Map<String, dynamic> profileJson) =>
      _write(StorageKeys.keyProfileData, jsonEncode(profileJson));

  static Future<Map<String, dynamic>?> getProfileData() async {
    final data = await _read(StorageKeys.keyProfileData);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSelectedStore(String storeSlug) =>
      _write(StorageKeys.keySelectedStoreSlug, storeSlug);

  static Future<String?> getSelectedStore() =>
      _read(StorageKeys.keySelectedStoreSlug);

  static Future<void> saveStoreSelectionDone() =>
      _write(StorageKeys.keyStoreSelectionDone, 'true');

  static Future<bool> isStoreSelectionDone() async {
    final data = await _read(StorageKeys.keyStoreSelectionDone);
    return data == 'true';
  }

  static Future<void> saveLastActiveAt(DateTime time) =>
      _write(StorageKeys.keyLastActiveAt, time.toIso8601String());

  static Future<DateTime?> getLastActiveAt() async {
    final data = await _read(StorageKeys.keyLastActiveAt);
    if (data == null) return null;
    return DateTime.tryParse(data);
  }

  static Future<void> saveWasLocked(bool locked) =>
      _write(StorageKeys.keyWasLocked, locked.toString());

  static Future<bool> getWasLocked() async {
    final data = await _read(StorageKeys.keyWasLocked);
    return data == 'true';
  }

  static Future<void> deleteProfileData() =>
      _delete(StorageKeys.keyProfileData);

  /// Salted hash of the current screen-lock PIN — lets unlocking work while
  /// offline without ever storing the PIN itself. Kept fresh whenever a PIN
  /// verify/set/change succeeds online.
  static Future<void> savePinHash(String hash) =>
      _write(StorageKeys.keyPinHash, hash);

  static Future<String?> getPinHash() => _read(StorageKeys.keyPinHash);

  static Future<void> deletePinHash() => _delete(StorageKeys.keyPinHash);
}
