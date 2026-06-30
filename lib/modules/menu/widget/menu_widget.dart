import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

enum MenuTileColor { blue, red }

class MenuList extends StatelessWidget {
  final String menuSvg;
  final String menuTitle;
  final MenuTileColor menuColor;
  final VoidCallback menuTap;

  const MenuList({
    super.key,
    required this.menuSvg,
    required this.menuTitle,
    required this.menuColor,
    required this.menuTap,
  });

  Color get _bgColor => menuColor == MenuTileColor.blue
      ? const Color(0xFFF2F6FF)
      : const Color(0xFFFFF3E2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: menuTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.04),
          vertical: context.responsiveHeight(0.018),
        ),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              menuSvg,
              width: 22,
              height: 22,
              color: ColorResources.blackColor,
            ),
            SizedBox(width: context.responsiveWidth(0.03)),
            Expanded(
              child: Text(
                menuTitle,
                style: GoogleFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: ColorResources.labelColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ColorResources.labelColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
