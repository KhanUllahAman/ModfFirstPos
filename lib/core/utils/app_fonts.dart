import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';

class AppFonts {
  
  static TextStyle geistMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    String family = 'Geist Mono';  

    if (Get.isRegistered<AppThemeService>()) {
      family = Get.find<AppThemeService>().fontFamily.value;
    }

    try {
      return GoogleFonts.getFont(
        family,
        fontSize: fontSize ?? 14.0,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );
    } catch (e) {
      // Safe fallback
      return GoogleFonts.getFont(
        'Geist Mono',
        fontSize: fontSize ?? 14.0,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );
    }
  }
}