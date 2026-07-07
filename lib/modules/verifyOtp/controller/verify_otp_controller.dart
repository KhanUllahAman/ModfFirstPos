import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/auth/service/send_otp_service.dart';
import 'package:modfirstpos/modules/verifyOtp/service/verify_otp_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class VerifyOtpController extends GetxController {
  final VerifyOtpService _verifyOtpService = Get.find<VerifyOtpService>();
  final SendOtpService _sendOtpService = Get.find<SendOtpService>();

  static const int otpLength = 6;
  static const int _resendCooldown = 30;

  final List<TextEditingController> otpControllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  final RxString email = ''.obs;
  final RxInt resendSecondsLeft = 0.obs;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    _loadEmail();
    _startResendCooldown();
  }

  Future<void> _loadEmail() async {
    email.value = await SecureStorageService.getLoginEmail() ?? '';
  }

  void _startResendCooldown() {
    resendSecondsLeft.value = _resendCooldown;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSecondsLeft.value <= 1) {
        timer.cancel();
        resendSecondsLeft.value = 0;
      } else {
        resendSecondsLeft.value--;
      }
    });
  }

  void onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index == otpFocusNodes.length - 1) {
      otpFocusNodes[index].unfocus();
    }
  }

  String get _otpCode => otpControllers.map((c) => c.text.trim()).join();

  Future<void> verifyOtp() async {
    final otp = _otpCode;
    if (otp.length < otpLength) {
      customSnackBar(
        'Error',
        'Please enter the complete $otpLength-digit code',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    CustomLoadingDialog.show();
    try {
      final response = await _verifyOtpService.verifyOtp(
        email: email.value,
        otp: otp,
      );
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      final accessToken = response.payload?.accessToken?.toString();
      if (accessToken != null && accessToken.isNotEmpty) {
        await SecureStorageService.saveAccessToken(accessToken);
      }

      customSnackBar(
        'Success',
        response.message,
        snackBarType: SnackBarType.success,
      );
      Get.offAllNamed(Routes.home);
    } catch (e) {
      log("Verify OTP error: $e");
      CustomLoadingDialog.hide();
      customSnackBar(
        'Error',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      CustomLoadingDialog.forceHide();
    }
  }

  Future<void> resendOtp() async {
    if (resendSecondsLeft.value > 0 || email.value.isEmpty) return;

    CustomLoadingDialog.show();
    try {
      final response = await _sendOtpService.sendOtp(email: email.value);
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      for (final c in otpControllers) {
        c.clear();
      }
      otpFocusNodes.first.requestFocus();
      _startResendCooldown();
      customSnackBar(
        'Success',
        response.message,
        snackBarType: SnackBarType.success,
      );
    } catch (e) {
      log("Resend OTP error: $e");
      CustomLoadingDialog.hide();
      customSnackBar(
        'Error',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      CustomLoadingDialog.forceHide();
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
