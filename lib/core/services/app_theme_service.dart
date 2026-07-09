import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/website_settings_storage_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/hex_color_extension.dart';

class AppThemeService extends GetxService {
  final Rx<Color> primaryColor = ColorResources.blackColor.obs;
  final Rx<Color> secondaryColor = ColorResources.appMainColor.obs;

  Color get onPrimaryColor => primaryColor.value.contrastText;
  Color get onSecondaryColor => secondaryColor.value.contrastText;

  final RxString fontFamily = 'GeistMono'.obs;
  final RxString logoUrl = ''.obs;

  LinearGradient get splashGradient {
    final endColor = secondaryColor.value;
    final midColor = Color.lerp(const Color(0xFFFDFEFA), endColor, 0.35)!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFDFEFA),
        midColor,                 
        endColor,                 
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  Future<AppThemeService> init() async {
    await _loadFromStorage();
    return this;
  }

  Future<void> _loadFromStorage() async {
    final primaryHex = await WebsiteSettingsStorageService.getPrimaryColor();
    final secondaryHex = await WebsiteSettingsStorageService.getSecondaryColor();
    final font = await WebsiteSettingsStorageService.getFontPrimary();
    final logo = await WebsiteSettingsStorageService.getLogoUrl();

    final parsedPrimary = primaryHex?.toColorOrNull();
    if (parsedPrimary != null) primaryColor.value = parsedPrimary;

    final parsedSecondary = secondaryHex?.toColorOrNull();
    if (parsedSecondary != null) secondaryColor.value = parsedSecondary;

    if (font != null && font.trim().isNotEmpty) fontFamily.value = font.trim();
    if (logo != null && logo.trim().isNotEmpty) logoUrl.value = logo.trim();
  }

  Future<void> refreshFromStorage() => _loadFromStorage();
}