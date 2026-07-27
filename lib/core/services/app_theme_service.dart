import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/website_settings_storage_service.dart';
import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:modfirstpos/core/utils/hex_color_extension.dart';
import 'package:modfirstpos/core/utils/colors.dart';

class AppThemeService extends GetxService {
  final Rx<Color> primaryColor = ColorResources.blackColor.obs;
  final Rx<Color> secondaryColor = ColorResources.appMainColor.obs;

  Color get onPrimaryColor => primaryColor.value.contrastText;
  Color get onSecondaryColor => secondaryColor.value.contrastText;

  final RxString fontFamily = 'GeistMono'.obs;
  final RxString logoUrl = ''.obs;

  final RxBool hasThemeData = false.obs;

  LinearGradient get splashGradient {
    final endColor = secondaryColor.value;
    final midColor = Color.lerp(const Color(0xFFFDFEFA), endColor, 0.35)!;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFFDFEFA), midColor, endColor],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  Decoration get splashDecoration {
    if (!hasThemeData.value) {
      return const BoxDecoration(color: Colors.black);
    }
    return BoxDecoration(gradient: splashGradient);
  }

  Future<AppThemeService> init() async {
    await _loadFromStorage();
    return this;
  }

  Future<void> _loadFromStorage() async {
    hasThemeData.value = await WebsiteSettingsStorageService.hasSettings();
    await CurrencyUtils.load();

    final primaryHex = await WebsiteSettingsStorageService.getPrimaryColor();
    final secondaryHex =
        await WebsiteSettingsStorageService.getSecondaryColor();
    final font = await WebsiteSettingsStorageService.getFontPrimary();
    final logo = await WebsiteSettingsStorageService.getLogoUrl();

    // Swapped: the website settings' "primary" reads as this app's
    // secondary, and its "secondary" reads as this app's primary.
    final parsedPrimary = primaryHex?.toColorOrNull();
    if (parsedPrimary != null) secondaryColor.value = parsedPrimary;

    final parsedSecondary = secondaryHex?.toColorOrNull();
    if (parsedSecondary != null) primaryColor.value = parsedSecondary;

    if (font != null && font.trim().isNotEmpty) fontFamily.value = font.trim();
    if (logo != null && logo.trim().isNotEmpty) logoUrl.value = logo.trim();
  }

  Future<void> refreshFromStorage() => _loadFromStorage();
}
