import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

enum SetPinStage { enterNew, confirmNew }

class SetPinController extends GetxController {
  final PinService _pinService = Get.find<PinService>();

  final RxString firstPin = ''.obs;
  final RxString confirmPin = ''.obs;
  final Rx<SetPinStage> stage = SetPinStage.enterNew.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;

  void onDigit(String digit) {
    errorMessage.value = '';
    if (stage.value == SetPinStage.enterNew) {
      if (firstPin.value.length >= 6) return;
      firstPin.value += digit;
      if (firstPin.value.length == 4) {
        Future.delayed(const Duration(milliseconds: 150), () {
          stage.value = SetPinStage.confirmNew;
        });
      }
    } else {
      if (confirmPin.value.length >= 6) return;
      confirmPin.value += digit;
      if (confirmPin.value.length == firstPin.value.length) {
        _submit();
      }
    }
  }

  void onBackspace() {
    if (stage.value == SetPinStage.enterNew) {
      if (firstPin.value.isEmpty) return;
      firstPin.value = firstPin.value.substring(0, firstPin.value.length - 1);
    } else {
      if (confirmPin.value.isEmpty) return;
      confirmPin.value = confirmPin.value.substring(
        0,
        confirmPin.value.length - 1,
      );
    }
  }

  void _resetToStart() {
    firstPin.value = '';
    confirmPin.value = '';
    stage.value = SetPinStage.enterNew;
  }

  Future<void> _submit() async {
    try {
      isLoading.value = true;
      CustomLoadingDialog.show();

      final response = await _pinService.setPin(
        pin: firstPin.value,
        confirmPin: confirmPin.value,
      );
      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        errorMessage.value = response.displayMessage;
        _resetToStart();
        return;
      }

      await Get.find<PinController>().fetchPinStatus();
      Get.back();
      customSnackBar(
        'Success',
        'Screen-lock PIN has been enabled',
        snackBarType: SnackBarType.success,
      );
    } catch (e) {
      log("SetPinController submit error: $e");
      CustomLoadingDialog.hide();
      errorMessage.value = e is AppException
          ? e.message
          : 'Something went wrong. Please try again.';
      _resetToStart();
    } finally {
      isLoading.value = false;
    }
  }
}
