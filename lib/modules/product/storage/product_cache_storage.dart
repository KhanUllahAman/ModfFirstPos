import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductCacheStorage {
  static const _storage = FlutterSecureStorage();
  static String _keyCategoryProducts(int catId) =>
      'cache_category_${catId}_products_data';

  static Future<void> saveProductsForCategory(
      int categoryId, Map<String, dynamic> jsonResponse) async {
    try {
      await _storage.write(
        key: _keyCategoryProducts(categoryId),
        value: jsonEncode(jsonResponse),
      );
    } catch (e) {
      log('ProductCacheStorage saveProductsForCategory error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getProductsForCategory(
      int categoryId) async {
    try {
      final jsonStr =
          await _storage.read(key: _keyCategoryProducts(categoryId));
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      log('ProductCacheStorage getProductsForCategory error: $e');
      return null;
    }
  }

  static Future<void> clearProductsForCategory(int categoryId) async {
    try {
      await _storage.delete(key: _keyCategoryProducts(categoryId));
    } catch (e) {
      log('ProductCacheStorage clearProductsForCategory error: $e');
    }
  }
}
