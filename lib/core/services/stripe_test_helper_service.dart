import 'dart:developer';

import 'package:dio/dio.dart';

/// TEST-ONLY helper that calls Stripe's Terminal test-helper API directly
/// from the app, so a simulated reader's card-present flow can be verified
/// end-to-end before the backend exposes a dedicated endpoint for it
/// (docs/POS_PAYMENT_FLUTTER.md — see the "simulate-card-present" backend
/// request). Requires a Stripe **test** secret key (sk_test_...), entered
/// once in Settings and kept only in this device's secure storage — never
/// bundled into the app, never sent to our own backend, never in git.
class StripeTestHelperService {
  final Dio _dio = Dio();

  /// Simulates a card being presented on [stripeReaderId] (Stripe's own
  /// reader id, e.g. "tmr_Gl78pgX7MSyoIw" — not the backend's numeric
  /// reader_id). See
  /// https://docs.stripe.com/api/terminal/readers/present_payment_method
  Future<bool> simulateCardPresent({
    required String stripeReaderId,
    required String secretKey,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.stripe.com/v1/test_helpers/terminal/readers/$stripeReaderId/present_payment_method',
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      }
      log('StripeTestHelperService simulateCardPresent failed: '
          '${response.statusCode} ${response.data}');
      return false;
    } catch (e) {
      log('StripeTestHelperService simulateCardPresent error: $e');
      return false;
    }
  }
}
