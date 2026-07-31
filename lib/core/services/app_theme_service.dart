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

  /// Generic fallback logo (used when a store only sent `logo_url`, no
  /// black/white variants) — most screens should prefer [logoBlackUrl] or
  /// [logoWhiteUrl] instead, matching their own background.
  final RxString logoUrl = ''.obs;

  /// For light backgrounds (login screen, splash screen).
  final RxString logoBlackUrl = ''.obs;

  /// For dark backgrounds (home top bar, nav drawer).
  final RxString logoWhiteUrl = ''.obs;

  final RxBool hasThemeData = false.obs;

  LinearGradient get splashGradient {
    final endColor = primaryColor.value;
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
    final blackLogo = await WebsiteSettingsStorageService.getLogoBlackUrl();
    final whiteLogo = await WebsiteSettingsStorageService.getLogoWhiteUrl();
    final genericLogo = await WebsiteSettingsStorageService.getLogoUrl();
    // Prefer the white logo (home/drawer background reads dark) — fall
    // back to the generic logo_url for stores that only sent that field.
    final logo = whiteLogo ?? genericLogo;

    // Swapped: the website settings' "primary" reads as this app's
    // secondary, and its "secondary" reads as this app's primary.
    final parsedPrimary = primaryHex?.toColorOrNull();
    if (parsedPrimary != null) secondaryColor.value = parsedPrimary;

    final parsedSecondary = secondaryHex?.toColorOrNull();
    if (parsedSecondary != null) primaryColor.value = parsedSecondary;

    if (font != null && font.trim().isNotEmpty) fontFamily.value = font.trim();
    if (logo != null && logo.trim().isNotEmpty) logoUrl.value = logo.trim();

    final resolvedBlack = (blackLogo != null && blackLogo.trim().isNotEmpty)
        ? blackLogo.trim()
        : (genericLogo != null && genericLogo.trim().isNotEmpty ? genericLogo.trim() : '');
    final resolvedWhite = (whiteLogo != null && whiteLogo.trim().isNotEmpty)
        ? whiteLogo.trim()
        : (genericLogo != null && genericLogo.trim().isNotEmpty ? genericLogo.trim() : '');
    logoBlackUrl.value = resolvedBlack;
    logoWhiteUrl.value = resolvedWhite;
  }

  Future<void> refreshFromStorage() => _loadFromStorage();
}
