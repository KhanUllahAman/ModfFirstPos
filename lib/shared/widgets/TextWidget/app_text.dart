import 'package:flutter/material.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import '../ScreenSize/screen_size_utils.dart';
import '../../../core/utils/colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  const AppText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: AppFonts.geistMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        decoration: decoration,
      ),
    );
  }
}

class AppTextStyle {
  static Widget title({
    required BuildContext context,
    required String text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? decoration,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppFonts.geistMono(
        fontSize: context.fontXXL,
        fontWeight: FontWeight.w700,
        color: color,
        decoration: decoration,
      ),
    );
  }

  static Widget subtitle({
    required BuildContext context,
    required String text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? decoration,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppFonts.geistMono(
        fontSize: context.fontMD,
        fontWeight: FontWeight.w400,
        color: color,
        decoration: decoration,
      ),
    );
  }

  static Widget body({
    required BuildContext context,
    required String text,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextDecoration? decoration,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: AppFonts.geistMono(
        fontSize: context.fontSM,
        fontWeight: FontWeight.normal,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        decoration: decoration,
      ),
    );
  }

  static Widget small({
    required BuildContext context,
    required String text,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? decoration,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: AppFonts.geistMono(
        fontSize: context.fontXS,
        fontWeight: FontWeight.normal,
        color: color ?? Theme.of(context).textTheme.bodySmall?.color,
        decoration: decoration,
      ),
    );
  }

  static Widget custom({
    required BuildContext context,
    required String text,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: AppFonts.geistMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        decoration: decoration,
        letterSpacing: letterSpacing,
      ),
    );
  }

  static Widget poweredBy({required BuildContext context}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered by ',
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            fontWeight: FontWeight.w400,
            color: Colors.white.withAlpha(150),
          ),
        ),
        Text(
          'ORIO',
          style: AppFonts.geistMono(
            fontSize: context.fontMD,
            fontWeight: FontWeight.w800,
            color: ColorResources.whiteColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
