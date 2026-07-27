import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/pin_hash_util.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class PinSettingsController extends GetxController {
  final PinService _pinService = Get.find<PinService>();
  PinController get pinController => Get.find<PinController>();

  final RxBool isLoading = false.obs;
  final RxInt autoLockMinutes = 10.obs;

  @override
  void onInit() {
    super.onInit();
    autoLockMinutes.value = pinController.autoLockMinutes.value;
  }

  Future<void> disablePin(String currentPin) async {
    try {
      isLoading.value = true;
      CustomLoadingDialog.show();
      final response = await _pinService.disablePin(currentPin: currentPin);
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.displayMessage,
          snackBarType: SnackBarType.error,
        );
        return;
      }
      await SecureStorageService.deletePinHash();
      await pinController.fetchPinStatus();
      Get.back();
      customSnackBar(
        'Success',
        'Screen-lock PIN disabled',
        snackBarType: SnackBarType.success,
      );
    } catch (e) {
      log("PinSettingsController disablePin error: $e");
      CustomLoadingDialog.hide();
      final message = e is AppException ? e.message : 'Something went wrong';
      customSnackBar('Error', message, snackBarType: SnackBarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String confirmNewPin,
  }) async {
    if (newPin != confirmNewPin) {
      customSnackBar(
        'Error',
        'New PIN and Confirm PIN do not match',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    if (newPin.length < 4) {
      customSnackBar(
        'Error',
        'PIN must be at least 4 digits',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    try {
      isLoading.value = true;
      CustomLoadingDialog.show();

      final response = await _pinService.changePin(
        currentPin: currentPin,
        newPin: newPin,
        confirmNewPin: confirmNewPin,
      );
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.displayMessage,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      await SecureStorageService.savePinHash(PinHashUtil.hash(newPin));
      Get.back();
      customSnackBar(
        'Success',
        'PIN changed successfully',
        snackBarType: SnackBarType.success,
      );
    } catch (e) {
      log("PinSettingsController changePin error: $e");
      CustomLoadingDialog.hide();
      final message = e is AppException ? e.message : 'Something went wrong';
      customSnackBar('Error', message, snackBarType: SnackBarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAutoLock(int minutes) async {
    try {
      isLoading.value = true;
      final response = await _pinService.updateAutoLockMinutes(minutes);
      if (response.isSuccess && response.autoLockMinutes != null) {
        autoLockMinutes.value = response.autoLockMinutes!;
        pinController.autoLockMinutes.value = response.autoLockMinutes!;
        customSnackBar(
          'Success',
          'Auto-lock updated',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("PinSettingsController updateAutoLock error: $e");
      customSnackBar(
        'Error',
        'Something went wrong',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
