import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class BottomButtons extends StatelessWidget {
  final HomeController controller;
  const BottomButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => controller.getOptions(),
              isLoading: false,
              backgroundColor: theme.primaryColor.value,
              borderRadius: 10,
              child: Text(
                'Options',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: theme.onPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.015)),
          Expanded(
            child: AppButton(
              backgroundColor: theme.secondaryColor.value,
              onPressed: () {},
              isLoading: false,
              borderRadius: 10,
              child: Text(
                'Payment',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w500,
                  color: theme.onSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
