import 'package:flutter/material.dart';
import 'package:modfirstpos/modules/order/widgets/order_details_pane_widget.dart';
import 'package:modfirstpos/modules/order/widgets/order_list_pane_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class OrderWideLayout extends StatelessWidget {
  const OrderWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 4,
          child: OrderListPaneWidget(),
        ),
        SizedBox(width: context.responsiveWidth(0.02)),
        const Expanded(
          flex: 5,
          child: OrderDetailsPaneWidget(),
        ),
      ],
    );
  }
}
