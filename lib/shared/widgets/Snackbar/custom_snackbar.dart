import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import '../../../core/utils/colors.dart';

enum SnackBarType { success, error, info, warning }

class SnackBarData {
  final String title;
  final String message;
  final SnackBarType snackBarType;
  final int durationSeconds;
  final VoidCallback? actionCallback;
  final String? actionLabel;

  SnackBarData({
    required this.title,
    required this.message,
    this.snackBarType = SnackBarType.success,
    this.durationSeconds = 3,
    this.actionCallback,
    this.actionLabel,
  });
}

class SnackBarQueue {
  static final Queue<SnackBarData> _queue = Queue<SnackBarData>();
  static bool _isShowing = false;

  static void addToQueue(
    String title,
    String message, {
    SnackBarType snackBarType = SnackBarType.success,
    int durationSeconds = 3,
    VoidCallback? actionCallback,
    String? actionLabel,
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    _queue.add(
      SnackBarData(
        title: title,
        message: message,
        snackBarType: snackBarType,
        durationSeconds: durationSeconds,
        actionCallback: actionCallback,
        actionLabel: actionLabel,
      ),
    );
    _showNextSnackBar(snackPosition);
  }

  static void _showNextSnackBar(SnackPosition snackPosition) {
    if (_isShowing || _queue.isEmpty) return;
    _isShowing = true;
    final snackBarData = _queue.removeFirst();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      customSnackBar(
        snackBarData.title,
        snackBarData.message,
        snackBarType: snackBarData.snackBarType,
        durationSeconds: snackBarData.durationSeconds,
        actionCallback: snackBarData.actionCallback,
        actionLabel: snackBarData.actionLabel,
        snackPosition: snackPosition,
        onDismissed: () {
          _isShowing = false;
          _showNextSnackBar(snackPosition);
        },
      );
    });
  }

  static void clearQueue() {
    _queue.clear();
    _isShowing = false;
  }
}

void customSnackBar(
  String title,
  String message, {
  SnackBarType snackBarType = SnackBarType.success,
  int durationSeconds = 3,
  VoidCallback? onDismissed,
  VoidCallback? actionCallback,
  String? actionLabel,
  SnackPosition snackPosition = SnackPosition.TOP,
}) {
  if (Get.context == null) return;

  // WidgetsBinding wrapper hatao — seedha call karo
  HapticFeedback.lightImpact();

  final screenWidth = MediaQuery.of(Get.context!).size.width;

  // Keep the toast a readable width and centered on wide/landscape
  // POS screens instead of stretching (or collapsing) across the display.
  const maxToastWidth = 480.0;
  final horizontalMargin = screenWidth > maxToastWidth + 32
      ? (screenWidth - maxToastWidth) / 2
      : screenWidth * 0.04;

  Get.snackbar(
    '',
    '',
    titleText: _SnackBarContent(
      message: message,
      snackBarType: snackBarType,
      screenWidth: screenWidth,
    ),
    messageText: const SizedBox.shrink(),
    padding: EdgeInsets.zero,
    margin: EdgeInsets.symmetric(
      horizontal: horizontalMargin,
      vertical: 10.0,
    ),
    duration: Duration(seconds: durationSeconds),
    backgroundColor: Colors.transparent,
    snackPosition: snackPosition,
    borderRadius: 0,
    animationDuration: const Duration(milliseconds: 300),
    forwardAnimationCurve: Curves.easeOut,
    reverseAnimationCurve: Curves.easeIn,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    overlayBlur: 0,
    boxShadows: [],
    onTap: (GetSnackBar snackBar) {
      Get.closeCurrentSnackbar();
      onDismissed?.call();
    },
  );
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType snackBarType;
  final double screenWidth;

  const _SnackBarContent({
    required this.message,
    required this.snackBarType,
    required this.screenWidth,
  });

  IconData get _icon {
    switch (snackBarType) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.info:
        return Icons.info_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  Color get _iconColor {
    switch (snackBarType) {
      case SnackBarType.success:
        return Colors.green[700]!;
      case SnackBarType.error:
        return Colors.red[700]!;
      case SnackBarType.info:
        return Colors.blue[700]!;
      case SnackBarType.warning:
        return Colors.orange[700]!;
    }
  }

  Color get _backgroundColor {
    switch (snackBarType) {
      case SnackBarType.success:
        return const Color(0xFF0D3320); // dark green
      case SnackBarType.error:
        return const Color(0xFF3D0D0D); // dark red
      case SnackBarType.info:
        return const Color(0xFF0D1F3D); // dark blue
      case SnackBarType.warning:
        return const Color(0xFF3D2500); // dark orange
    }
  }

  Color get _borderColor {
    switch (snackBarType) {
      case SnackBarType.success:
        return Colors.green[700]!;
      case SnackBarType.error:
        return Colors.red[700]!;
      case SnackBarType.info:
        return Colors.blue[700]!;
      case SnackBarType.warning:
        return Colors.orange[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppFonts.geistMono(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorResources.whiteColor,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


//Changes //