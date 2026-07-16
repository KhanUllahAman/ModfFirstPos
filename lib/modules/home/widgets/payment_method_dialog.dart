import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

/// Payment method picker: Cash / Stripe / PayPal.
class PaymentMethodDialog extends StatelessWidget {
  final HomeController controller;
  const PaymentMethodDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, HomeController controller) {
    if (controller.cartItems.isEmpty) {
      customSnackBar(
        'Empty Cart',
        'Add items to the cart before taking a payment',
        snackBarType: SnackBarType.warning,
      );
      return Future.value();
    }
    return showAppFadeDialog(
      context,
      barrierDismissible: true,
      barrierLabel: 'Payment Method',
      builder: (_) => PaymentMethodDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.34),
        vertical: context.responsiveHeight(0.1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.02),
          vertical: context.responsiveHeight(0.025),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Payment Method',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorResources.labelColor,
              ),
            ),
            Obx(
              () => Text(
                'Payable: Rs. ${controller.balance.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: AppFonts.geistMono(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(
              height: context.responsiveHeight(0.03),
              color: ColorResources.cardBorderColor,
            ),
            _PaymentMethodTile(
              icon: Iconsax.money_3,
              label: 'Cash',
              subtitle: 'Take cash on the POS keypad',
              onTap: () {
                Navigator.of(context).pop();
                controller.openCashPayment();
              },
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Iconsax.card,
              label: 'Stripe',
              subtitle: 'Card payment via Stripe',
              onTap: () => _notAvailable(context, 'Stripe'),
            ),
            const SizedBox(height: 8),
            _PaymentMethodTile(
              icon: Iconsax.wallet_3,
              label: 'PayPal',
              subtitle: 'Online payment via PayPal',
              onTap: () => _notAvailable(context, 'PayPal'),
            ),
          ],
        ),
      ),
    );
  }

  void _notAvailable(BuildContext context, String method) {
    Navigator.of(context).pop();
    customSnackBar(
      '$method Unavailable',
      '$method payments are not configured for this store yet',
      snackBarType: SnackBarType.info,
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Material(
        color: theme.secondaryColor.value.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.secondaryColor.value),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppFonts.geistMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppFonts.geistMono(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
