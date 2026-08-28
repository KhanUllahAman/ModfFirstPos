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
      lastError.value = _formatErrorMessage(e);
      return false;
    }
  }

  /// Discovers and connects to the physical Internet reader on the network.
  Future<bool> connect() async {
    if (isConnected.value && !isConnecting.value) return true;
    isConnecting.value = true;
    lastError.value = '';
    try {
      final ready = await _ensureInitialized();
      if (!ready) return false;

      final readers = await Terminal.instance
          .discoverReaders(
            const InternetDiscoveryConfiguration(isSimulated: false),
          )
          .first
          .timeout(const Duration(seconds: 15));

      if (readers.isEmpty) {
        lastError.value =
            'No card reader found on the network. Please make sure the reader is powered on, active, and on the same Wi-Fi.';
        return false;
      }

      final reader = await Terminal.instance.connectReader(
        readers.first,
        configuration: InternetConnectionConfiguration(
          readerDelegate: _InternetReaderDelegate(
            onDisconnected: () {
              isConnected.value = false;
              connectedReaderId.value = null;
            },
          ),
        ),
      );

      isConnected.value = true;
      connectedReaderId.value = reader.id;
      return true;
    } catch (e) {
      log('StripeTerminalService connect error: $e');
      lastError.value = _formatErrorMessage(e);
      isConnected.value = false;
      return false;
    } finally {
      isConnecting.value = false;
    }
  }

  String _formatErrorMessage(Object error) {
    final str = error.toString().toLowerCase();
    if (str.contains('timeout') ||
        str.contains('socket closed') ||
        str.contains('readercommunicationerror') ||
        str.contains('econnrefused') ||
        str.contains('connection refused') ||
        str.contains('broken pipe')) {
      return 'Card reader is offline or unreachable. Please ensure the physical reader is powered on, active, and connected to the same Wi-Fi network.';
    }
    if (str.contains('no reader') || str.contains('noreaderfound')) {
      return 'No card reader found on the network. Please check that the reader is powered on and connected to Wi-Fi.';
    }
    if (str.contains('busy') ||
        str.contains('inuse') ||
        str.contains('already connected') ||
        str.contains('conflict')) {
      return 'The card reader is currently busy or in use. Please wait a moment and try again.';
    }
    if (str.contains('token') ||
        str.contains('connectiontoken') ||
        str.contains('unauthorized') ||
        str.contains('authentication')) {
      return 'Failed to authenticate with Stripe Terminal. Please check your internet connection.';
    }
    if (str.contains('location') || str.contains('permission')) {
      return 'Location or network permission is required to connect to the card reader.';
    }
    if (str.contains('bluetooth')) {
      return 'Bluetooth connection failed. Please ensure Bluetooth is enabled on the device.';
    }
    return 'Could not connect to the card reader. Please ensure it is powered on, connected to Wi-Fi, and try again.';
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
