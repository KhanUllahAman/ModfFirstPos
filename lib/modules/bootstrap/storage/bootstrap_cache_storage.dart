import 'package:modfirstpos/core/database/key_value_store.dart';

/// Caches the full pos/bootstrap payload (store/branch/categories/products/
/// variants/inventory/pickup-locations/etc) as a single JSON blob — the
/// offline-first source of truth for the whole POS while a shift is open.
class BootstrapCacheStorage {
  static const String _keyBootstrap = 'cache_pos_bootstrap_data';

  static Future<void> saveBootstrap(Map<String, dynamic> payloadJson) =>
      KeyValueStore.setJsonCache(_keyBootstrap, payloadJson);

  static Future<Map<String, dynamic>?> getBootstrap() =>
      KeyValueStore.getJsonCache(_keyBootstrap);

  static Future<void> clearBootstrap() =>
      KeyValueStore.removeJsonCache(_keyBootstrap);
}
