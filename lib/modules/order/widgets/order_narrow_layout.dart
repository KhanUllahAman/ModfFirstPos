import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/widgets/order_details_pane_widget.dart';
import 'package:modfirstpos/modules/order/widgets/order_list_pane_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class OrderNarrowLayout extends GetView<OrderController> {
  const OrderNarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSelected = controller.selectedOrder.value != null;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: hasSelected
            ? Column(
                key: const ValueKey('details'),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () =>
                            controller.selectedOrder.value = null,
                      ),
                      Text(
                        'Order Details',
                        style: AppFonts.geistMono(
                          fontSize: context.fontMD,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: OrderDetailsPaneWidget()),
                ],
              )
            : const OrderListPaneWidget(
                key: ValueKey('list'),
              ),
      );
    });
  }
}
