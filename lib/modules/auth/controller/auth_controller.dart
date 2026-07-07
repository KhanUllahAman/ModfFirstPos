import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/auth/service/auth_service.dart';
import 'package:modfirstpos/modules/auth/service/send_otp_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import '../../../shared/widgets/Snackbar/custom_snackbar.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SendOtpService _sendOtpService = Get.find<SendOtpService>();

  final TextEditingController storeEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  String? validateStoreEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required' : null;

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final email = storeEmailController.text.trim();
    final password = passwordController.text.trim();
    CustomLoadingDialog.show();
    try {
      final loginResponse = await _authService.login(
        email: email,
        password: password,
      );

      if (!loginResponse.isSuccess) {
        CustomLoadingDialog.hide();
        customSnackBar(
          'Error',
          loginResponse.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      await SecureStorageService.saveLoginEmail(email);
      final otpResponse = await _sendOtpService.sendOtp(email: email);
      CustomLoadingDialog.hide();

      if (!otpResponse.isSuccess) {
        customSnackBar(
          'Error',
          otpResponse.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      customSnackBar(
        'Success',
        otpResponse.message,
        snackBarType: SnackBarType.success,
      );
      Get.toNamed(Routes.verifyOtp);
    } catch (e) {
      log("Login error: $e");
      CustomLoadingDialog.hide();
      final errorMessage = e is AppException
          ? e.message
          : 'Something went wrong. Please try again.';

      customSnackBar(
        'Error',
        errorMessage,
        snackBarType: SnackBarType.error,
      );
    } finally {
      CustomLoadingDialog.forceHide();
    }
  }

  @override
  void onClose() {
    storeEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
