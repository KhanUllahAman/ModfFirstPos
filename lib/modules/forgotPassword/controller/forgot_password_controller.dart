import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/forgotPassword/service/forgot_password_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordService _forgotPasswordService =
      Get.find<ForgotPasswordService>();

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isEmailSent = false.obs;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    CustomLoadingDialog.show();
    try {
      final response =
          await _forgotPasswordService.forgotPassword(email: email);
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }
      isEmailSent.value = true;
      await SecureStorageService.saveLoginEmail(email);

      customSnackBar(
        'Success',
        response.message,
        snackBarType: SnackBarType.success,
      );

      Get.toNamed(Routes.verifyOtp);
    } catch (e) {
      log("Forgot password error: $e");
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
    emailController.dispose();
    super.onClose();
  }
}