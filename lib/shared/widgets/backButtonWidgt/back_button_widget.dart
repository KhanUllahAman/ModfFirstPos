import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class BackBar extends StatelessWidget {
  final String title;
  const BackBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Pop when possible; otherwise fall back to the POS home so the
            // button always works even when this screen is the stack root.
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(Routes.home);
            }
          },
          child: Row(
            children: [
              SvgPicture.asset(
                ImagesConstant.backArrowSvg,
                height: context.fontSM,
                width: context.fontSM,
              ),
              SizedBox(width: 10),
              Text(
                'Back',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  color: ColorResources.labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          '  /  ',
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
        ),
        Text(
          title,
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
        ),
      ],
    );
  }
}
