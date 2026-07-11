// lib/modules/customerDisplay/view/customer_pairing_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerPairingView extends StatelessWidget {
  const CustomerPairingView({super.key});

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
              const SizedBox(height: 8),
              const Text(
                'Customer App — Test Build',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Get.toNamed('/customer-display'),
                child: const Text('Go to Display Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}