import 'package:modfirstpos/core/services/website_settings_storage_service.dart';

/// Central money formatting for the whole app.
///
/// Prices render as `12.50 USD` (amount followed by the currency code).
/// The code comes from the cached website settings and falls back to USD;
/// call [load] at startup / after a settings refresh.
class CurrencyUtils {
  CurrencyUtils._();

  static String code = 'USD';

  static Future<void> load() async {
    final stored = await WebsiteSettingsStorageService.getCurrency();
    if (stored != null && stored.trim().isNotEmpty) {
      code = stored.trim().toUpperCase();
    }
  }

  static String format(num amount, {int decimals = 2}) =>
      '${amount.toStringAsFixed(decimals)} $code';
}
