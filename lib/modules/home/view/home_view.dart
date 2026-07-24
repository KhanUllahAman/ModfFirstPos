import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/widgets/home_widget.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscapeOrTablet =
        MediaQuery.of(context).size.width >= 600 ||
        MediaQuery.of(context).orientation == Orientation.landscape;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ShiftController>().ensureShiftCheckedOnStartup(context);
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            trackVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(5),
            radius: const Radius.circular(8),
            thumbColor:
                WidgetStateProperty.all(ColorResources.thumbColor),
            trackColor:
                WidgetStateProperty.all(const Color(0xffE6E8EC)),
            trackBorderColor:
                WidgetStateProperty.all(Colors.transparent),
            crossAxisMargin: 2,
            mainAxisMargin: 4,
            minThumbLength: 40,
            interactive: true,
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.all(context.responsiveWidth(0.02)),
                  child: isLandscapeOrTablet
                      ? _buildTabletLayout(context)
                      : _buildMobileLayout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _buildCartPanel(context),
        ),
        SizedBox(width: context.responsiveWidth(0.015)),
        Expanded(
          flex: 4,
          child: ProductListPanel(controller: controller),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Obx(() {
      final hasCategory = controller.selectedCategory.value != null;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: hasCategory
            ? ProductListPanel(
                key: const ValueKey('products'),
                controller: controller,
              )
            : Column(
                key: const ValueKey('cart'),
                children: [
                  _buildCartPanel(context),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.selectedCategory.value = null,
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Browse Products'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildCartPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsiveWidth(0.018)),
      decoration: BoxDecoration(
        color: ColorResources.homeBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ScanField(controller: controller),
          SizedBox(height: context.spacingSM),
          Expanded(child: CartSection(controller: controller)),
          SizedBox(height: context.spacingSM),
          const Divider(height: 1, color: ColorResources.cardBorderColor),
          SizedBox(height: context.spacingSM),
          SummarySection(controller: controller),
          SizedBox(height: context.spacingSM),
          BottomButtons(controller: controller),
        ],
      ),
    );
  }
}
