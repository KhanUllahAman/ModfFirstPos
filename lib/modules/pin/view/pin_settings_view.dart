import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/pin/controller/pin_settings_controller.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/dailogs/pin_dialog.dart';

class PinSettingsView extends GetView<PinSettingsController> {
  const PinSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () => Get.back()),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.responsiveWidth(0.03)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BackBar(title: "Screen Lock"),
                SizedBox(height: context.spacingLG),
                Obx(
                  () => Container(
                    padding: EdgeInsets.all(context.spacingMD),
                    decoration: BoxDecoration(
                      color: ColorResources.whiteColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7E9F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Enable PIN Lock",
                            style: AppFonts.geistMono(
                              fontSize: context.fontSM,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: controller.pinController.pinEnabled.value,
                          activeColor: theme.primaryColor.value,
                          onChanged: (val) {
                            if (val) {
                              Get.toNamed(Routes.setPin);
                            } else {
                              _showDisableDialog(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.spacingMD),
                Obx(
                  () => controller.pinController.pinEnabled.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SettingsTile(
                              title: "Change PIN",
                              onTap: () => _showChangePinDialog(context),
                            ),
                            SizedBox(height: context.spacingMD),
                            Container(
                              padding: EdgeInsets.all(context.spacingMD),
                              decoration: BoxDecoration(
                                color: ColorResources.whiteColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE7E9F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Auto-lock after ${controller.autoLockMinutes.value} minutes",
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontSM,
                                    ),
                                  ),
                                  Slider(
                                    value: controller.autoLockMinutes.value
                                        .toDouble(),
                                    min: 1,
                                    max: 120,
                                    divisions: 119,
                                    activeColor: theme.primaryColor.value,
                                    label:
                                        "${controller.autoLockMinutes.value} min",
                                    onChanged: (val) {
                                      controller.autoLockMinutes.value = val
                                          .toInt();
                                    },
                                    onChangeEnd: (val) {
                                      controller.updateAutoLock(val.toInt());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDisableDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    Get.dialog(
      PinActionDialog(
        icon: Icons.lock_open_rounded,
        title: "Disable PIN Lock",
        subtitle: "Enter your current PIN to turn off screen lock",
        isDestructive: true,
        confirmLabel: "Disable",
        fields: [PinDialogField(controller: pinCtrl, label: "Current PIN")],
        onConfirm: () => controller.disablePin(pinCtrl.text.trim()),
      ),
    ).whenComplete(() {
      // The dialog's exit transition keeps animating (and rebuilding the
      // still-mounted TextField) for a moment after the route is popped —
      // disposing the controller synchronously here races that animation.
      Future.delayed(const Duration(milliseconds: 300), pinCtrl.dispose);
    });
  }

  void _showChangePinDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    Get.dialog(
      PinActionDialog(
        icon: Icons.password_rounded,
        title: "Change PIN",
        subtitle: "Enter your current PIN and choose a new one",
        confirmLabel: "Update",
        fields: [
          PinDialogField(controller: currentCtrl, label: "Current PIN"),
          PinDialogField(controller: newCtrl, label: "New PIN"),
          PinDialogField(controller: confirmCtrl, label: "Confirm New PIN"),
        ],
        onConfirm: () => controller.changePin(
          currentPin: currentCtrl.text.trim(),
          newPin: newCtrl.text.trim(),
          confirmNewPin: confirmCtrl.text.trim(),
        ),
      ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        currentCtrl.dispose();
        newCtrl.dispose();
        confirmCtrl.dispose();
      });
    });
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorResources.whiteColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(context.spacingMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
