import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/VideoBackground/video_background.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: theme.secondaryColor.value,
          selectionHandleColor: theme.secondaryColor.value,
          selectionColor: theme.secondaryColor.value.withOpacity(0.25),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: ColorResources.backgroundColor,
          body: Stack(
            children: [
              const VideoBackground(assetPath: 'assets/videos/posvideo.mp4'),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveWidth(0.06),
                      vertical: context.spacingLG,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.spacingLG),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE7E9F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.zero,
                              ),
                              SizedBox(height: context.spacingXS),
                              Text(
                                'Forgot Password',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontLG,
                                  fontWeight: FontWeight.w600,
                                  color: ColorResources.blackColor,
                                ),
                              ),
                              SizedBox(height: context.spacingXS),
                              Text(
                                'Enter your store email and we will send you reset instructions.',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  fontWeight: FontWeight.w400,
                                  color: ColorResources.blackColor.withOpacity(
                                    0.55,
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingXL),
                              CustomTextFormField(
                                controller: controller.emailController,
                                labelText: 'Store Email',
                                validator: controller.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                borderRadius: 12,
                                customFocusedBorderColor:
                                    ColorResources.blackColor,
                                customEnabledBorderColor:
                                    ColorResources.blackColor,
                              ),
                              SizedBox(height: context.spacingMD),
                              Obx(
                                () => AppButton(
                                  backgroundColor: theme.secondaryColor.value,
                                  onPressed: controller.submit,
                                  isLoading: false,
                                  borderRadius: 12,
                                  child: Text(
                                    controller.isEmailSent.value
                                        ? 'Resend Instructions'
                                        : 'Send Reset Link',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontMD,
                                      fontWeight: FontWeight.w500,
                                      color: theme.onSecondaryColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).noKeyboard(),
      ),
    );
  }
}
