import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_widgets.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class NotificationFilterSidebarWidget extends GetView<NotificationController> {
  const NotificationFilterSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Container(
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
              const Icon(Icons.filter_list_rounded,
                  color: ColorResources.blueColor, size: 20),
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
            child: Obx(
              () => ListView.separated(
                primary: false,
                itemCount: controller.filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = controller.filterOptions[index];
                  final isSelected =
                      controller.selectedFilter.value == option;
                  return ListTile(
                    title: Text(
                      option,
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.onSecondaryColor
                            : ColorResources.labelColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.transparent,
                    selectedTileColor: theme.secondaryColor.value,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () => controller.selectFilter(option),
                    trailing: NotificationFilterBadge(
                      controller: controller,
                      filter: option,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
