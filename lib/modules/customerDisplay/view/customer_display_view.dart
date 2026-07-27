// lib/modules/customerDisplay/view/customer_display_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';

class CustomerDisplayView extends StatelessWidget {
  const CustomerDisplayView({super.key});

  @override
  Widget build(BuildContext context) {
    final server = Get.find<CustomerDisplayServerService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final items = server.items;
          final symbol = server.currencySymbol.value;
          final storeName = server.storeName.value;

          if (!server.hasClient.value) {
            return const _WaitingForCashier();
          }

          if (items.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              if (storeName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'x${item.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '$symbol${item.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TotalsRow(
                      label: 'Subtotal',
                      value: '$symbol${server.subtotal.value.toStringAsFixed(2)}',
                      valueColor: Colors.white70,
                      labelColor: Colors.white54,
                      fontSize: 15,
                    ),
                    if (server.discount.value > 0)
                      _TotalsRow(
                        label: 'Discount',
                        value: '-$symbol${server.discount.value.toStringAsFixed(2)}',
                        valueColor: Colors.greenAccent,
                        labelColor: Colors.white54,
                        fontSize: 15,
                      ),
                    const SizedBox(height: 8),
                    _TotalsRow(
                      label: 'TOTAL',
                      value: '$symbol${server.total.value.toStringAsFixed(2)}',
                      valueColor: Colors.white,
                      labelColor: Colors.white,
                      fontSize: 28,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final double fontSize;
  final bool bold;

  const _TotalsRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    required this.fontSize,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.bold : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: fontSize, fontWeight: weight),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: fontSize, fontWeight: weight),
          ),
        ],
      ),
    );
  }
}

class _WaitingForCashier extends StatelessWidget {
  const _WaitingForCashier();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_tethering_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            'Waiting for cashier tab to connect...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            'Welcome!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
