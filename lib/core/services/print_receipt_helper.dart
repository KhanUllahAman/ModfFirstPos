import 'dart:developer';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/modules/order/service/print_receipt_service.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

/// Shared "fetch receipt data + send to the configured POS device printer"
/// flow, used from both the order details pane and the home screen
/// checkout success path.
class PrintReceiptHelper {
  static final PrintReceiptService _receiptService = PrintReceiptService();
  static final ThermalPrinterService _printerService = ThermalPrinterService();

  static Future<bool> printOrderReceipt(int orderId) async {
    try {
      var device = await PosDeviceCacheStorage.getDevice();
      if (device == null) {
        final devicesResponse = await SettingService().getMyBranchDevices();
        if (devicesResponse.isSuccess && devicesResponse.payload.isNotEmpty) {
          device = devicesResponse.payload.first;
          await PosDeviceCacheStorage.saveDevice(device);
        }
      }

      if (device == null || device.ipAddress.trim().isEmpty) {
        customSnackBar(
          'Print Receipt',
          'No printer IP configured. Please set it up in Settings.',
          snackBarType: SnackBarType.warning,
        );
        return false;
      }

      final receiptResponse = await _receiptService.getReceiptData(orderId);
      if (!receiptResponse.isSuccess || receiptResponse.payload == null) {
        customSnackBar(
          'Print Receipt',
          receiptResponse.message.isNotEmpty
              ? receiptResponse.message
              : 'Could not fetch receipt data.',
          snackBarType: SnackBarType.error,
        );
        return false;
      }

      final printed = await _printerService.printReceipt(
        receiptResponse.payload!,
        printerIp: device.ipAddress,
      );

      if (printed) {
        customSnackBar(
          'Print Receipt',
          'Receipt sent to printer.',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Print Receipt',
          'Could not reach the printer at ${device.ipAddress}.',
          snackBarType: SnackBarType.error,
        );
      }
      return printed;
    } catch (e) {
      log('PrintReceiptHelper printOrderReceipt error: $e');
      customSnackBar(
        'Print Receipt',
        'Something went wrong while printing the receipt.',
        snackBarType: SnackBarType.error,
      );
      return false;
    }
  }
}
