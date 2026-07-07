import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 5));
    try {
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      if (isLoggedIn) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.auth);
      }
    } catch (e) {
      log('Navigation error: $e');
      Get.offAllNamed(Routes.auth);
    }
  }
}