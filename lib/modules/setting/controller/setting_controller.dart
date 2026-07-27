import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';
import 'package:modfirstpos/core/services/stripe_terminal_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/storage/stripe_terminal_settings_storage.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class SettingController extends GetxController {
  final SettingService _service = SettingService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController deviceCodeController = TextEditingController();
  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController customerIpController = TextEditingController();
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

  // -- Stripe Terminal (card-present) — see docs/POS_PAYMENT_FLUTTER.md --
  final StripeTerminalService _terminal = Get.find<StripeTerminalService>();
  final TextEditingController readerIdController = TextEditingController();
  final RxBool useSimulatedReader = true.obs;

  // Test-only: simulate a card being presented on a simulated reader,
  // bypassing the need for a real physical reader or a backend endpoint.
  // See docs/POS_PAYMENT_FLUTTER.md.
  final TextEditingController stripeReaderTmrIdController = TextEditingController();
  final TextEditingController stripeTestSecretKeyController = TextEditingController();

  RxBool get isTerminalConnecting => _terminal.isConnecting;
  RxBool get isTerminalConnected => _terminal.isConnected;
  RxString get terminalError => _terminal.lastError;

  @override
  void onInit() {
    super.onInit();
    _hydrateFromCache();
    _hydrateTerminalSettings();
  }

  // Test-only defaults so a fresh install/testing device is ready to go
  // without the cashier having to type these in manually. Only used when
  // nothing has been saved yet.
  static const _defaultReaderId = '1';
  static const _defaultStripeReaderTmrId = 'tmr_Gl78pgX7MSyoIw';
  static const _defaultStripeTestSecretKey =
      'sk_test_51Tng6EBuoZOYjaKmiMqwAdBth27RHZI05dEJ7SGhGDKbZJ8OwXGzb9VYz2h4rMIUp23WiSQ0Gr3iodlXbgRdjaDc008KKrJF9R';

  Future<void> _hydrateTerminalSettings() async {
    final readerId = await StripeTerminalSettingsStorage.getReaderId();
    readerIdController.text = readerId ?? _defaultReaderId;
    useSimulatedReader.value = await StripeTerminalSettingsStorage.getUseSimulated();

    final tmrId = await StripeTerminalSettingsStorage.getStripeReaderTmrId();
    stripeReaderTmrIdController.text = tmrId ?? _defaultStripeReaderTmrId;
    final secretKey = await SecureStorageService.getStripeTestSecretKey();
    stripeTestSecretKeyController.text = secretKey ?? _defaultStripeTestSecretKey;

    // Persist the defaults immediately so testing works without an extra
    // manual "Save" tap.
    if (readerId == null || tmrId == null || secretKey == null) {
      await saveTerminalSettings(showSnackbar: false);
    }
  }

  Future<void> saveTerminalSettings({bool showSnackbar = true}) async {
    await StripeTerminalSettingsStorage.saveReaderId(readerIdController.text.trim());
    await StripeTerminalSettingsStorage.saveUseSimulated(useSimulatedReader.value);
    await StripeTerminalSettingsStorage.saveStripeReaderTmrId(
      stripeReaderTmrIdController.text.trim(),
    );
    await SecureStorageService.saveStripeTestSecretKey(
      stripeTestSecretKeyController.text.trim(),
    );
    if (!showSnackbar) return;
    customSnackBar(
      'Stripe Terminal',
      'Reader settings saved.',
      snackBarType: SnackBarType.success,
    );
  }

  /// Connects to the reader now (simulated or real, per the toggle) so the
  /// cashier can confirm the setup works before a live sale.
  Future<void> testTerminalConnection() async {
    await saveTerminalSettings();
    final connected = await _terminal.connect(simulated: useSimulatedReader.value);
    if (connected) {
      customSnackBar(
        'Stripe Terminal',
        'Reader connected${useSimulatedReader.value ? ' (simulated)' : ''}.',
        snackBarType: SnackBarType.success,
      );
    } else {
      customSnackBar(
        'Stripe Terminal',
        _terminal.lastError.value.isNotEmpty
            ? _terminal.lastError.value
            : 'Could not connect to the reader.',
        snackBarType: SnackBarType.error,
      );
    }
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
    customerIpController.dispose();
    readerIdController.dispose();
    stripeReaderTmrIdController.dispose();
    stripeTestSecretKeyController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void _applyDevice(PosDeviceModel device) {
    currentDevice.value = device;
    nameController.text = device.name;
    deviceCodeController.text = device.deviceCode;
    ipAddressController.text = device.ipAddress;
    customerIpController.text = device.customerIp ?? '';
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

  /// Tests reachability of the customer-facing display tab — that tab runs
  /// the CustomerDisplayServer on [CustomerDisplayConfig.port], so a
  /// successful handshake here means the two tabs can actually pair up.
  Future<void> checkCashierConnection() async {
    try {
      isCheckingCashier.value = true;
      isCashierConnected.value = await _pingHost(
        customerIpController.text,
        port: CustomerDisplayConfig.port,
      );

      if (isCashierConnected.value) {
        customSnackBar(
          'Customer Display Diagnostic',
          'Successfully established connection to Customer Tab at ${customerIpController.text}',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Customer Display Diagnostic',
          customerIpController.text.trim().isEmpty
              ? 'Connection failed. Customer IP is empty.'
              : 'Could not reach ${customerIpController.text}. Make sure the customer tab is on and open on the Customer Display screen.',
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
      customerIp: customerIpController.text.trim(),
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
        if (Get.isRegistered<CustomerDisplayClientService>() &&
            response.payload!.customerIp != null &&
            response.payload!.customerIp!.trim().isNotEmpty) {
          unawaited(
            Get.find<CustomerDisplayClientService>().connect(
              response.payload!.customerIp!,
            ),
          );
        }
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
