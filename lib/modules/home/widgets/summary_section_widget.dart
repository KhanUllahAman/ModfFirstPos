import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class SummarySection extends StatelessWidget {
  final HomeController controller;
  const SummarySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.discountInput.value;
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  'Discount:',
                  'Rs. ${controller.discount.toStringAsFixed(2)}',
                ),
                _SummaryRow('GST:', 'Rs. 0.00'),
                _SummaryRow('C.Voucher:', 'Rs. 0.00'),
                _SummaryRow('G.Voucher:', 'Rs. 0.00'),
                _SummaryRow('Service:', 'Rs. 0.00'),
              ],
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  'Total Amount:',
                  'Rs. ${controller.productTotal.toStringAsFixed(0)}',
                  isBold: true,
                ),
                _SummaryRow(
                  'Paid Amount:',
                  'Rs. ${controller.subTotal.toStringAsFixed(2)}',
                  isBold: true,
                ),
                _SummaryRow(
                  'Balance:',
                  'Rs. ${controller.balance.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = AppFonts.geistMono(
      fontSize: context.fontXS,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      color: ColorResources.blackColor,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
