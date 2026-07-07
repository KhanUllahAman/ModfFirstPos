import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modfirstpos/core/contants/storage_keys.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> _write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> _read(String key) => _storage.read(key: key);

  static Future<void> _delete(String key) => _storage.delete(key: key);

  static Future<void> clearAll() => _storage.deleteAll();

  static Future<void> delete(String key) => _delete(key);

  static Future<void> saveAccessToken(String token) =>
      _write(StorageKeys.keyAccessToken, token);

  static Future<String?> getAccessToken() => _read(StorageKeys.keyAccessToken);

  static Future<void> deleteAccessToken() =>
      _delete(StorageKeys.keyAccessToken);

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

  static Future<void> deleteProfileData() => _delete(StorageKeys.keyProfileData);
}