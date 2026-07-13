import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(
        showMenuIcon: true,
        onMenuPressed: () {
          Get.back();
        },
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackBar(title: "Orders"),
              SizedBox(height: context.spacingSM),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Pane - Order List, Search & Filters
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.homeBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorResources.cardBorderColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSearchField(context),
                            SizedBox(height: context.spacingSM),
                            _buildStatusFilterRow(context),
                            SizedBox(height: context.spacingSM),
                            _buildDropdownFilters(context),
                            SizedBox(height: context.spacingSM),
                            Expanded(child: _buildOrderList(context)),
                            SizedBox(height: context.spacingSM),
                            _buildPaginationControls(context),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveWidth(0.02)),
                    // Right Pane - Selected Order Details
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorResources.cardBorderColor,
                          ),
                        ),
                        child: Obx(() {
                          final order = controller.selectedOrder.value;
                          if (order == null) {
                            return _buildEmptyState(context);
                          }
                          return _buildOrderDetails(context, order);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }

  Widget _buildSearchField(BuildContext context) {
    return SizedBox(
      height: context.responsiveHeight(0.055),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: AppFonts.geistMono(
          fontSize: context.fontSM,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search Order ID / Name / Phone',
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
            borderSide: const BorderSide(color: ColorResources.cardBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorResources.cardBorderColor),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacingSM,
            vertical: context.spacingXS,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.statusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final status = controller.statusOptions[index];
          return Obx(() {
            final isSelected = controller.selectedStatus.value == status;
            return ChoiceChip(
              iconTheme: IconThemeData(color: theme.onPrimaryColor),
              label: Text(
                status,
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
              onSelected: (_) => controller.selectStatus(status),
            );
          });
        },
      ),
    );
  }

  Widget _buildDropdownFilters(BuildContext context) {
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
                      value,
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
                      value.replaceAll('_', ' '),
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
            ],
          ),
        );
      }

      return Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: const EdgeInsets.only(right: 8),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => SizedBox(height: context.spacingSM),
          itemBuilder: (_, index) {
            final order = controller.orders[index];
            final isSelected = controller.selectedOrder.value?.id == order.id;
            return _OrderListItemCard(
              order: order,
              isSelected: isSelected,
              onTap: () => controller.selectOrder(order),
            );
          },
        ),
      );
    });
  }

  Widget _buildPaginationControls(BuildContext context) {
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
                onPressed: controller.hasPrev.value
                    ? controller.prevPage
                    : null,
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
                onPressed: controller.hasNext.value
                    ? controller.nextPage
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                color: ColorResources.appAccentColor,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select an Order to View Details',
            style: AppFonts.geistMono(
              fontSize: context.fontMD,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose an order from the list on the left to see customer data, items list, shipments, and billing breakdown.',
            textAlign: TextAlign.center,
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderModel order) {
    final totalAmount = double.tryParse(order.totalAmount ?? '0') ?? 0.0;
    final formattedDate = _formatDateTime(order.orderDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Details Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber ?? 'ORD-UNKNOWN',
                  style: AppFonts.geistMono(
                    fontSize: context.fontLG,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Placed on: $formattedDate  |  Channel: ${order.channel?.replaceAll('_', ' ').toUpperCase() ?? 'POS'}',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildStatusBadge(order.status),
                const SizedBox(width: 8),
                _buildPaymentStatusBadge(order.paymentStatus),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: ColorResources.cardBorderColor),
        const SizedBox(height: 10),
        // Scrollable Body
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView(
              padding: const EdgeInsets.only(right: 8),
              children: [
                // Section 1: Customer Details
                _buildDetailsCard(
                  title: 'Customer Details',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        'Full Name',
                        order.fullName ?? 'Walk-in Customer',
                      ),
                      _buildDetailRow(context, 'Phone', order.phone ?? '--'),
                      _buildDetailRow(context, 'Email', order.email ?? '--'),
                      _buildDetailRow(
                        context,
                        'Delivery Type',
                        order.deliveryType
                                ?.replaceAll('_', ' ')
                                .toUpperCase() ??
                            'STORE PICKUP',
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        _buildDetailRow(
                          context,
                          'Notes',
                          order.notes!,
                          isMultiLine: true,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacingSM),
                // Section 2: Items Table
                _buildDetailsCard(
                  title: 'Order Items (${order.items.length})',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildItemsTableHeader(context),
                      const Divider(),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = order.items[i];
                          return _buildItemRow(context, item);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacingSM),
                // Section 3: Payment Logs (if present)
                if (order.paymentLogs.isNotEmpty) ...[
                  _buildDetailsCard(
                    title: 'Payment Transactions',
                    icon: Icons.receipt_outlined,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.paymentLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final log = order.paymentLogs[i];
                        return _buildPaymentTransactionLog(context, log);
                      },
                    ),
                  ),
                  SizedBox(height: context.spacingSM),
                ],
                // Section 4: Pricing breakdown
                _buildPricingSummaryCard(context, order),
              ],
            ),
          ),
        ),
        // Action Panel
        const SizedBox(height: 10),
        const Divider(color: ColorResources.cardBorderColor),
        const SizedBox(height: 10),
        _buildActionButtons(context, order),
      ],
    );
  }

  Widget _buildDetailsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorResources.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorResources.cardBorderColor.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ColorResources.appAccentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.geistMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w600,
                color: ColorResources.labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTableHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            'Product / Customization',
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Qty',
            textAlign: TextAlign.center,
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Price',
            textAlign: TextAlign.right,
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Total',
            textAlign: TextAlign.right,
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItemModel item) {
    final price = double.tryParse(item.unitPrice ?? '0') ?? 0.0;
    final total = item.totalPrice;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Details
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Unnamed Product',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                if (item.variantName != null && item.variantName!.isNotEmpty)
                  Text(
                    'Variant: ${item.variantName}',
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                if (item.printMethod != null && item.printMethod!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Print: ${item.printMethod?.toUpperCase()}',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        color: ColorResources.appAccentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (item.customText != null && item.customText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Text: "${item.customText}"',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Quantity
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w600,
                color: ColorResources.labelColor,
              ),
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                color: ColorResources.labelColor,
              ),
            ),
          ),
          // Total
          Expanded(
            flex: 2,
            child: Text(
              '\$${total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w700,
                color: ColorResources.labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTransactionLog(
    BuildContext context,
    OrderPaymentLogModel log,
  ) {
    final amount = double.tryParse(log.amount ?? '0') ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorResources.cardBorderColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gateway: ${log.paymentMethod?.toUpperCase() ?? '--'}',
                style: AppFonts.geistMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
              _buildPaymentStatusBadge(log.status),
            ],
          ),
          const SizedBox(height: 6),
          _buildTransactionRow('Transaction ID', log.transactionId ?? '--'),
          _buildTransactionRow('Amount', '\$${amount.toStringAsFixed(2)}'),
          _buildTransactionRow('Date/Time', _formatDateTime(log.createdAt)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppFonts.geistMono(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.geistMono(
                fontSize: 10,
                color: ColorResources.labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummaryCard(BuildContext context, OrderModel order) {
    final subtotal = double.tryParse(order.subtotal ?? '0') ?? 0.0;
    final shipping = double.tryParse(order.shippingFee ?? '0') ?? 0.0;
    final discount = double.tryParse(order.discountAmount ?? '0') ?? 0.0;
    final tax = double.tryParse(order.taxAmount ?? '0') ?? 0.0;
    final total = double.tryParse(order.totalAmount ?? '0') ?? 0.0;
    final paid = double.tryParse(order.paidAmount ?? '0') ?? 0.0;
    final balance = total - paid;

    final theme = Get.find<AppThemeService>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorResources.backgroundColor.withOpacity(0.5),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPricingRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _buildPricingRow('Shipping Fee', '\$${shipping.toStringAsFixed(2)}'),
          if (discount > 0)
            _buildPricingRow(
              'Discount (${order.discountSource?.replaceAll('_', ' ') ?? 'coupon'})',
              '-\$${discount.toStringAsFixed(2)}',
              valueColor: ColorResources.gradientRed,
            ),
          _buildPricingRow('Tax Amount', '\$${tax.toStringAsFixed(2)}'),
          const Divider(),
          _buildPricingRow(
            'Total Amount',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
            fontSize: context.fontMD,
            valueColor: theme.primaryColor.value,
          ),
          _buildPricingRow(
            'Paid Amount',
            '\$${paid.toStringAsFixed(2)}',
            valueColor: ColorResources.successGreen,
          ),
          _buildPricingRow(
            balance <= 0 ? 'Change Returned' : 'Balance Due',
            '\$${balance.abs().toStringAsFixed(2)}',
            isBold: true,
            valueColor: balance <= 0
                ? ColorResources.successGreen
                : ColorResources.gradientRed,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(
    String label,
    String value, {
    bool isBold = false,
    double? fontSize,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.geistMono(
              fontSize: fontSize ?? 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: ColorResources.labelColor,
            ),
          ),
          Text(
            value,
            style: AppFonts.geistMono(
              fontSize: fontSize ?? 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
              color: valueColor ?? ColorResources.labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    final theme = Get.find<AppThemeService>();
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text(
                'PRINT RECEIPT',
                style: AppFonts.geistMono(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColorResources.cardBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: ColorResources.labelColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: Obx(
              () => ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondaryColor.value,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ORDER ACTIONS',
                  style: AppFonts.geistMono(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'booked':
      case 'accepted':
        color = ColorResources.blueColor;
        break;
      case 'preparing':
      case 'design_review':
      case 'label_create':
        color = ColorResources.warningOrange;
        break;
      case 'shipped':
      case 'ready_for_pickup':
        color = ColorResources.appMainColorLight;
        break;
      case 'completed':
        color = ColorResources.successGreen;
        break;
      case 'cancelled':
        color = ColorResources.gradientRed;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'pending':
        color = ColorResources.warningOrange;
        break;
      case 'paid':
        color = ColorResources.successGreen;
        break;
      case 'failed':
      case 'refunded':
        color = ColorResources.gradientRed;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.toUpperCase() ?? 'PENDING',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }
}

class _OrderListItemCard extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderListItemCard({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final formattedDate = _formatDate(order.orderDate);
    final total = double.tryParse(order.totalAmount ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.fullName ?? 'Walk-in Customer',
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor.value,
                  ),
                ),
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
                    _buildPaymentStatusBadge(order.paymentStatus),
                    const SizedBox(width: 6),
                    _buildDeliveryTypeBadge(order.deliveryType),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'booked':
      case 'accepted':
        color = ColorResources.blueColor;
        break;
      case 'preparing':
      case 'design_review':
      case 'label_create':
        color = ColorResources.warningOrange;
        break;
      case 'shipped':
      case 'ready_for_pickup':
        color = ColorResources.appMainColorLight;
        break;
      case 'completed':
        color = ColorResources.successGreen;
        break;
      case 'cancelled':
        color = ColorResources.gradientRed;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'pending':
        color = ColorResources.warningOrange;
        break;
      case 'paid':
        color = ColorResources.successGreen;
        break;
      case 'failed':
      case 'refunded':
        color = ColorResources.gradientRed;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status?.toUpperCase() ?? 'PENDING',
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDeliveryTypeBadge(String? type) {
    final isHome = type?.toLowerCase() == 'home_delivery';
    final color = isHome ? Colors.teal : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isHome ? 'HOME' : 'PICKUP',
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } catch (e) {
      return isoString;
    }
  }
}
