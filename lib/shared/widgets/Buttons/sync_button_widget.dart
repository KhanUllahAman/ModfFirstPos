import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

enum SyncButtonVariant { filled, outlined, iconOnly }

class AppSyncButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final IconData icon;
  final double? height;
  final SyncButtonVariant variant;
  final double borderRadius;

  const AppSyncButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sync Server',
    this.icon = Icons.sync_rounded,
    this.height,
    this.variant = SyncButtonVariant.filled,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final isBtnDisabled = isLoading || onPressed == null;

    if (variant == SyncButtonVariant.iconOnly) {
      return Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: IconButton(
          tooltip: label,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primaryColor.value,
                  ),
                )
              : Icon(
                  icon,
                  color: isBtnDisabled ? Colors.grey : theme.primaryColor.value,
                  size: 20,
                ),
          onPressed: isBtnDisabled ? null : onPressed,
        ),
      ));
    }

    if (variant == SyncButtonVariant.outlined) {
      return Obx(() => OutlinedButton.icon(
        onPressed: isBtnDisabled ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.primaryColor.value,
                ),
              )
            : Icon(icon, size: 16, color: theme.primaryColor.value),
        label: Text(
          label,
          style: AppFonts.geistMono(
            fontSize: context.fontXS,
            fontWeight: FontWeight.w700,
            color: theme.primaryColor.value,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.primaryColor.value),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ));
    }

    // Default: SyncButtonVariant.filled
    return Obx(() => ElevatedButton.icon(
      onPressed: isBtnDisabled ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.onPrimaryColor,
              ),
            )
          : Icon(
              icon,
              size: 18,
              color: theme.onPrimaryColor,
            ),
      label: Text(
        label,
        style: AppFonts.geistMono(
          fontSize: context.fontXS,
          fontWeight: FontWeight.w700,
          color: theme.onPrimaryColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor.value,
        disabledBackgroundColor: theme.primaryColor.value.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ));
  }
}
