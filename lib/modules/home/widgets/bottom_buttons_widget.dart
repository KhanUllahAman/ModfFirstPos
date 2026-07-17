import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/widgets/order_options_dialog.dart';
import 'package:modfirstpos/modules/checkout/controller/checkout_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class BottomButtons extends StatelessWidget {
  final HomeController controller;
  const BottomButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => OrderOptionsDialog.show(context, controller),
              isLoading: false,
              backgroundColor: theme.primaryColor.value,
              borderRadius: 10,
              child: Text(
                'Options',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: theme.onPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.015)),
          Expanded(
            child: AppButton(
              backgroundColor: theme.secondaryColor.value,
              onPressed: () {
                if (controller.cartItems.isEmpty) {
                  customSnackBar(
                    'Empty Cart',
                    'Add items to the cart before taking a payment',
                    snackBarType: SnackBarType.warning,
                  );
                  return;
                }
                final customer = controller.selectedCartCustomer.value;
                if (customer == null) {
                  customSnackBar(
                    'Customer Required',
                    'Please select a customer first to proceed to delivery/pickup options.',
                    snackBarType: SnackBarType.warning,
                  );
                  controller.showCustomerPanel.value = true;
                  return;
                }
                final checkoutController = Get.find<CheckoutController>();
                checkoutController.startCheckoutFlow(customer.id);
                controller.showCheckoutPanel.value = true;
              },
              isLoading: false,
              borderRadius: 10,
              child: Text(
                'Payment',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w500,
                  color: theme.onSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
