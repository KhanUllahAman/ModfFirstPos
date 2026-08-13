// lib/modules/customerDisplay/view/customer_display_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';

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

          if (!server.hasClient.value) {
            return const _WaitingForCashier();
          }

          return Column(
            children: [
              const _DisplayHeader(),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyCart()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 24, color: ColorResources.cardBorderColor),
                        itemBuilder: (context, i) => _CartItemTile(
                          item: items[i],
                          symbol: symbol,
                        ),
                      ),
              ),
              if (items.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          valueColor: ColorResources.appMainColor,
                          labelColor: Colors.white54,
                          fontSize: 15,
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Colors.white24),
                      ),
                      _TotalsRow(
                        label: 'TOTAL',
                        value: '$symbol${server.total.value.toStringAsFixed(2)}',
                        valueColor: ColorResources.appMainColor,
                        labelColor: Colors.white,
                        fontSize: 30,
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

/// Store branding — the ModFirst logo, shown on every state (waiting, empty
/// cart, cart view) instead of a plain "ModFirst" text label.
class _DisplayHeader extends StatelessWidget {
  const _DisplayHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SvgPicture.asset(
        ImagesConstant.mJafferjeesLogo,
        height: 36,
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CustomerDisplayItem item;
  final String symbol;

  const _CartItemTile({required this.item, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[100],
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey, size: 24),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[100],
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.grey, size: 24),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.geistMono(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorResources.blackColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'x${item.quantity}',
          style: AppFonts.geistMono(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 20),
        Text(
          '$symbol${item.total.toStringAsFixed(2)}',
          style: AppFonts.geistMono(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorResources.blackColor,
          ),
        ),
      ],
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
    final weight = bold ? FontWeight.w800 : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.geistMono(color: labelColor, fontSize: fontSize, fontWeight: weight),
          ),
          Text(
            value,
            style: AppFonts.geistMono(color: valueColor, fontSize: fontSize, fontWeight: weight),
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
    return Column(
      children: [
        const _DisplayHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_tethering_rounded, size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(
                  'Waiting for cashier tab to connect...',
                  style: AppFonts.geistMono(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
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
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Welcome!',
            style: AppFonts.geistMono(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
