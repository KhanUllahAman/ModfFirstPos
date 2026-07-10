import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/VideoBackground/video_background.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import '../controller/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorResources.appMainColor,
          selectionHandleColor: ColorResources.appMainColor,
          selectionColor: ColorResources.appMainColor.withOpacity(0.25),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: ColorResources.backgroundColor,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Stack(
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
                                'Verify OTP',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontLG,
                                  fontWeight: FontWeight.w600,
                                  color: ColorResources.blackColor,
                                ),
                              ),
                              SizedBox(height: context.spacingXS),
                              Obx(
                                () => Text(
                                  controller.email.value.isEmpty
                                      ? 'Enter the 6-digit code sent to your email.'
                                      : 'Enter the 6-digit code sent to ${controller.email.value}',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontXS,
                                    fontWeight: FontWeight.w400,
                                    color: ColorResources.blackColor
                                        .withOpacity(0.55),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingXL),
                              Row(
                                children: List.generate(
                                  VerifyOtpController.otpLength,
                                  (index) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.spacingXS / 2,
                                      ),
                                      child: _OtpBox(
                                        controller:
                                            controller.otpControllers[index],
                                        focusNode:
                                            controller.otpFocusNodes[index],
                                        onChanged: (value) => controller
                                            .onOtpDigitChanged(value, index),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingXL),
                              Obx(
                                () => AppButton(
                                  backgroundColor: theme.secondaryColor.value,
                                  onPressed: controller.verifyOtp,
                                  isLoading: false,
                                  borderRadius: 12,
                                  child: Text(
                                    'Verify',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontMD,
                                      fontWeight: FontWeight.w500,
                                      color: theme.onSecondaryColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingMD),
                              Center(
                                child: Obx(
                                  () => TextButton(
                                    onPressed:
                                        controller.resendSecondsLeft.value == 0
                                        ? controller.resendOtp
                                        : null,
                                    child: Text(
                                      controller.resendSecondsLeft.value == 0
                                          ? "Didn't receive the code? Resend"
                                          : 'Resend code in ${controller.resendSecondsLeft.value}s',
                                      style: AppFonts.geistMono(
                                        fontSize: context.fontXS,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            controller
                                                    .resendSecondsLeft
                                                    .value ==
                                                0
                                            ? ColorResources.blackColor
                                            : ColorResources.blackColor
                                                  .withOpacity(0.4),
                                      ),
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
              ],
            ),
          ),
        ).noKeyboard(),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return AspectRatio(
      aspectRatio: 0.85,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isFocused
              ? ColorResources.whiteColor
              : ColorResources.backgroundColor,
          border: Border.all(
            color: _isFocused
                ? theme.secondaryColor.value
                : const Color(0xFFE7E9F0),
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: theme.secondaryColor.value.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            showCursor: true,
            cursorColor: theme.secondaryColor.value,
            style: AppFonts.geistMono(
              fontSize: context.fontLG,
              fontWeight: FontWeight.w600,
              color: ColorResources.blackColor,
            ),
            decoration: const InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
      ),
    );
  }
}
