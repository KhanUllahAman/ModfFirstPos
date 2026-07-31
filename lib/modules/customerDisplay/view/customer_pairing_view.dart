// lib/modules/customerDisplay/view/customer_pairing_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'ModFirst Customer Display',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Enter this IP in the cashier tab\'s Settings → Customer IP',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _localIp ?? 'Detecting IP...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      'And this pairing code → Settings → Customer Pairing Code',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        _server.pairingCode.value.isEmpty
                            ? '......'
                            : _server.pairingCode.value,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                        color: running ? Colors.greenAccent : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      running
                          ? 'Waiting for cashier tab to connect...'
                          : 'Starting...',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Get.toNamed('/customer-display'),
                child: const Text(
                  'Go to Display Screen',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
