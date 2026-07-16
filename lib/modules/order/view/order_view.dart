import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/widgets/order_narrow_layout.dart';
import 'package:modfirstpos/modules/order/widgets/order_wide_layout.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/pos_side_nav.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600 ||
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: false),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PosSideNav(currentRouteOverride: Routes.order),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackBar(title: 'Orders'),
                    SizedBox(height: context.spacingSM),
                    Obx(() {
                      final customer = controller.currentFilterCustomer.value;
                      if (customer == null) return const SizedBox.shrink();

                      final theme = Get.find<AppThemeService>();
                      final inCart = controller.isCustomerInCart;

                      return Container(
                        margin: EdgeInsets.only(bottom: context.spacingSM),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.value.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.primaryColor.value.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: theme.primaryColor.value,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.fullName ?? 'Unnamed Customer',
                                    style: AppFonts.geistMono(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.fontSM,
                                      color: ColorResources.labelColor,
                                    ),
                                  ),
                                  Text(
                                    customer.email ?? 'No email',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontXS,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.toggleCustomerInCart();
                              },
                              icon: Icon(
                                inCart ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                size: 16,
                              ),
                              label: Text(
                                inCart ? 'Remove from cart' : 'Add this user to cart',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: inCart
                                    ? ColorResources.gradientRed
                                    : theme.secondaryColor.value,
                                foregroundColor: inCart ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                            if (inCart) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.offAllNamed(Routes.home);
                                },
                                icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
                                label: Text(
                                  'Go to cart',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontXS,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor.value,
                                  foregroundColor: theme.onPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ],
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.grey),
                              onPressed: () {
                                controller.currentFilterCustomer.value = null;
                                controller.searchQuery.value = '';
                                controller.searchController.clear();
                                controller.loadOrders(isRefresh: true);
                              },
                              tooltip: 'Clear Filter',
                            ),
                          ],
                        ),
                      );
                    }),
                    Expanded(
                      child: isWide
                          ? const OrderWideLayout()
                          : const OrderNarrowLayout(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).noKeyboard();
  }
}
