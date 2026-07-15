import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomerCacheStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyCustomers = 'cache_customers_data';

  static Future<void> saveCustomers(Map<String, dynamic> jsonResponse) async {
    try {
      await _storage.write(key: _keyCustomers, value: jsonEncode(jsonResponse));
    } catch (e) {
      log('CustomerCacheStorage saveCustomers error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCustomers() async {
    try {
      final jsonStr = await _storage.read(key: _keyCustomers);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      log('CustomerCacheStorage getCustomers error: $e');
      return null;
    }
  }

  static Future<void> clearCustomers() async {
    try {
      await _storage.delete(key: _keyCustomers);
    } catch (e) {
      log('CustomerCacheStorage clearCustomers error: $e');
    }
  }
}
