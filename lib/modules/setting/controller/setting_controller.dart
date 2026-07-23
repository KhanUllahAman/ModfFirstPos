import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class SettingController extends GetxController {
  final SettingService _service = SettingService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();
  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final RxString deviceType = 'tablet'.obs;
  final RxString receiptType = 'thermal_80mm'.obs;
  final RxBool isActive = true.obs;

  final Rxn<PosDeviceModel> currentDevice = Rxn<PosDeviceModel>();

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  final RxBool isPrinterConnected = false.obs;
  final RxBool isCashierConnected = false.obs;

  final RxBool isCheckingPrinter = false.obs;
  final RxBool isCheckingCashier = false.obs;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromCache();
  }

  /// Instant, offline-first load from the last-known device. The cashier
  /// taps "Get from Server" explicitly to hit the network — this avoids
  /// firing a GET every time the Settings screen is opened.
  Future<void> _hydrateFromCache() async {
    final cached = await PosDeviceCacheStorage.getDevice();
    if (cached != null) {
      _applyDevice(cached);
    } else {
      // Nothing cached yet (first run on this terminal) — fetch once so the
      // form isn't empty.
      await getSettingsFromServer();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    deviceCodeController.dispose();
    ipAddressController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void _applyDevice(PosDeviceModel device) {
    currentDevice.value = device;
    nameController.text = device.name;
    deviceCodeController.text = device.deviceCode;
    ipAddressController.text = device.ipAddress;
    locationController.text = device.location;
    deviceType.value = device.deviceType;
    receiptType.value = device.receiptType;
    isActive.value = device.isActive;
  }

  /// Attempts a real TCP handshake to [host]:[port] and reports whether the
  /// device actually answered, instead of just checking the field is filled.
  Future<bool> _pingHost(String host, {int port = 9100}) async {
    if (host.trim().isEmpty) return false;
    Socket? socket;
    try {
      socket = await Socket.connect(
        host.trim(),
        port,
        timeout: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      log('SettingController _pingHost error ($host:$port): $e');
      return false;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> checkPrinterConnection() async {
    try {
      isCheckingPrinter.value = true;
      isPrinterConnected.value = await _pingHost(ipAddressController.text);

      if (isPrinterConnected.value) {
        customSnackBar(
          'Printer Diagnostic',
          'Successfully connected to printer at ${ipAddressController.text}',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Printer Diagnostic',
          ipAddressController.text.trim().isEmpty
              ? 'Connection failed. IP address is empty.'
              : 'Could not reach ${ipAddressController.text}. Check the printer is powered on and on the network.',
          snackBarType: SnackBarType.warning,
        );
      }
    } catch (e) {
      isPrinterConnected.value = false;
    } finally {
      isCheckingPrinter.value = false;
    }
  }

  Future<void> checkCashierConnection() async {
    try {
      isCheckingCashier.value = true;
      isCashierConnected.value = await _pingHost(ipAddressController.text);

      if (isCashierConnected.value) {
        customSnackBar(
          'Cashier Diagnostic',
          'Successfully established connection to Cashier Tab at ${ipAddressController.text}',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Cashier Diagnostic',
          ipAddressController.text.trim().isEmpty
              ? 'Connection failed. IP address is empty.'
              : 'Could not reach ${ipAddressController.text}.',
          snackBarType: SnackBarType.warning,
        );
      }
    } catch (e) {
      isCashierConnected.value = false;
    } finally {
      isCheckingCashier.value = false;
    }
  }

  Future<void> getSettingsFromServer() async {
    try {
      isLoading.value = true;
      final response = await _service.getMyBranchDevices();
      if (response.isSuccess && response.payload.isNotEmpty) {
        final device = response.payload.first;
        _applyDevice(device);
        await PosDeviceCacheStorage.saveDevice(device);
        customSnackBar(
          'Server Settings',
          'Settings retrieved successfully from server.',
          snackBarType: SnackBarType.info,
        );
      } else if (response.isSuccess) {
        customSnackBar(
          'Server Settings',
          'No POS device is registered for this branch.',
          snackBarType: SnackBarType.warning,
        );
      } else {
        // Fall back to the last-known cached device so the terminal stays
        // usable offline.
        final cached = await PosDeviceCacheStorage.getDevice();
        if (cached != null) {
          _applyDevice(cached);
        }
        customSnackBar(
          'Server Settings',
          response.message.isNotEmpty
              ? response.message
              : 'Could not retrieve settings from server.',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("SettingController getSettingsFromServer error: $e");
      customSnackBar(
        'Server Settings',
        'Something went wrong while retrieving settings.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettingsToServer() async {
    final device = currentDevice.value;
    if (device == null) {
      customSnackBar(
        'Server Settings',
        'No device loaded yet. Tap "Get from Server" first.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    if (nameController.text.trim().isEmpty ||
        deviceCodeController.text.trim().isEmpty ||
        ipAddressController.text.trim().isEmpty) {
      customSnackBar(
        'Validation Error',
        'Name, device code and IP address are required.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    final updated = device.copyWith(
      name: nameController.text.trim(),
      deviceCode: deviceCodeController.text.trim(),
      deviceType: deviceType.value,
      ipAddress: ipAddressController.text.trim(),
      location: locationController.text.trim(),
      receiptType: receiptType.value,
      isActive: isActive.value,
    );

    try {
      isUpdating.value = true;
      final response = await _service.updateDevice(id: device.id, device: updated);
      if (response.isSuccess && response.payload != null) {
        _applyDevice(response.payload!);
        await PosDeviceCacheStorage.saveDevice(response.payload!);
        customSnackBar(
          'Server Settings',
          'Settings updated successfully to server.',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Server Settings',
          response.message.isNotEmpty
              ? response.message
              : 'Could not update settings.',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("SettingController updateSettingsToServer error: $e");
      customSnackBar(
        'Server Settings',
        'Something went wrong while updating settings.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
