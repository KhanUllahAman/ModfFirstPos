import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(
        showMenuIcon: true,
        onMenuPressed: () {
          Get.back();
        },
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackBar(title: "Notifications"),
              SizedBox(height: context.spacingSM),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left sidebar - Categories & Filter selection
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.homeBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorResources.cardBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.filter_list_rounded, color: ColorResources.blueColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Alert Categories',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontMD,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.labelColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: controller.filterOptions.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final option = controller.filterOptions[index];
                                  return Obx(() {
                                    final isSelected = controller.selectedFilter.value == option;
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: AppFonts.geistMono(
                                          fontSize: context.fontSM,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? theme.onSecondaryColor : ColorResources.labelColor,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: Colors.transparent,
                                      selectedTileColor: theme.secondaryColor.value,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      onTap: () => controller.selectFilter(option),
                                      trailing: _buildFilterBadgeCount(option),
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveWidth(0.02)),

                    // Right main panel - List of Notifications
                    Expanded(
                      flex: 7,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorResources.cardBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header controls inside right pane
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Obx(() => Text(
                                      'All Messages (${controller.filteredNotifications.length})',
                                      style: AppFonts.geistMono(
                                        fontSize: context.fontMD,
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.labelColor,
                                      ),
                                    )),
                                    const SizedBox(width: 8),
                                    Obx(() {
                                      final unread = controller.unreadCount;
                                      if (unread == 0) return const SizedBox.shrink();
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: ColorResources.gradientRed.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$unread UNREAD',
                                          style: AppFonts.geistMono(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: ColorResources.gradientRed,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: controller.markAllAsRead,
                                      icon: const Icon(Icons.done_all_rounded, size: 16),
                                      label: Text(
                                        'Mark all read',
                                        style: AppFonts.geistMono(fontSize: context.fontXS, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: ColorResources.blueColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: controller.clearAll,
                                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                                      label: Text(
                                        'Clear all',
                                        style: AppFonts.geistMono(fontSize: context.fontXS, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: ColorResources.gradientRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Main notifications list
                            Expanded(child: _buildNotificationsList(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }

  Widget? _buildFilterBadgeCount(String filter) {
    int count = 0;
    if (filter == 'All') {
      count = controller.notifications.where((n) => !n.isRead.value).length;
    } else {
      count = controller.notifications
          .where((n) => n.type.toLowerCase() == filter.toLowerCase() && !n.isRead.value)
          .length;
    }
    if (count == 0) return null;
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
  }

  Widget _buildNotificationsList(BuildContext context) {
    return Obx(() {
      final list = controller.filteredNotifications;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No notifications available',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have caught up with all alerts and updates.',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }

      return Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: const EdgeInsets.only(right: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final notification = list[index];
            return _NotificationCard(
              notification: notification,
              onTap: () => controller.markAsRead(notification),
              onDismiss: () => controller.removeNotification(notification),
            );
          },
        ),
      );
    });
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
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
            color: isRead ? ColorResources.whiteColor : theme.secondaryColor.value.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? ColorResources.cardBorderColor.withOpacity(0.5) : theme.secondaryColor.value.withOpacity(0.3),
              width: isRead ? 1.0 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on type
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

              // Title and Description
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
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
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

              // Status dot and dismiss icon
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
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}
