import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class ScanField extends StatelessWidget {
  final HomeController controller;
  const ScanField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: TextField(
        controller: controller.scanController,
        style: AppFonts.geistMono(fontSize: context.fontSM),
        decoration: InputDecoration(
          hintText: 'Scan Product',
          hintStyle: AppFonts.geistMono(
            color: ColorResources.blackColor,
            fontSize: context.fontSM,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.02),
            vertical: context.responsiveHeight(0.018),
          ),
          border: InputBorder.none,
          suffixIcon: Padding(
            padding: EdgeInsets.all(context.responsiveWidth(0.012)),
            child: Icon(Iconsax.scan_barcode, color: ColorResources.blackColor),
          ),
        ),
      ),
    );
  }
}
