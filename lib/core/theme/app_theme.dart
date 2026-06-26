import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.geistMonoTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorResources.darkBackground,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.geistMono(
          color: ColorResources.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorResources.appMainColor,
          foregroundColor: ColorResources.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColorResources.appAccentColor,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.geistMono(
          color: Colors.white.withAlpha(150),
          fontSize: 13,
        ),
        floatingLabelStyle: GoogleFonts.geistMono(
          color: ColorResources.appAccentColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
