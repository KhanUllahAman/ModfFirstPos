import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      final theme = Get.find<AppThemeService>();
      final storeSelectionDone = await SecureStorageService.isStoreSelectionDone();

      if (!storeSelectionDone) {
        Get.offAllNamed(Routes.storeSelection);
        return;
      }

      
      if (theme.hasThemeData.value && theme.logoUrl.value.isNotEmpty) {
      }

      final isLoggedIn = await SecureStorageService.isLoggedIn();
      Get.offAllNamed(isLoggedIn ? Routes.home : Routes.auth);
    } catch (e) {
      log('Navigation error: $e');
      Get.offAllNamed(Routes.auth);
    }
  }
}