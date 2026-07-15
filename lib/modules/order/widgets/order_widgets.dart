import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class OrderSearchField extends StatelessWidget {
  final OrderController controller;
  const OrderSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: context.responsiveHeight(0.055),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: AppFonts.geistMono(
                fontSize: context.fontSM,
                color: ColorResources.labelColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search Order ID / Customer Name / Phone',
                hintStyle: AppFonts.geistMono(
                  fontWeight: FontWeight.w500,
                  fontSize: context.fontSM,
                  color: ColorResources.labelColor.withOpacity(0.5),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: ColorResources.blackColor,
                ),
                filled: true,
                fillColor: ColorResources.whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: ColorResources.cardBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: ColorResources.cardBorderColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.spacingSM,
                  vertical: context.spacingXS,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() => AppSyncButton(
              onPressed: controller.syncOrders,
              isLoading: controller.isLoading.value,
              label: 'Sync Orders',
              height: context.responsiveHeight(0.055),
            )),
      ],
    );
  }
}

class OrderStatusFilterRow extends StatelessWidget {
  final OrderController controller;
  const OrderStatusFilterRow({super.key, required this.controller});

  String _formatStatusLabel(String status) {
    if (status.toLowerCase() == 'all') return 'All';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        primary: false,
        scrollDirection: Axis.horizontal,
        itemCount: controller.statusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final rawStatus = controller.statusOptions[index];
          final formattedLabel = _formatStatusLabel(rawStatus);
          return Obx(() {
            final isSelected = controller.selectedStatus.value == rawStatus;
            return ChoiceChip(
              iconTheme: IconThemeData(color: theme.onPrimaryColor),
              label: Text(
                formattedLabel,
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.onPrimaryColor
                      : ColorResources.blackColor,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.primaryColor.value,
              backgroundColor: ColorResources.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : ColorResources.cardBorderColor,
                ),
              ),
              onSelected: (_) => controller.selectStatus(rawStatus),
            );
          });
        },
      ),
    );
  }
}

class OrderDropdownFilters extends StatelessWidget {
  final OrderController controller;
  const OrderDropdownFilters({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedPaymentStatus.value,
                decoration: InputDecoration(
                  labelText: 'Payment Status',
                  labelStyle: AppFonts.geistMono(
                    fontSize: 10,
                    color: ColorResources.labelColor,
                  ),
                  filled: true,
                  fillColor: ColorResources.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: ColorResources.cardBorderColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                ),
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  color: ColorResources.labelColor,
                ),
                items: controller.paymentStatusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'All' ? 'All' : value.toUpperCase(),
                      style: AppFonts.geistMono(fontSize: context.fontXS),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectPaymentStatus(val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 42,
            child: Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedDeliveryType.value,
                decoration: InputDecoration(
                  labelText: 'Delivery Type',
                  labelStyle: AppFonts.geistMono(
                    fontSize: 10,
                    color: ColorResources.labelColor,
                  ),
                  filled: true,
                  fillColor: ColorResources.whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: ColorResources.cardBorderColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                ),
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  color: ColorResources.labelColor,
                ),
                items: controller.deliveryTypeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'All'
                          ? 'All'
                          : value.replaceAll('_', ' ').toUpperCase(),
                      style: AppFonts.geistMono(fontSize: context.fontXS),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectDeliveryType(val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: controller.clearFilters,
          icon: const Icon(
            Icons.clear_all_rounded,
            size: 16,
            color: ColorResources.gradientRed,
          ),
          label: Text(
            'Clear',
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              color: ColorResources.gradientRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderPaginationControls extends StatelessWidget {
  final OrderController controller;
  const OrderPaginationControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.orders.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${controller.totalCount.value} orders',
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    controller.hasPrev.value ? controller.prevPage : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                color: ColorResources.appAccentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${controller.currentPage.value} / ${controller.totalPages.value}',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed:
                    controller.hasNext.value ? controller.nextPage : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                color: ColorResources.appAccentColor,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class OrderListItemCard extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderListItemCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final formattedDate = _formatDate(order.orderDate);
    final total = double.tryParse(order.totalAmount ?? '0') ?? 0.0;
    final isPaid = (order.paymentStatus?.toLowerCase() == 'paid');
    final isHomeDelivery = (order.deliveryType?.toLowerCase() == 'home_delivery');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(context.spacingSM),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.secondaryColor.value.withOpacity(0.08)
              : ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.secondaryColor.value
                : ColorResources.cardBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.secondaryColor.value.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber ?? 'ORD-UNKNOWN',
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                _buildStatusPill(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.fullName ?? 'Walk-in Customer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: context.fontSM,
                      fontWeight: FontWeight.w600,
                      color: ColorResources.labelColor.withOpacity(0.85),
                    ),
                  ),
                ),
                Obx(() => Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor.value,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: AppFonts.geistMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isPaid ? '• Paid' : '• Pending Payment',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPaid
                            ? ColorResources.successGreen
                            : ColorResources.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHomeDelivery ? '• Delivery' : '• Pickup',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String? status) {
    final color = _getStatusColor(status);
    final formatted = _formatStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formatted,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'UNKNOWN';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}

Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'booked':
    case 'accepted':
      return ColorResources.blueColor;
    case 'preparing':
    case 'design_review':
    case 'label_create':
      return ColorResources.warningOrange;
    case 'shipped':
    case 'ready_for_pickup':
      return ColorResources.appMainColorLight;
    case 'completed':
      return ColorResources.successGreen;
    case 'cancelled':
      return ColorResources.gradientRed;
    default:
      return Colors.grey;
  }
}
