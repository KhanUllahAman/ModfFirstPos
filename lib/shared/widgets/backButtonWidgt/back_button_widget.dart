import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class BackBar extends StatelessWidget {
  final String title;
  const BackBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
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
                style: GoogleFonts.geistMono(
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
          style: GoogleFonts.geistMono(
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.geistMono(
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
        ),
      ],
    );
  }
}
