import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/widgets/home_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import '../../../routes/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Reassign fresh ScrollController instances to HomeController to prevent
    // "attached to more than one ScrollPosition" exceptions during page transitions.
    controller.cartScrollController = ScrollController();
    controller.productScrollController = ScrollController();
  }

  @override
  void dispose() {
    controller.cartScrollController.dispose();
    controller.productScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(
        showMenuIcon: true,
        onMenuPressed: () {
          Get.toNamed(Routes.menu);
        },
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            trackVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(5),
            radius: const Radius.circular(8),
            thumbColor: WidgetStateProperty.all(ColorResources.thumbColor),
            trackColor: WidgetStateProperty.all(Color(0xffE6E8EC)),
            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
            crossAxisMargin: 2,
            mainAxisMargin: 4,
            minThumbLength: 40,
            interactive: true,
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Padding(
            padding: EdgeInsets.all(context.responsiveWidth(0.03)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
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
                        const Divider(
                          height: 1,
                          color: ColorResources.cardBorderColor,
                        ),
                        SizedBox(height: context.spacingSM),
                        SummarySection(controller: controller),
                        SizedBox(height: context.spacingSM),
                        BottomButtons(controller: controller),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: context.responsiveWidth(0.02)),
                Expanded(
                  flex: 4,
                  child: ProductListPanel(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    ).noKeyboard();
  }
}
