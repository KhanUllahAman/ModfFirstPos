import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/setting/controller/setting_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/sideNav/pos_side_nav.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(
        showMenuIcon: false,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PosSideNav(currentRouteOverride: Routes.setting),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackBar(title: "Settings"),
                    SizedBox(height: context.spacingSM),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Pane - Configuration Fields Form
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.homeBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorResources.cardBorderColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.tune_rounded,
                                  color: ColorResources.blackColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Connection Configurations',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontMD,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.labelColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView(
                                primary: false,
                                children: [
                                  // Printer IP Address
                                  Text(
                                    'Thermal Printer Configuration',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontXS,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  CustomTextFormField(
                                    controller: controller.printerIpController,
                                    labelText: 'Printer IP Address',
                                    hintText:
                                        'Enter printer IP address (e.g. 192.168.1.100)',
                                    borderRadius: 12,
                                    customFocusedBorderColor:
                                        theme.primaryColor.value,
                                    customEnabledBorderColor:
                                        ColorResources.cardBorderColor,
                                  ),
                                  SizedBox(height: context.spacingLG),

                                  // Customer Display Configuration
                                  Text(
                                    'Customer Display Settings',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontXS,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: CustomTextFormField(
                                          controller:
                                              controller.customerIpController,
                                          labelText: 'Customer IP Address',
                                          hintText: 'Enter customer Display IP',
                                          borderRadius: 12,
                                          customFocusedBorderColor:
                                              theme.primaryColor.value,
                                          customEnabledBorderColor:
                                              ColorResources.cardBorderColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextFormField(
                                          controller:
                                              controller.customerPortController,
                                          labelText: 'Port',
                                          hintText: 'e.g. 8080',
                                          keyboardType: TextInputType.number,
                                          borderRadius: 12,
                                          customFocusedBorderColor:
                                              theme.primaryColor.value,
                                          customEnabledBorderColor:
                                              ColorResources.cardBorderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveWidth(0.02)),

                    // Right Pane - Status Indicators & Diagnostician
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(context.spacingMD),
                              decoration: BoxDecoration(
                                color: ColorResources.whiteColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ColorResources.cardBorderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.assessment_rounded,
                                        color: ColorResources.blackColor,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Diagnostics & Status',
                                        style: AppFonts.geistMono(
                                          fontSize: context.fontMD,
                                          fontWeight: FontWeight.bold,
                                          color: ColorResources.labelColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildPrinterDiagnosticRow(context),
                                  SizedBox(height: context.spacingMD),
                                  _buildCashierDiagnosticRow(context),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.spacingSM),
                          // Bottom Actions Row using AppButton
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  onPressed: controller.getSettingsFromServer,
                                  isLoading: false,
                                  backgroundColor: theme.primaryColor.value,
                                  borderRadius: 12,
                                  child: Text(
                                    'Get from Server',
                                    style: AppFonts.geistMono(
                                      fontWeight: FontWeight.w700,
                                      fontSize: context.fontXS,
                                      color: theme.onPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Obx(
                                  () => AppButton(
                                    onPressed:
                                        controller.updateSettingsToServer,
                                    isLoading: false,
                                    backgroundColor: theme.secondaryColor.value,
                                    borderRadius: 12,
                                    child: Text(
                                      'Update to Server',
                                      style: AppFonts.geistMono(
                                        fontWeight: FontWeight.w700,
                                        fontSize: context.fontXS,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
    ).noKeyboard();
  }

  Widget _buildPrinterDiagnosticRow(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final isConnected = controller.isPrinterConnected.value;
      final isChecking = controller.isCheckingPrinter.value;

      return Container(
        padding: EdgeInsets.all(context.spacingSM),
        decoration: BoxDecoration(
          color: ColorResources.backgroundColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorResources.cardBorderColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecking
                        ? Colors.grey
                        : (isConnected
                              ? ColorResources.successGreen
                              : ColorResources.gradientRed),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Device',
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight: FontWeight.bold,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isChecking
                          ? 'Diagnosing connection...'
                          : (isConnected
                                ? 'Connected / Active'
                                : 'Disconnected / Offline'),
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: isChecking
                    ? null
                    : controller.checkPrinterConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected
                      ? Colors.grey[200]
                      : theme.secondaryColor.value,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isChecking
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'TEST',
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCashierDiagnosticRow(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final isConnected = controller.isCashierConnected.value;
      final isChecking = controller.isCheckingCashier.value;

      return Container(
        padding: EdgeInsets.all(context.spacingSM),
        decoration: BoxDecoration(
          color: ColorResources.backgroundColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorResources.cardBorderColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecking
                        ? Colors.grey
                        : (isConnected
                              ? ColorResources.successGreen
                              : ColorResources.gradientRed),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashier Tab Link',
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight: FontWeight.bold,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isChecking
                          ? 'Verifying socket handshake...'
                          : (isConnected
                                ? 'Handshake Successful'
                                : 'Handshake Failed'),
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: isChecking
                    ? null
                    : controller.checkCashierConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected
                      ? Colors.grey[200]
                      : theme.secondaryColor.value,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isChecking
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'TEST',
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
