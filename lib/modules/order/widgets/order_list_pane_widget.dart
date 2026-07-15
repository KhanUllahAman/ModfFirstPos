import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/widgets/order_widgets.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class OrderListPaneWidget extends GetView<OrderController> {
  const OrderListPaneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingMD),
      decoration: BoxDecoration(
        color: ColorResources.homeBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderSearchField(controller: controller),
          SizedBox(height: context.spacingSM),
          OrderStatusFilterRow(controller: controller),
          SizedBox(height: context.spacingSM),
          OrderDropdownFilters(controller: controller),
          SizedBox(height: context.spacingSM),
          Expanded(child: _buildOrderList(context)),
          SizedBox(height: context.spacingSM),
          OrderPaginationControls(controller: controller),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorResources.appAccentColor,
          ),
        );
      }
      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No orders found',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              AppSyncButton(
                onPressed: () =>
                    controller.loadOrders(isRefresh: true),
                label: 'Retry / Reload',
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        );
      }
      return Scrollbar(
        controller: controller.orderListScrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: controller.orderListScrollController,
          primary: false,
          padding: const EdgeInsets.only(right: 8),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => SizedBox(height: context.spacingSM),
          itemBuilder: (_, index) {
            final order = controller.orders[index];
            return Obx(() {
              final isSelected =
                  controller.selectedOrder.value?.id == order.id;
              return OrderListItemCard(
                order: order,
                isSelected: isSelected,
                onTap: () => controller.selectOrder(order),
              );
            });
          },
        ),
      );
    });
  }
}
