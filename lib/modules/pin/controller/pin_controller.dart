import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/pin_hash_util.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';

class PinController extends GetxController with WidgetsBindingObserver {
  final PinService _pinService = Get.find<PinService>();
  final RxBool pinEnabled = false.obs;
  final RxInt autoLockMinutes = 10.obs;
  final RxBool isLocked = false.obs;
  final RxBool isLoading = false.obs;
  final RxString verifyError = ''.obs;

  // GetX-based pin entry state (replaces StatefulWidget state)
  final RxString enteredPin = ''.obs;

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
    enteredPin.value = '';
    _stopIdleWatcher();
    SecureStorageService.saveWasLocked(true);
  }

  Future<bool> unlockWithPin(String pin) async {
    final isOnline = !Get.isRegistered<ConnectivityService>() ||
        Get.find<ConnectivityService>().isConnected;

    // Fully offline: skip the network call entirely and verify against the
    // locally saved hash (kept in sync on every successful online
    // verify/set/change) so a dead network can never lock the cashier out.
    if (!isOnline) {
      return _unlockOffline(pin);
    }

    try {
      isLoading.value = true;
      verifyError.value = '';
      final response = await _pinService.verifyPin(pin: pin);
      if (response.isSuccess) {
        await SecureStorageService.savePinHash(await PinHashUtil.hash(pin));
        _completeUnlock();
        return true;
      } else {
        verifyError.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      if (e is NoInternetException) {
        // Connectivity dropped between the check above and the call.
        return _unlockOffline(pin);
      }
      verifyError.value = e is AppException
          ? e.message
          : 'Something went wrong. Please try again.';
      log("PinController unlockWithPin error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _unlockOffline(String pin) async {
    final savedHash = await SecureStorageService.getPinHash();
    if (savedHash == null || savedHash.isEmpty) {
      verifyError.value =
          'No internet connection. Connect once to enable offline unlock.';
      return false;
    }
    if (await PinHashUtil.hash(pin) != savedHash) {
      verifyError.value = 'Incorrect PIN';
      return false;
    }
    _completeUnlock();
    return true;
  }

  void _completeUnlock() {
    isLocked.value = false;
    enteredPin.value = '';
    _lastActiveAt = DateTime.now();
    _startIdleWatcher();
    SecureStorageService.saveWasLocked(false);
    SecureStorageService.saveLastActiveAt(_lastActiveAt!);
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

  /// Clears the lock overlay and idle-timer state on logout. Without this
  /// the lock screen (a permanent, app-wide overlay — see
  /// AppLockWrapper) keeps showing after logout, since `isLocked` is
  /// otherwise only ever cleared by successfully entering the PIN.
  void resetForLogout() {
    _stopIdleWatcher();
    isLocked.value = false;
    pinEnabled.value = false;
    enteredPin.value = '';
    verifyError.value = '';
    _lastActiveAt = null;
    SecureStorageService.saveWasLocked(false);
  }

  void onPinDigit(String digit) {
    if (enteredPin.value.length >= 6) return;
    verifyError.value = '';
    enteredPin.value += digit;
    if (enteredPin.value.length == 4) {
      _tryVerifyPin();
    }
  }

  void onPinBackspace() {
    if (enteredPin.value.isEmpty) return;
    enteredPin.value =
        enteredPin.value.substring(0, enteredPin.value.length - 1);
  }

  Future<void> _tryVerifyPin() async {
    final pin = enteredPin.value;
    final success = await unlockWithPin(pin);
    if (!success) {
      enteredPin.value = '';
    }
  }
}
