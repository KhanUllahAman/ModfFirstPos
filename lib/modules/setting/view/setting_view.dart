import 'package:flutter/foundation.dart';
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

import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                                    child: Obx(
                                      () => ListView(
                                        primary: false,
                                        children: [
                                          Text(
                                            'POS Device Configuration',
                                            style: AppFonts.geistMono(
                                              fontSize: context.fontXS,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          CustomTextFormField(
                                            controller:
                                                controller.nameController,
                                            labelText: 'Device Name',
                                            hintText: 'e.g. Counter 1 Tablet',
                                            borderRadius: 12,
                                            customFocusedBorderColor:
                                                theme.secondaryColor.value,
                                            customEnabledBorderColor:
                                                ColorResources.cardBorderColor,
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: CustomTextFormField(
                                                  controller: controller
                                                      .deviceCodeController,
                                                  labelText: 'Device Code',
                                                  hintText: 'e.g. POS-TAB-001',
                                                  borderRadius: 12,
                                                  customFocusedBorderColor:
                                                      theme
                                                          .secondaryColor
                                                          .value,
                                                  customEnabledBorderColor:
                                                      ColorResources
                                                          .cardBorderColor,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.copyWith(
                                                          primary: theme
                                                              .secondaryColor
                                                              .value,
                                                        ),
                                                  ),
                                                  child: DropdownButtonFormField<String>(
                                                    dropdownColor:
                                                        ColorResources
                                                            .whiteColor,
                                                    value: controller
                                                        .deviceType
                                                        .value,
                                                    decoration: InputDecoration(
                                                      labelText: 'Device Type',
                                                      filled: true,
                                                      fillColor: ColorResources
                                                          .whiteColor,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: const BorderSide(
                                                          color: ColorResources
                                                              .cardBorderColor,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: theme
                                                              .secondaryColor
                                                              .value,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                    ),
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value:
                                                            'android_terminal',
                                                        child: Text(
                                                          'Android Terminal',
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'ios_terminal',
                                                        child: Text(
                                                          'iOS Terminal',
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'windows_pos',
                                                        child: Text(
                                                          'Windows POS',
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'tablet',
                                                        child: Text('Tablet'),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'desktop',
                                                        child: Text('Desktop'),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'kiosk',
                                                        child: Text('Kiosk'),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'mobile',
                                                        child: Text('Mobile'),
                                                      ),
                                                    ],
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        controller
                                                                .deviceType
                                                                .value =
                                                            val;
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          CustomTextFormField(
                                            controller:
                                                controller.ipAddressController,
                                            labelText: 'IP Address',
                                            hintText:
                                                'Enter device / printer IP address (e.g. 192.168.1.45)',
                                            borderRadius: 12,
                                            customFocusedBorderColor:
                                                theme.secondaryColor.value,
                                            customEnabledBorderColor:
                                                ColorResources.cardBorderColor,
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          CustomTextFormField(
                                            controller:
                                                controller.customerIpController,
                                            labelText: 'Customer IP',
                                            hintText:
                                                'IP shown on the customer-facing tab (e.g. 192.168.1.60)',
                                            borderRadius: 12,
                                            customFocusedBorderColor:
                                                theme.secondaryColor.value,
                                            customEnabledBorderColor:
                                                ColorResources.cardBorderColor,
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          CustomTextFormField(
                                            controller: controller
                                                .customerPairingCodeController,
                                            labelText: 'Customer Pairing Code',
                                            hintText:
                                                '6-digit code shown on the customer-facing tab',
                                            keyboardType: TextInputType.number,
                                            borderRadius: 12,
                                            customFocusedBorderColor:
                                                theme.secondaryColor.value,
                                            customEnabledBorderColor:
                                                ColorResources.cardBorderColor,
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          CustomTextFormField(
                                            controller:
                                                controller.locationController,
                                            labelText: 'Location',
                                            hintText: 'e.g. Main Counter',
                                            borderRadius: 12,
                                            customFocusedBorderColor:
                                                theme.secondaryColor.value,
                                            customEnabledBorderColor:
                                                ColorResources.cardBorderColor,
                                          ),
                                          SizedBox(height: context.spacingMD),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: Theme.of(context)
                                                  .colorScheme
                                                  .copyWith(
                                                    primary: theme
                                                        .secondaryColor
                                                        .value,
                                                  ),
                                            ),
                                            child: DropdownButtonFormField<String>(
                                              dropdownColor:
                                                  ColorResources.whiteColor,
                                              value:
                                                  controller.receiptType.value,
                                              decoration: InputDecoration(
                                                labelText: 'Receipt Type',
                                                filled: true,
                                                fillColor:
                                                    ColorResources.whiteColor,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: ColorResources
                                                        .cardBorderColor,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: theme
                                                            .secondaryColor
                                                            .value,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'thermal_80mm',
                                                  child: Text('Thermal 80mm'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'thermal_58mm',
                                                  child: Text('Thermal 58mm'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'a4',
                                                  child: Text('A4'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'digital',
                                                  child: Text('Digital'),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.receiptType.value =
                                                      val;
                                                }
                                              },
                                            ),
                                          ),
                                          // SizedBox(height: context.spacingMD),
                                          // SwitchListTile.adaptive(
                                          //   contentPadding: EdgeInsets.zero,
                                          //   value: controller.isActive.value,
                                          //   onChanged: (val) =>
                                          //       controller.isActive.value = val,
                                          //   activeThumbColor: theme.secondaryColor.value,
                                          //   activeTrackColor:
                                          //       theme.secondaryColor.value.withOpacity(0.4),
                                          //   title: Text(
                                          //     'Device Active',
                                          //     style: AppFonts.geistMono(
                                          //       fontSize: context.fontSM,
                                          //       fontWeight: FontWeight.w600,
                                          //       color: ColorResources.labelColor,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
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
                                    child: SingleChildScrollView(
                                      child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
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
                                                color:
                                                    ColorResources.labelColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _buildPrinterDiagnosticRow(context),
                                        SizedBox(height: context.spacingMD),
                                        _buildCashierDiagnosticRow(context),
                                        SizedBox(height: context.spacingMD),
                                        const Divider(),
                                        SizedBox(height: context.spacingSM),
                                        _buildStripeTerminalSection(context),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.spacingSM),
                                // Bottom Actions Row using AppButton
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(
                                        () => OutlinedButton(
                                          onPressed:
                                              controller.getSettingsFromServer,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: ColorResources
                                                  .cardBorderColor,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            foregroundColor:
                                                ColorResources.labelColor,
                                          ),
                                          child: Text(
                                            'GET FROM SERVER',
                                            style: AppFonts.geistMono(
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                          isLoading:
                                              controller.isUpdating.value,
                                          backgroundColor:
                                              theme.primaryColor.value,
                                          borderRadius: 12,
                                          child: Text(
                                            'UPDATE TO SERVER',
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
                      : theme.primaryColor.value,
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
                      'Customer Display Link',
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
                      : theme.primaryColor.value,
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

  /// Card-present (Stripe Terminal) reader config — see
  /// docs/POS_PAYMENT_FLUTTER.md. The reader is registered once via Postman
  /// (`POST /terminal/readers`); its `reader_id` is entered here so the app
  /// can send it with every card-present payment.
  Widget _buildStripeTerminalSection(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.point_of_sale_rounded,
              color: ColorResources.blackColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Stripe Terminal',
              style: AppFonts.geistMono(
                fontSize: context.fontSM,
                fontWeight: FontWeight.bold,
                color: ColorResources.labelColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacingSM),
        CustomTextFormField(
          controller: controller.readerIdController,
          labelText: 'Reader ID',
          hintText: 'Registered reader_id from POST /terminal/readers',
          keyboardType: TextInputType.number,
          borderRadius: 12,
          customFocusedBorderColor: theme.secondaryColor.value,
          customEnabledBorderColor: ColorResources.cardBorderColor,
        ),
        // Simulated-reader testing tools — dev builds only. A client running
        // a release build always has a real physical terminal, so none of
        // this (toggle, Stripe test reader id, test secret key) should be
        // visible or reachable for them.
        if (kDebugMode) ...[
          SizedBox(height: context.spacingSM),
          Obx(
            () => SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: controller.useSimulatedReader.value,
              onChanged: (val) {
                controller.useSimulatedReader.value = val;
                controller.saveTerminalSettings(showSnackbar: false);
              },
              activeThumbColor: theme.secondaryColor.value,
              title: Text(
                'Use Simulated Reader (testing, no hardware)',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w600,
                  color: ColorResources.labelColor,
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacingSM),
          Text(
            'TEST ONLY — simulate a card tap on a simulated reader '
            '(bypasses needing a real Stripe Terminal to test)',
            style: AppFonts.geistMono(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.spacingSM),
          CustomTextFormField(
            controller: controller.stripeReaderTmrIdController,
            labelText: 'Stripe Reader ID (tmr_...)',
            hintText: 'From POST /terminal/readers/list',
            borderRadius: 12,
            customFocusedBorderColor: theme.secondaryColor.value,
            customEnabledBorderColor: ColorResources.cardBorderColor,
          ),
          SizedBox(height: context.spacingSM),
          CustomTextFormField(
            controller: controller.stripeTestSecretKeyController,
            labelText: 'Stripe Test Secret Key (sk_test_...)',
            hintText: 'Stored on this device only — never sent to our server',
            obscureText: true,
            borderRadius: 12,
            customFocusedBorderColor: theme.secondaryColor.value,
            customEnabledBorderColor: ColorResources.cardBorderColor,
          ),
        ],
        SizedBox(height: context.spacingSM),
        Obx(() {
          final connecting = controller.isTerminalConnecting.value;
          final connected = controller.isTerminalConnected.value;
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
                        color: connecting
                            ? Colors.grey
                            : (connected
                                  ? ColorResources.successGreen
                                  : ColorResources.gradientRed),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      connecting
                          ? 'Connecting reader...'
                          : (connected ? 'Reader Connected' : 'Not Connected'),
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.labelColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed:
                        connecting ? null : controller.testTerminalConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: connected
                          ? Colors.grey[200]
                          : theme.primaryColor.value,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: connecting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'CONNECT',
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
        }),
      ],
    );
  }
}
