// lib/modules/customerDisplay/view/customer_pairing_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';

class CustomerPairingView extends StatefulWidget {
  const CustomerPairingView({super.key});

  @override
  State<CustomerPairingView> createState() => _CustomerPairingViewState();
}

class _CustomerPairingViewState extends State<CustomerPairingView> {
  final CustomerDisplayServerService _server =
      Get.find<CustomerDisplayServerService>();
  String? _localIp;
  Worker? _hasClientWorker;

  @override
  void initState() {
    super.initState();
    _server.start();
    _loadLocalIp();
    // As soon as the cashier tab connects, jump straight to the display.
    _hasClientWorker = ever<bool>(_server.hasClient, (connected) {
      if (connected && mounted) {
        Get.offNamed('/customer-display');
      }
    });
  }

  Future<void> _loadLocalIp() async {
    try {
      final ip = await NetworkInfo().getWifiIP();
      if (mounted) setState(() => _localIp = ip);
    } catch (_) {
      if (mounted) setState(() => _localIp = null);
    }
  }

  @override
  void dispose() {
    _hasClientWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // A SingleChildScrollView instead of a bare Center+Column — on a
        // short/landscape display the fixed-size cards below no longer fit
        // in the viewport height and this content used to overflow instead
        // of simply scrolling.
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorResources.appMainColor.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: ColorResources.appMainColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ModFirst Customer Display',
                    textAlign: TextAlign.center,
                    style: AppFonts.geistMono(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PairingInfoCard(
                    label: 'Enter this IP in the cashier tab\'s Settings → Customer IP',
                    value: _localIp ?? 'Detecting IP...',
                    valueColor: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  _PairingInfoCard(
                    label: 'And this pairing code → Settings → Customer Pairing Code',
                    value: _server.pairingCode,
                    valueColor: ColorResources.appMainColor,
                    letterSpacing: 4,
                  ),
                  const SizedBox(height: 28),
                  Obx(() {
                    final running = _server.isRunning.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: running
                                ? ColorResources.appMainColor
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          running
                              ? 'Waiting for cashier tab to connect...'
                              : 'Starting...',
                          style: AppFonts.geistMono(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => Get.toNamed('/customer-display'),
                    child: Text(
                      'Go to Display Screen',
                      style: AppFonts.geistMono(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass/frosted card matching the cashier app's lock-screen styling
/// (blurred, translucent, soft border) instead of a flat tinted box.
class _PairingInfoCard extends StatelessWidget {
  final String label;
  final Object value; // String or RxString
  final Color valueColor;
  final double letterSpacing;

  const _PairingInfoCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.letterSpacing = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppFonts.geistMono(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 10),
              value is RxString
                  ? Obx(() => _valueText((value as RxString).value))
                  : _valueText(value as String),
            ],
          ),
        ),
      ),
    );
  }

  Text _valueText(String text) {
    return Text(
      text.isEmpty ? '......' : text,
      style: AppFonts.geistMono(
        color: valueColor,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
