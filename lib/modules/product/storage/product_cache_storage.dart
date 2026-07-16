import 'package:modfirstpos/core/database/key_value_store.dart';

/// Per-category product list cache, backed by SQLite (offline-first).
class ProductCacheStorage {
  static String _keyCategoryProducts(int catId) =>
      'cache_category_${catId}_products_data';

  static Future<void> saveProductsForCategory(
    int categoryId,
    Map<String, dynamic> jsonResponse,
  ) =>
      KeyValueStore.setJsonCache(
        _keyCategoryProducts(categoryId),
        jsonResponse,
      );

  static Future<Map<String, dynamic>?> getProductsForCategory(
    int categoryId,
  ) =>
      KeyValueStore.getJsonCache(_keyCategoryProducts(categoryId));

  static Future<void> clearProductsForCategory(int categoryId) =>
      KeyValueStore.removeJsonCache(_keyCategoryProducts(categoryId));

  static Future<void> clearAll() =>
      KeyValueStore.removeJsonCacheByPrefix('cache_category_');
}
