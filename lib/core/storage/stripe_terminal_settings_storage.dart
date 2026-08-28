import 'package:modfirstpos/core/database/key_value_store.dart';

/// Manually-configured Stripe Terminal reader settings (Settings screen).
/// The cashier registers the reader once and enters its `reader_id` here.
class StripeTerminalSettingsStorage {
  static const String _keyReaderId = 'stripe_terminal_reader_id';

  static const String defaultReaderId = '1';

  static Future<void> saveReaderId(String readerId) =>
      KeyValueStore.setJsonCache(_keyReaderId, {'value': readerId});

  static Future<String?> getReaderId() async {
    final data = await KeyValueStore.getJsonCache(_keyReaderId);
    final value = data?['value'] as String?;
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    await saveReaderId(defaultReaderId);
    return defaultReaderId;
  }

  /// Ensures readerId is initialized with default ('1') so first-time
  /// logins/runs immediately work without manually visiting Settings.
  static Future<void> ensureDefaults() async {
    final readerIdData = await KeyValueStore.getJsonCache(_keyReaderId);
    final readerId = readerIdData?['value'] as String?;
    if (readerId == null || readerId.trim().isEmpty) {
      await saveReaderId(defaultReaderId);
    }
  }
}
