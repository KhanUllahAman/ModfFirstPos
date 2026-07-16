import 'package:modfirstpos/core/database/key_value_store.dart';

/// Category list cache, backed by SQLite (offline-first).
class CategoryCacheStorage {
  static const String _keyCategories = 'cache_categories_data';

  static Future<void> saveCategories(Map<String, dynamic> jsonResponse) =>
      KeyValueStore.setJsonCache(_keyCategories, jsonResponse);

  static Future<Map<String, dynamic>?> getCategories() =>
      KeyValueStore.getJsonCache(_keyCategories);

  static Future<void> clearCategories() =>
      KeyValueStore.removeJsonCache(_keyCategories);
}
