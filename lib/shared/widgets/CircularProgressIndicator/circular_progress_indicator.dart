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
  static OverlayEntry? _overlayEntry;
  static final ValueNotifier<String?> _messageNotifier =
      ValueNotifier<String?>(null);
  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  static void show({String? message, bool barrierDismissible = false}) {
    if (_isShowing && _overlayEntry != null) {
      _messageNotifier.value = message;
      return;
    }
    _isShowing = true;
    _messageNotifier.value = message;

    void insertOverlay() {
      if (!_isShowing) return;
      if (_overlayEntry != null) return;

      final context = Get.overlayContext ?? Get.key.currentContext;
      if (context == null) return;

      final overlay =
          Overlay.maybeOf(context) ?? Get.key.currentState?.overlay;
      if (overlay == null) return;

      _overlayEntry = OverlayEntry(
        builder: (context) => PopScope(
          canPop: barrierDismissible,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop && barrierDismissible) {
              hide();
            }
          },
          child: Material(
            color: Colors.black.withValues(alpha: 0.5),
            type: MaterialType.canvas,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: barrierDismissible ? hide : null,
                    child: const SizedBox.expand(),
                  ),
                ),
                Center(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: _messageNotifier,
                    builder: (context, msg, _) =>
                        _LoadingDialogContent(message: msg),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      overlay.insert(_overlayEntry!);
    }

    final context = Get.overlayContext ?? Get.key.currentContext;
    if (context != null) {
      insertOverlay();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => insertOverlay());
    }
  }

  static void hide() {
    _isShowing = false;
    _messageNotifier.value = null;
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (_) {}
      _overlayEntry = null;
    }
    // Also dismiss any dialog if one was opened via Get.dialog
    if (Get.isDialogOpen ?? false) {
      try {
        Get.key.currentState?.pop();
      } catch (_) {}
    }
  }

  static void forceHide() {
    hide();
  }
}

class _LoadingDialogContent extends StatelessWidget {
  final String? message;

  const _LoadingDialogContent({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Get.isRegistered<AppThemeService>()
        ? Get.find<AppThemeService>()
        : null;
    final animColor =
        theme?.secondaryColor.value ?? ColorResources.blackColor;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                style: const TextStyle(
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
