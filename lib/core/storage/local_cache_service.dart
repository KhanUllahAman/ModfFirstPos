import 'package:modfirstpos/modules/category/storage/category_cache_storage.dart';
import 'package:modfirstpos/modules/order/storage/order_cache_storage.dart';
import 'package:modfirstpos/modules/product/storage/product_cache_storage.dart';

class LocalCacheService {
  static Future<void> saveCategoriesCache(Map<String, dynamic> jsonResponse) async {
    await CategoryCacheStorage.saveCategories(jsonResponse);
  }

  static Future<Map<String, dynamic>?> getCategoriesCache() async {
    return await CategoryCacheStorage.getCategories();
  }

  static Future<void> saveProductsCache(int categoryId, Map<String, dynamic> jsonResponse) async {
    await ProductCacheStorage.saveProductsForCategory(categoryId, jsonResponse);
  }

  static Future<Map<String, dynamic>?> getProductsCache(int categoryId) async {
    return await ProductCacheStorage.getProductsForCategory(categoryId);
  }

  static Future<void> saveOrdersCache(Map<String, dynamic> jsonResponse) async {
    await OrderCacheStorage.saveOrders(jsonResponse);
  }

  static Future<Map<String, dynamic>?> getOrdersCache() async {
    return await OrderCacheStorage.getOrders();
  }

  static Future<void> clearAllCache() async {
    await CategoryCacheStorage.clearCategories();
    await OrderCacheStorage.clearOrders();
  }
}
