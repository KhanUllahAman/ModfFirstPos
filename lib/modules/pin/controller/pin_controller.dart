import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';

class PinController extends GetxController with WidgetsBindingObserver {
  final PinService _pinService = Get.find<PinService>();
  final RxBool pinEnabled = false.obs;
  final RxInt autoLockMinutes = 10.obs;
  final RxBool isLocked = false.obs;
  final RxBool isLoading = false.obs;
  final RxString verifyError = ''.obs;

  Timer? _idleTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchPinStatus();
  }

  Future<void> fetchPinStatus() async {
    try {
      final response = await _pinService.getPinStatus();
      if (response.isSuccess && response.payload != null) {
        pinEnabled.value = response.payload!.pinEnabled;
        autoLockMinutes.value = response.payload!.autoLockMinutes;
        if (pinEnabled.value) _restartIdleTimer();
      }
    } catch (e) {
      log("PinController fetchPinStatus error: $e");
    }
  }

  void registerActivity() {
    if (!pinEnabled.value || isLocked.value) return;
    _restartIdleTimer();
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    if (!pinEnabled.value) return;
    _idleTimer = Timer(Duration(minutes: autoLockMinutes.value), () {
      lockNow();
    });
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  void lockNow() {
    if (!pinEnabled.value) return;
    isLocked.value = true;
    verifyError.value = '';
    _cancelIdleTimer();
  }

  Future<bool> unlockWithPin(String pin) async {
    try {
      isLoading.value = true;
      verifyError.value = '';
      final response = await _pinService.verifyPin(pin: pin);
      if (response.isSuccess) {
        isLocked.value = false;
        _restartIdleTimer();
        return true;
      } else {
        verifyError.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      log("PinController unlockWithPin error: $e");
      verifyError.value = 'Something went wrong. Try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!pinEnabled.value) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      lockNow();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelIdleTimer();
    super.onClose();
  }
}
