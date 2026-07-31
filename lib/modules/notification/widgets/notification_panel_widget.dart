import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_widgets.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class NotificationPanelWidget extends GetView<NotificationController> {
  const NotificationPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingMD),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                      style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: ColorResources.blueColor),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: controller.clearAll,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                    label: Text(
                      'Clear all',
                      style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                        foregroundColor: ColorResources.gradientRed),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(child: _buildNotificationsList(context)),
        ],
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
              Icon(Icons.notifications_none_rounded,
                  size: 64, color: Colors.grey[300]),
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.loadNotifications(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Reload Notifications',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Get.find<AppThemeService>().primaryColor.value,
                  foregroundColor:
                      Get.find<AppThemeService>().onPrimaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        );
      }
      return Scrollbar(
        controller: controller.scrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: controller.scrollController,
          primary: false,
          padding: const EdgeInsets.only(right: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final notification = list[index];
            return NotificationCard(
              notification: notification,
              onTap: () => controller.markAsRead(notification),
              onDismiss: () =>
                  controller.removeNotification(notification),
            );
          },
        ),
      );
    });
  }
}
