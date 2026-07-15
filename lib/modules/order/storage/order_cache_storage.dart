import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OrderCacheStorage {
  static const _storage = FlutterSecureStorage();
  static const String _keyOrders = 'cache_orders_data';

  static Future<void> saveOrders(Map<String, dynamic> jsonResponse) async {
    try {
      await _storage.write(key: _keyOrders, value: jsonEncode(jsonResponse));
    } catch (e) {
      log('OrderCacheStorage saveOrders error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getOrders() async {
    try {
      final jsonStr = await _storage.read(key: _keyOrders);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      log('OrderCacheStorage getOrders error: $e');
      return null;
    }
  }

  static Future<void> clearOrders() async {
    try {
      await _storage.delete(key: _keyOrders);
    } catch (e) {
      log('OrderCacheStorage clearOrders error: $e');
    }
  }
}
