import 'package:modfirstpos/core/database/key_value_store.dart';

/// Manually-configured Stripe Terminal reader settings (Settings screen).
/// The cashier registers the reader once (via Postman/`POST /terminal/readers`)
/// and enters its `reader_id` here — see docs/POS_PAYMENT_FLUTTER.md.
class StripeTerminalSettingsStorage {
  static const String _keyReaderId = 'stripe_terminal_reader_id';
  static const String _keySimulated = 'stripe_terminal_use_simulated';
  static const String _keyStripeReaderTmrId = 'stripe_terminal_reader_tmr_id';

  static Future<void> saveReaderId(String readerId) =>
      KeyValueStore.setJsonCache(_keyReaderId, {'value': readerId});

  static Future<String?> getReaderId() async {
    final data = await KeyValueStore.getJsonCache(_keyReaderId);
    return data?['value'] as String?;
  }

  /// The reader's actual Stripe id (e.g. "tmr_Gl78pgX7MSyoIw", from
  /// `POST /terminal/readers/list`) — needed only for the test-only
  /// "Simulate Card" helper, which talks to Stripe directly.
  static Future<void> saveStripeReaderTmrId(String tmrId) =>
      KeyValueStore.setJsonCache(_keyStripeReaderTmrId, {'value': tmrId});

  static Future<String?> getStripeReaderTmrId() async {
    final data = await KeyValueStore.getJsonCache(_keyStripeReaderTmrId);
    return data?['value'] as String?;
  }

  static Future<void> saveUseSimulated(bool useSimulated) =>
      KeyValueStore.setJsonCache(_keySimulated, {'value': useSimulated});

  static Future<bool> getUseSimulated() async {
    final data = await KeyValueStore.getJsonCache(_keySimulated);
    return (data?['value'] as bool?) ?? true;
  }
}
