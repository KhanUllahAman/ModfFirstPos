import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/suspended_order_model.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

/// "Options" dialog on the POS home screen: Suspend / Resume / Void order.
class OrderOptionsDialog extends StatelessWidget {
  final HomeController controller;
  const OrderOptionsDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, HomeController controller) {
    return showAppFadeDialog(
      context,
      barrierDismissible: true,
      barrierLabel: 'Order Options',
      builder: (_) => OrderOptionsDialog(controller: controller),
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
              'Order Options',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorResources.labelColor,
              ),
            ),
            Divider(
              height: context.responsiveHeight(0.03),
              color: ColorResources.cardBorderColor,
            ),
            _OptionTile(
              icon: Iconsax.pause,
              label: 'Suspend Order',
              subtitle: 'Park the current sale to resume later',
              onTap: () async {
                Navigator.of(context).pop();
                await controller.suspendCurrentOrder();
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Iconsax.play,
              label: 'Resume Order',
              subtitle: 'Restore a previously suspended sale',
              onTap: () {
                Navigator.of(context).pop();
                ResumeOrderDialog.show(context, controller);
              },
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Iconsax.trash,
              label: 'Void Order',
              subtitle: 'Cancel the current sale entirely',
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                AppDialog.showConfirm(
                  context,
                  title: 'Void Order',
                  message: 'Are you sure you want to void this order?',
                  subMessage: 'The cart, customer and totals will be cleared.',
                  yesText: 'Confirm',
                  noText: 'Cancel',
                  yesButtonColor: ColorResources.gradientRed,
                  onYes: controller.voidCurrentOrder,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final accent = isDestructive
          ? ColorResources.gradientRed
          : theme.secondaryColor.value;
      return Material(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accent),
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
      );
    });
  }
}

/// Lists all suspended sessions; tapping one restores it exactly as it was.
class ResumeOrderDialog extends StatelessWidget {
  final HomeController controller;
  const ResumeOrderDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, HomeController controller) {
    controller.loadSuspendedOrders();
    return showAppFadeDialog(
      context,
      barrierDismissible: true,
      barrierLabel: 'Resume Order',
      builder: (_) => ResumeOrderDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.30),
        vertical: context.responsiveHeight(0.08),
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
              'Suspended Orders',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ColorResources.labelColor,
              ),
            ),
            Divider(
              height: context.responsiveHeight(0.03),
              color: ColorResources.cardBorderColor,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: context.responsiveHeight(0.45),
              ),
              child: Obx(() {
                final orders = controller.suspendedOrders;
                if (orders.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveHeight(0.04),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.receipt_minus,
                          size: 36,
                          color: ColorResources.blackColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No suspended orders',
                          textAlign: TextAlign.center,
                          style: AppFonts.geistMono(
                            fontSize: 12,
                            color: ColorResources.blackColor.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _SuspendedOrderTile(
                    order: orders[i],
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.resumeSuspendedOrder(orders[i]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuspendedOrderTile extends StatelessWidget {
  final SuspendedOrderModel order;
  final VoidCallback onTap;

  const _SuspendedOrderTile({required this.order, required this.onTap});

  String get _formattedTime {
    final parsed = DateTime.tryParse(order.createdAt);
    if (parsed == null) return '';
    return DateFormat('dd MMM, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Material(
        color: theme.secondaryColor.value.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Iconsax.receipt_1,
                    size: 20, color: theme.secondaryColor.value),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customer?.displayName ?? 'Walk-in Customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.geistMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.itemCount} items • $_formattedTime',
                        style: AppFonts.geistMono(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyUtils.format(order.total, decimals: 2),
                  style: AppFonts.geistMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.secondaryColor.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
