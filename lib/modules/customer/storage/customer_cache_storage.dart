import 'package:modfirstpos/core/database/key_value_store.dart';

/// Customer list cache, backed by SQLite (offline-first).
class CustomerCacheStorage {
  static const String _keyCustomers = 'cache_customers_data';

  static Future<void> saveCustomers(Map<String, dynamic> jsonResponse) =>
      KeyValueStore.setJsonCache(_keyCustomers, jsonResponse);

  static Future<Map<String, dynamic>?> getCustomers() =>
      KeyValueStore.getJsonCache(_keyCustomers);

  static Future<void> clearCustomers() =>
      KeyValueStore.removeJsonCache(_keyCustomers);
}
