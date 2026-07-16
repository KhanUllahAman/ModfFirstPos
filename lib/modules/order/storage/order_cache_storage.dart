import 'package:modfirstpos/core/database/key_value_store.dart';

/// Order list cache, backed by SQLite (offline-first).
class OrderCacheStorage {
  static const String _keyOrders = 'cache_orders_data';

  static Future<void> saveOrders(Map<String, dynamic> jsonResponse) =>
      KeyValueStore.setJsonCache(_keyOrders, jsonResponse);

  static Future<Map<String, dynamic>?> getOrders() =>
      KeyValueStore.getJsonCache(_keyOrders);

  static Future<void> clearOrders() =>
      KeyValueStore.removeJsonCache(_keyOrders);
}
