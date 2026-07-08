// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:modfirstpos/modules/pin/service/pin_service.dart';

// class PinController extends GetxController with WidgetsBindingObserver {
//   final PinService _pinService = Get.find<PinService>();
//   final RxBool pinEnabled = false.obs;
//   final RxInt autoLockMinutes = 10.obs;
//   final RxBool isLocked = false.obs;
//   final RxBool isLoading = false.obs;
//   final RxString verifyError = ''.obs;

//   Timer? _idleTimer;

//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     fetchPinStatus();
//   }

//   Future<void> fetchPinStatus() async {
//     try {
//       final response = await _pinService.getPinStatus();
//       if (response.isSuccess && response.payload != null) {
//         pinEnabled.value = response.payload!.pinEnabled;
//         autoLockMinutes.value = response.payload!.autoLockMinutes;
//         if (pinEnabled.value) _restartIdleTimer();
//       }
//     } catch (e) {
//       log("PinController fetchPinStatus error: $e");
//     }
//   }

//   void registerActivity() {
//     if (!pinEnabled.value || isLocked.value) return;
//     _restartIdleTimer();
//   }

//   void _restartIdleTimer() {
//     _idleTimer?.cancel();
//     if (!pinEnabled.value) return;
//     _idleTimer = Timer(Duration(minutes: autoLockMinutes.value), () {
//       lockNow();
//     });
//   }

//   void _cancelIdleTimer() {
//     _idleTimer?.cancel();
//     _idleTimer = null;
//   }

//   void lockNow() {
//     if (!pinEnabled.value) return;
//     isLocked.value = true;
//     verifyError.value = '';
//     _cancelIdleTimer();
//   }

//   Future<bool> unlockWithPin(String pin) async {
//     try {
//       isLoading.value = true;
//       verifyError.value = '';
//       final response = await _pinService.verifyPin(pin: pin);
//       if (response.isSuccess) {
//         isLocked.value = false;
//         _restartIdleTimer();
//         return true;
//       } else {
//         verifyError.value = response.displayMessage;
//         return false;
//       }
//     } catch (e) {
//       log("PinController unlockWithPin error: $e");
//       verifyError.value = 'Something went wrong. Try again.';
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!pinEnabled.value) return;
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       lockNow();
//     }
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cancelIdleTimer();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';

class PinController extends GetxController with WidgetsBindingObserver {
  final PinService _pinService = Get.find<PinService>();
  final RxBool pinEnabled = false.obs;
  final RxInt autoLockMinutes = 10.obs;
  final RxBool isLocked = false.obs;
  final RxBool isLoading = false.obs;
  final RxString verifyError = ''.obs;

  Timer? _tickTimer;
  DateTime? _lastActiveAt;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _restoreLockStateFromStorage();
    fetchPinStatus();
  }

  Future<void> _restoreLockStateFromStorage() async {
    final wasLocked = await SecureStorageService.getWasLocked();
    final lastActive = await SecureStorageService.getLastActiveAt();

    if (lastActive != null) _lastActiveAt = lastActive;

    if (wasLocked) {
      isLocked.value = true;
      return;
    }

    if (lastActive != null) {
      final idleFor = DateTime.now().difference(lastActive);
      if (idleFor >= Duration(minutes: autoLockMinutes.value)) {
        isLocked.value = true;
      }
    }
  }

  Future<void> fetchPinStatus() async {
    try {
      final response = await _pinService.getPinStatus();
      if (response.isSuccess && response.payload != null) {
        pinEnabled.value = response.payload!.pinEnabled;
        autoLockMinutes.value = response.payload!.autoLockMinutes;
        if (pinEnabled.value) _startIdleWatcher();
      }
    } catch (e) {
      log("PinController fetchPinStatus error: $e");
    }
  }

  void registerActivity() {
    if (!pinEnabled.value || isLocked.value) return;
    _lastActiveAt = DateTime.now();
    if (_tickTimer == null) _startIdleWatcher();
  }

  void _startIdleWatcher() {
    _tickTimer?.cancel();
    _lastActiveAt ??= DateTime.now();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!pinEnabled.value || isLocked.value) return;
      final idleFor = DateTime.now().difference(_lastActiveAt!);
      if (idleFor >= Duration(minutes: autoLockMinutes.value)) {
        lockNow();
      }
    });
  }

  void _stopIdleWatcher() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void lockNow() {
    if (!pinEnabled.value) return;
    isLocked.value = true;
    verifyError.value = '';
    _stopIdleWatcher();
    SecureStorageService.saveWasLocked(true);
  }

  Future<bool> unlockWithPin(String pin) async {
    try {
      isLoading.value = true;
      verifyError.value = '';
      final response = await _pinService.verifyPin(pin: pin);
      if (response.isSuccess) {
        isLocked.value = false;
        _lastActiveAt = DateTime.now();
        _startIdleWatcher();
        SecureStorageService.saveWasLocked(false);
        SecureStorageService.saveLastActiveAt(_lastActiveAt!);
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
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_lastActiveAt != null) {
        SecureStorageService.saveLastActiveAt(_lastActiveAt!);
      }
      SecureStorageService.saveWasLocked(isLocked.value);
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_lastActiveAt != null) {
        final idleFor = DateTime.now().difference(_lastActiveAt!);
        if (idleFor >= Duration(minutes: autoLockMinutes.value)) {
          lockNow();
          return;
        }
      }
      if (!isLocked.value) _startIdleWatcher();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopIdleWatcher();
    super.onClose();
  }
}
