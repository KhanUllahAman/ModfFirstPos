import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';

class CircularLoaderWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  const CircularLoaderWidget({
    super.key,
    this.size = 60,
    this.strokeWidth = 3,
    this.color = Colors.white,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          backgroundColor: backgroundColor.withAlpha(02),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 1500.ms);
  }
}

class CustomLoadingDialog {
  static bool _isShowing = false;

  static void show({String? message, bool barrierDismissible = false}) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: barrierDismissible,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _LoadingDialogContent(message: message),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  static void hide() {
    _isShowing = false;
    while (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void forceHide() {
    if (Get.isDialogOpen ?? false) {
      Navigator.of(Get.overlayContext!).pop();
    }
    _isShowing = false;
  }
}

class _LoadingDialogContent extends StatelessWidget {
  final String? message;

  const _LoadingDialogContent({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Get.isRegistered<AppThemeService>() ? Get.find<AppThemeService>() : null;
    final animColor = theme?.secondaryColor.value ?? ColorResources.blackColor;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.halfTriangleDot(
              color: animColor,
              size: 30,
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: TextStyle(
                  color: ColorResources.blackColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
