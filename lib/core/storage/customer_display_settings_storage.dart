import 'package:modfirstpos/core/database/key_value_store.dart';

/// The pairing code typed into the cashier's Settings screen (copied from
/// the customer tab's pairing screen) — required by
/// [CustomerDisplayServerService] before it'll accept a connection.
class CustomerDisplaySettingsStorage {
  static const String _keyPairingCode = 'customer_display_saved_pairing_code';

  static Future<void> savePairingCode(String code) =>
      KeyValueStore.setString(_keyPairingCode, code);

  static Future<String?> getPairingCode() =>
      KeyValueStore.getString(_keyPairingCode);
}
