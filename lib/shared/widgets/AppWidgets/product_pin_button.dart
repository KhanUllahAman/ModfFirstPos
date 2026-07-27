import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';

/// Small outlined pin/favorite toggle meant to sit inside a product card
/// (top-right corner) rather than float as a bare icon, so it stays legible
/// over any product image. Used consistently on the Home product grid and
/// the Category products grid.
class ProductPinButton extends StatelessWidget {
  final bool isPinned;
  final VoidCallback onTap;
  final double size;

  const ProductPinButton({
    super.key,
    required this.isPinned,
    required this.onTap,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final color = theme.secondaryColor.value;
      return Material(
        color: Colors.white,
        shape: CircleBorder(side: BorderSide(color: color.withOpacity(0.5))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: size * 0.55,
              color: color,
            ),
          ),
        ),
      );
    });
  }
}
