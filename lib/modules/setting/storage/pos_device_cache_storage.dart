import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';

/// Caches the last-known POS device for this terminal (offline-first), so
/// the print flow can read the printer's IP without hitting the network.
class PosDeviceCacheStorage {
  static const String _keyDevice = 'cache_pos_device_data';

  static Future<void> saveDevice(PosDeviceModel device) =>
      KeyValueStore.setJsonCache(_keyDevice, device.toCacheJson());

  static Future<PosDeviceModel?> getDevice() async {
    final data = await KeyValueStore.getJsonCache(_keyDevice);
    if (data == null) return null;
    return PosDeviceModel.fromJson(data);
  }

  static Future<void> clearDevice() => KeyValueStore.removeJsonCache(_keyDevice);
}
