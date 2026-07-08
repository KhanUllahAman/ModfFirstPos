import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/changePassword/service/change_password_service.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class ChangePasswordController extends GetxController {
  final ChangePasswordService _changePasswordService =
      Get.find<ChangePasswordService>();

  final formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final RxBool isLoading = false.obs;

  static final RegExp _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-\[\];\\/~`+=]).{8,}$',
  );

  void toggleCurrentPasswordVisibility() =>
      obscureCurrentPassword.value = !obscureCurrentPassword.value;

  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (!_strongPasswordRegex.hasMatch(value)) {
      return 'Must contain 8+ chars with uppercase, lowercase,\nnumber & special character';
    }
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _pendingErrorMessage;

  Future<void> changePassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _pendingErrorMessage = null;
    try {
      CustomLoadingDialog.show();
      isLoading.value = true;

      final response = await _changePasswordService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (!response.isSuccess) {
        _pendingErrorMessage = response.displayMessage;
        return;
      }
      _clearFields();
    } catch (e) {
      log("ChangePasswordController changePassword error: $e");
      _pendingErrorMessage = 'Something went wrong while changing password';
    } finally {
      CustomLoadingDialog.hide();
      isLoading.value = false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_pendingErrorMessage != null) {
        customSnackBar(
          'Error',
          _pendingErrorMessage!,
          snackBarType: SnackBarType.error,
        );
      } else {
        customSnackBar(
          'Success',
          'Password changed successfully',
          snackBarType: SnackBarType.success,
        );
        Navigator.of(Get.context!).pop(); // Close the Change Password screen
      }
    }
  }

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
