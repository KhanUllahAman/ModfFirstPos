import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/changePassword/controller/change_password_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () => Get.back()),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveWidth(0.03)),
            child: Form(
              key: controller.formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BackBar(title: "Change Password"),
                    SizedBox(height: context.spacingLG),
                    Text(
                      "Choose a strong password to keep your account secure.",
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w400,
                        color: ColorResources.blackColor.withOpacity(0.55),
                      ),
                    ),
                    SizedBox(height: context.spacingLG),
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.currentPasswordController,
                        labelText: "Current Password",
                        hintText: "Enter your current password",
                        obscureText: controller.obscureCurrentPassword.value,
                        keyboardType: TextInputType.visiblePassword,
                        isPasswordField: true,
                        onSuffixIconPressed:
                            controller.toggleCurrentPasswordVisibility,
                        borderRadius: 12,
                        customFocusedBorderColor: ColorResources.blackColor,
                        customEnabledBorderColor: ColorResources.blackColor,
                        validator: controller.validateCurrentPassword,
                      ),
                    ),
                    SizedBox(height: context.spacingMD),
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.newPasswordController,
                        labelText: "New Password",
                        hintText: "Enter your new password",
                        obscureText: controller.obscureNewPassword.value,
                        keyboardType: TextInputType.visiblePassword,
                        isPasswordField: true,
                        onSuffixIconPressed:
                            controller.toggleNewPasswordVisibility,
                        borderRadius: 12,
                        customFocusedBorderColor: ColorResources.blackColor,
                        customEnabledBorderColor: ColorResources.blackColor,
                        validator: controller.validateNewPassword,
                      ),
                    ),
                    SizedBox(height: context.spacingMD),
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.confirmPasswordController,
                        labelText: "Confirm New Password",
                        hintText: "Re-enter your new password",
                        obscureText: controller.obscureConfirmPassword.value,
                        keyboardType: TextInputType.visiblePassword,
                        isPasswordField: true,
                        onSuffixIconPressed:
                            controller.toggleConfirmPasswordVisibility,
                        borderRadius: 12,
                        customFocusedBorderColor: ColorResources.blackColor,
                        customEnabledBorderColor: ColorResources.blackColor,
                        validator: controller.validateConfirmPassword,
                      ),
                    ),
                    SizedBox(height: context.spacingXL),
                    Obx(
                      () => AppButton(
                        backgroundColor: theme.primaryColor.value,
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.changePassword,
                        isLoading: controller.isLoading.value,
                        borderRadius: 12,
                        child: Text(
                          controller.isLoading.value
                              ? "Updating..."
                              : "Change Password",
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM,
                            fontWeight: FontWeight.w500,
                            color: theme.onPrimaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.spacingMD),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).noKeyboard();
  }
}
