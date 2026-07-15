import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class OrderDetailsPaneWidget extends GetView<OrderController> {
  const OrderDetailsPaneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingMD),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) return _buildEmptyState(context);
        return _buildOrderDetails(context, order);
      }),
    );
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
    final formattedDate = _formatDateTime(order.orderDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Expanded(
          child: Scrollbar(
            controller: controller.orderDetailsScrollController,
            thumbVisibility: true,
            child: ListView(
              controller: controller.orderDetailsScrollController,
              primary: false,
              padding: const EdgeInsets.only(right: 8),
              children: [
                _buildDetailsCard(
                  title: 'Customer Details',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      _buildDetailRow(context, 'Full Name',
                          order.fullName ?? 'Walk-in Customer'),
                      _buildDetailRow(
                          context, 'Phone', order.phone ?? '--'),
                      _buildDetailRow(
                          context, 'Email', order.email ?? '--'),
                      _buildDetailRow(
                        context,
                        'Delivery Type',
                        order.deliveryType
                                ?.replaceAll('_', ' ')
                                .toUpperCase() ??
                            'STORE PICKUP',
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        _buildDetailRow(context, 'Notes', order.notes!,
                            isMultiLine: true),
                    ],
                  ),
                ),
                SizedBox(height: context.spacingSM),
                _buildDetailsCard(
                  title: 'Order Items (${order.items.length})',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildItemsTableHeader(context),
                      const Divider(),
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _buildItemRow(context, order.items[i]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacingSM),
                if (order.paymentLogs.isNotEmpty) ...[
                  _buildDetailsCard(
                    title: 'Payment Transactions',
                    icon: Icons.receipt_outlined,
                    child: ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.paymentLogs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) => _buildPaymentTransactionLog(
                          context, order.paymentLogs[i]),
                    ),
                  ),
                  SizedBox(height: context.spacingSM),
                ],
                _buildPricingSummaryCard(context, order),
              ],
            ),
          ),
        ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isMultiLine = false}) {
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
          child: Text('Product / Customization',
              style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
        ),
        Expanded(
          flex: 1,
          child: Text('Qty',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
        ),
        Expanded(
          flex: 2,
          child: Text('Price',
              textAlign: TextAlign.right,
              style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
        ),
        Expanded(
          flex: 2,
          child: Text('Total',
              textAlign: TextAlign.right,
              style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
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
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? 'Unnamed Product',
                    style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor)),
                if (item.variantName != null && item.variantName!.isNotEmpty)
                  Text('Variant: ${item.variantName}',
                      style: AppFonts.geistMono(
                          fontSize: 10, color: Colors.grey[600])),
                if (item.printMethod != null && item.printMethod!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                        'Print: ${item.printMethod?.toUpperCase()}',
                        style: AppFonts.geistMono(
                            fontSize: 10,
                            color: ColorResources.appAccentColor,
                            fontWeight: FontWeight.w600)),
                  ),
                if (item.customText != null && item.customText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text('Text: "${item.customText}"',
                        style: AppFonts.geistMono(
                            fontSize: 10,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${item.quantity}',
                textAlign: TextAlign.center,
                style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor)),
          ),
          Expanded(
            flex: 2,
            child: Text('\$${price.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    color: ColorResources.labelColor)),
          ),
          Expanded(
            flex: 2,
            child: Text('\$${total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTransactionLog(
      BuildContext context, OrderPaymentLogModel log) {
    final amount = double.tryParse(log.amount ?? '0') ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: ColorResources.cardBorderColor.withOpacity(0.5)),
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
                      color: ColorResources.labelColor)),
              _buildPaymentStatusBadge(log.status),
            ],
          ),
          const SizedBox(height: 6),
          _buildTransactionRow(
              'Transaction ID', log.transactionId ?? '--'),
          _buildTransactionRow(
              'Amount', '\$${amount.toStringAsFixed(2)}'),
          _buildTransactionRow(
              'Date/Time', _formatDateTime(log.createdAt)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Text('$label: ',
              style: AppFonts.geistMono(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value,
                  style: AppFonts.geistMono(
                      fontSize: 10,
                      color: ColorResources.labelColor,
                      fontWeight: FontWeight.w500))),
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
    return Obx(() => Container(
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
              _buildPricingRow(
                  'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              _buildPricingRow(
                  'Shipping Fee', '\$${shipping.toStringAsFixed(2)}'),
              if (discount > 0)
                _buildPricingRow(
                  'Discount (${order.discountSource?.replaceAll('_', ' ') ?? 'coupon'})',
                  '-\$${discount.toStringAsFixed(2)}',
                  valueColor: ColorResources.gradientRed,
                ),
              _buildPricingRow(
                  'Tax Amount', '\$${tax.toStringAsFixed(2)}'),
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
        ));
  }

  Widget _buildPricingRow(String label, String value,
      {bool isBold = false, double? fontSize, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppFonts.geistMono(
                  fontSize: fontSize ?? 11,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.w500,
                  color: ColorResources.labelColor)),
          Text(value,
              style: AppFonts.geistMono(
                  fontSize: fontSize ?? 11,
                  fontWeight:
                      isBold ? FontWeight.bold : FontWeight.w700,
                  color: valueColor ?? ColorResources.labelColor)),
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
              label: Text('PRINT RECEIPT',
                  style: AppFonts.geistMono(
                      fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: ColorResources.cardBorderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                foregroundColor: ColorResources.labelColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 44,
            child: Obx(() => ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondaryColor.value,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('ORDER ACTIONS',
                      style: AppFonts.geistMono(
                          fontWeight: FontWeight.w700)),
                )),
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
      child: Text(status?.toUpperCase() ?? 'UNKNOWN',
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800)),
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
      child: Text(status?.toUpperCase() ?? 'PENDING',
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800)),
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
