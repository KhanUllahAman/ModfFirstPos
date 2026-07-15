import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_panel_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class NotificationNarrowLayout extends GetView<NotificationController> {
  const NotificationNarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: Obx(() => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final option = controller.filterOptions[index];
                  final isSelected =
                      controller.selectedFilter.value == option;
                  return ChoiceChip(
                    label: Text(
                      option,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.onSecondaryColor
                            : ColorResources.labelColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.secondaryColor.value,
                    backgroundColor: ColorResources.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : ColorResources.cardBorderColor,
                      ),
                    ),
                    onSelected: (_) => controller.selectFilter(option),
                  );
                },
              )),
        ),
        const SizedBox(height: 8),
        const Expanded(child: NotificationPanelWidget()),
      ],
    );
  }
}
