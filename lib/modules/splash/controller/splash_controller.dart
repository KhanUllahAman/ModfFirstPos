import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  final AppThemeService theme = Get.find<AppThemeService>();

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOutBack),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeIn),
    );
    _prepareLogo();
    _navigateToNext();
  }

  Future<void> _prepareLogo() async {
    final url = theme.logoUrl.value;
    if (theme.hasThemeData.value && url.isNotEmpty) {
      try {
        // Precache happens in controller context via a BuildContext-free workaround
        // The view will handle image caching display via CachedNetworkImage
      } catch (_) {}
    }
    animController.forward();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    try {
      final storeSelectionDone =
          await SecureStorageService.isStoreSelectionDone();
      if (!storeSelectionDone) {
        Get.offAllNamed(Routes.storeSelection);
        return;
      }
      if (theme.hasThemeData.value && theme.logoUrl.value.isNotEmpty) {}
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      Get.offAllNamed(isLoggedIn ? Routes.home : Routes.auth);
    } catch (e) {
      log('Navigation error: $e');
      Get.offAllNamed(Routes.auth);
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}