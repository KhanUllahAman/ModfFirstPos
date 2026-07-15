import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoryCacheStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyCategories = 'cache_categories_data';

  static Future<void> saveCategories(Map<String, dynamic> jsonResponse) async {
    try {
      await _storage.write(key: _keyCategories, value: jsonEncode(jsonResponse));
    } catch (e) {
      log('CategoryCacheStorage saveCategories error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCategories() async {
    try {
      final jsonStr = await _storage.read(key: _keyCategories);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      log('CategoryCacheStorage getCategories error: $e');
      return null;
    }
  }

  static Future<void> clearCategories() async {
    try {
      await _storage.delete(key: _keyCategories);
    } catch (e) {
      log('CategoryCacheStorage clearCategories error: $e');
    }
  }
}
