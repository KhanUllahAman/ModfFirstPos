import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/auth/controller/auth_controller.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/dynamic_network_image.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';

class LoginFormCard extends StatelessWidget {
  final AuthController controller;

  const LoginFormCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Container(
      width: double.infinity,
      height: context.responsiveHeight(0.75),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E9F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingLG,
          vertical: context.spacingLG,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.spacingLG,
                vertical: context.spacingLG,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DynamicAppLogo(height: context.responsiveHeight(0.10)),
                      Text(
                        'Sign in to your store',
                        textAlign: TextAlign.center,
                        style: AppFonts.geistMono(
                          fontSize: context.fontLG,
                          fontWeight: FontWeight.w600,
                          color: ColorResources.blackColor,
                        ),
                      ),
                      SizedBox(height: context.spacingXS),
                      Text(
                        'Enter your store details to continue.',
                        textAlign: TextAlign.center,
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.w400,
                          color: ColorResources.blackColor.withOpacity(0.55),
                        ),
                      ),
                      SizedBox(height: context.spacingXL),
                      CustomTextFormField(
                        controller: controller.storeEmailController,
                        labelText: 'Store Email',
                        validator: controller.validateStoreEmail,
                        keyboardType: TextInputType.emailAddress,
                        borderRadius: 12,
                        customFocusedBorderColor: ColorResources.blackColor,
                        customEnabledBorderColor: ColorResources.blackColor,
                      ),
                      SizedBox(height: context.spacingSM),
                      Obx(
                        () => CustomTextFormField(
                          controller: controller.passwordController,
                          labelText: 'Password',
                          validator: controller.validatePassword,
                          isPasswordField: true,
                          obscureText: !controller.isPasswordVisible.value,
                          onSuffixIconPressed:
                              controller.togglePasswordVisibility,
                          borderRadius: 12,
                          customFocusedBorderColor: ColorResources.blackColor,
                          customEnabledBorderColor: ColorResources.blackColor,
                        ),
                      ),
                      SizedBox(height: context.spacingMD),
                      Obx(
                        () => AppButton(
                          backgroundColor: theme.secondaryColor.value,
                          onPressed: () {
                            controller.login(controller.formKey);
                          },
                          isLoading: false,
                          borderRadius: 12,
                          child: Text(
                            'Login',
                            style: AppFonts.geistMono(
                              fontSize: context.fontMD,
                              fontWeight: FontWeight.w500,
                              color: theme.onSecondaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.forgotPassword),
                          child: Text(
                            'Forgot Password?',
                            style: AppFonts.geistMono(
                              fontSize: context.fontXS,
                              fontWeight: FontWeight.w500,
                              color: ColorResources.blackColor.withOpacity(
                                0.75,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
