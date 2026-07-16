import 'package:flutter/material.dart';

/// Shows a dialog with the app-standard subtle fade + scale transition.
/// All POS dialogs should go through this helper for consistent motion.
Future<T?> showAppFadeDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = false,
  String? barrierLabel,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
