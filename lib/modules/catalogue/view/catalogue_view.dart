import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/catalogue/controller/catalogue_controller.dart';
import 'package:modfirstpos/modules/catalogue/widgets/catalogue_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class CatalogueView extends GetView<CatalogueController> {
  const CatalogueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.whiteColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () {
        Get.back();
      }),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackBar(title: "Catalogue"),
              SizedBox(height: context.spacingSM),
              SearchBarCatalogue(controller: controller),
              SizedBox(height: context.spacingSM),
              Expanded(child: ProductGrid(controller: controller)),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}