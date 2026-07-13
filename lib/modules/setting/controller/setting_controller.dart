import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class SettingController extends GetxController {
  final TextEditingController printerIpController = TextEditingController();
  final TextEditingController customerIpController = TextEditingController();
  final TextEditingController customerPortController = TextEditingController();

  final RxBool isPrinterConnected = false.obs;
  final RxBool isCashierConnected = false.obs;

  final RxBool isCheckingPrinter = false.obs;
  final RxBool isCheckingCashier = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default mock configurations
    printerIpController.text = '192.168.1.200';
    customerIpController.text = '192.168.1.201';
    customerPortController.text = '8080';
  }

  @override
  void onClose() {
    printerIpController.dispose();
    customerIpController.dispose();
    customerPortController.dispose();
    super.onClose();
  }

  Future<void> checkPrinterConnection() async {
    try {
      isCheckingPrinter.value = true;
      // Mock network latency for printer check
      await Future.delayed(const Duration(seconds: 2));
      isPrinterConnected.value = printerIpController.text.isNotEmpty;
      
      if (isPrinterConnected.value) {
        customSnackBar(
          'Printer Diagnostic',
          'Successfully connected to printer at ${printerIpController.text}',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Printer Diagnostic',
          'Connection failed. IP address is empty.',
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
      // Mock network latency for Cashier tab check
      await Future.delayed(const Duration(seconds: 2));
      isCashierConnected.value = customerIpController.text.isNotEmpty && customerPortController.text.isNotEmpty;

      if (isCashierConnected.value) {
        customSnackBar(
          'Cashier Diagnostic',
          'Successfully established connection to Cashier Tab at ${customerIpController.text}:${customerPortController.text}',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Cashier Diagnostic',
          'Connection failed. Please provide a valid IP and Port.',
          snackBarType: SnackBarType.warning,
        );
      }
    } catch (e) {
      isCashierConnected.value = false;
    } finally {
      isCheckingCashier.value = false;
    }
  }

  void getSettingsFromServer() {
    customSnackBar(
      'Server Settings',
      'Settings retrieved successfully from server (mocked).',
      snackBarType: SnackBarType.info,
    );
  }

  void updateSettingsToServer() {
    customSnackBar(
      'Server Settings',
      'Settings updated successfully to server (mocked).',
      snackBarType: SnackBarType.success,
    );
  }
}
