import 'dart:developer';

import 'package:get/get.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:modfirstpos/modules/checkout/service/checkout_service.dart';

/// Wraps the Stripe Terminal SDK for the app's role in card-present payments:
/// connect to an **Internet reader** (Stripe WisePOS E / S700, or Stripe's
/// built-in simulated reader for testing without hardware — see
/// docs/POS_PAYMENT_FLUTTER.md section 2/3). Everything after that
/// (creating the PaymentIntent, sending it to the reader, capturing) is
/// driven entirely by the backend via plain REST — this service's only job
/// is to keep the reader connected so the backend can reach it.
class StripeTerminalService extends GetxService {
  final CheckoutService _service = CheckoutService();

  final RxBool isInitialized = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final Rxn<String> connectedReaderId = Rxn<String>();
  final RxString lastError = ''.obs;

  Future<bool> _ensureInitialized() async {
    if (Terminal.isInitialized) {
      isInitialized.value = true;
      return true;
    }
    try {
      await Terminal.init(
        fetchToken: () async {
          final token = await _service.fetchTerminalConnectionToken();
          if (token == null || token.isEmpty) {
            throw Exception('Could not fetch a Stripe Terminal connection token');
          }
          return token;
        },
      );
      isInitialized.value = true;
      return true;
    } catch (e) {
      log('StripeTerminalService init error: $e');
      lastError.value = 'Could not initialize Stripe Terminal: $e';
      return false;
    }
  }

  /// Discovers and connects to the first available Internet reader.
  /// [simulated] = true uses Stripe's built-in simulated reader (no physical
  /// hardware needed) — flip to false once a real reader is on the network.
  Future<bool> connect({required bool simulated}) async {
    if (isConnected.value && !isConnecting.value) return true;
    isConnecting.value = true;
    lastError.value = '';
    try {
      final ready = await _ensureInitialized();
      if (!ready) return false;

      final readers = await Terminal.instance
          .discoverReaders(InternetDiscoveryConfiguration(isSimulated: simulated))
          .first
          .timeout(const Duration(seconds: 15));

      if (readers.isEmpty) {
        lastError.value = simulated
            ? 'No simulated reader was returned by Stripe.'
            : 'No reader found on the network. Make sure it is powered on and online.';
        return false;
      }

      final reader = await Terminal.instance.connectReader(
        readers.first,
        configuration: InternetConnectionConfiguration(
          readerDelegate: _InternetReaderDelegate(onDisconnected: () {
            isConnected.value = false;
            connectedReaderId.value = null;
          }),
        ),
      );

      isConnected.value = true;
      connectedReaderId.value = reader.id;
      return true;
    } catch (e) {
      log('StripeTerminalService connect error: $e');
      lastError.value = 'Could not connect to the reader: $e';
      isConnected.value = false;
      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (Terminal.isInitialized) {
        await Terminal.instance.disconnectReader();
      }
    } catch (e) {
      log('StripeTerminalService disconnect error: $e');
    } finally {
      isConnected.value = false;
      connectedReaderId.value = null;
    }
  }
}

class _InternetReaderDelegate extends InternetReaderDelegate {
  final void Function() onDisconnected;
  _InternetReaderDelegate({required this.onDisconnected});

  @override
  void onDisconnect(DisconnectReason reason) => onDisconnected();
}
