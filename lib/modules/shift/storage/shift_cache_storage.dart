import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

/// Caches the last-known shift for this terminal (offline-first fallback
/// only — the server is always the source of truth for shift state).
class ShiftCacheStorage {
  static const String _keyShift = 'cache_pos_shift_data';

  static Future<void> saveShift(ShiftModel shift) =>
      KeyValueStore.setJsonCache(_keyShift, shift.toCacheJson());

  static Future<ShiftModel?> getShift() async {
    final data = await KeyValueStore.getJsonCache(_keyShift);
    if (data == null) return null;
    return ShiftModel.fromJson(data);
  }

  static Future<void> clearShift() => KeyValueStore.removeJsonCache(_keyShift);
}
