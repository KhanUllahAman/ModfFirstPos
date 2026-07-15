import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTimestamp(notification.timestamp);
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final isRead = notification.isRead.value;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isRead
                ? ColorResources.whiteColor
                : theme.secondaryColor.value.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? ColorResources.cardBorderColor.withOpacity(0.5)
                  : theme.secondaryColor.value.withOpacity(0.3),
              width: isRead ? 1.0 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _getIconData(notification.type),
                  color: _getIconColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.bold,
                            color: ColorResources.labelColor,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: AppFonts.geistMono(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.description,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.labelColor.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ColorResources.gradientRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getIconData(String type) {
    switch (type.toLowerCase()) {
      case 'orders':
        return Icons.shopping_bag_rounded;
      case 'inventory':
        return Icons.warehouse_rounded;
      case 'diagnostics':
        return Icons.bug_report_rounded;
      case 'system alert':
      default:
        return Icons.info_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'orders':
        return ColorResources.successGreen;
      case 'inventory':
        return ColorResources.warningOrange;
      case 'diagnostics':
        return ColorResources.gradientRed;
      case 'system alert':
      default:
        return ColorResources.blueColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(timestamp);
  }
}

class NotificationFilterBadge extends StatelessWidget {
  final NotificationController controller;
  final String filter;
  const NotificationFilterBadge(
      {super.key, required this.controller, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int count = 0;
      if (filter == 'All') {
        count =
            controller.notifications.where((n) => !n.isRead.value).length;
      } else {
        count = controller.notifications
            .where((n) =>
                n.type.toLowerCase() == filter.toLowerCase() &&
                !n.isRead.value)
            .length;
      }
      if (count == 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: ColorResources.gradientRed.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: ColorResources.gradientRed,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}
