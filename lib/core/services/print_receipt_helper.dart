import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';
import 'package:modfirstpos/modules/order/model/print_receipt_model.dart';
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
  static final _dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mm a");

  /// Builds the receipt entirely from the [order] already on screen (plus
  /// the cached bootstrap snapshot for company/branch info) and prints it
  /// directly — no `/orders/print-receipt` API call, so it works for any
  /// order regardless of connectivity.
  static Future<bool> printOrderReceiptLocally(OrderModel order) async {
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

      final bootstrap = Get.isRegistered<BootstrapController>()
          ? Get.find<BootstrapController>().data.value
          : null;

      final receipt = ReceiptDataModel(
        company: ReceiptCompanyModel(
          name: bootstrap?.store.siteName,
          logoUrl: bootstrap?.store.logoBlackUrl ?? bootstrap?.store.logoUrl,
          tagline: bootstrap?.store.siteTagline,
          phone: bootstrap?.store.contactPhone,
          email: bootstrap?.store.contactEmail,
          address: bootstrap?.store.address,
        ),
        branch: ReceiptBranchModel(
          name: bootstrap?.branch?.name,
          code: bootstrap?.branch?.code,
          address: [bootstrap?.branch?.addressLine1, bootstrap?.branch?.city]
              .where((e) => e != null && e.isNotEmpty)
              .join(', '),
          phone: bootstrap?.branch?.phone,
        ),
        receiptId: order.orderNumber ?? order.id?.toString(),
        receiptDate: order.orderDate ?? _dateFormat.format(DateTime.now()),
        cashier: bootstrap?.cashier.fullName,
        customer: ReceiptCustomerModel(
          name: order.fullName,
          phone: order.phone,
          email: order.email,
        ),
        items: order.items
            .map((item) => ReceiptItemModel(
                  name: item.productName ?? item.product?.name,
                  variant: item.variantName,
                  quantity: item.quantity ?? 0,
                  unitPrice: item.unitPrice,
                  lineTotal: item.totalPrice.toStringAsFixed(2),
                ))
            .toList(),
        summary: ReceiptSummaryModel(
          subtotal: order.subtotal,
          discount: order.discountAmount,
          shipping: order.shippingFee,
          tax: order.taxAmount,
          grandTotal: order.totalAmount,
          paid: order.paidAmount,
          balance: ((double.tryParse(order.totalAmount ?? '0') ?? 0) -
                  (double.tryParse(order.paidAmount ?? '0') ?? 0))
              .toStringAsFixed(2),
        ),
        notes: order.notes,
        footerNote: bootstrap?.store.siteTagline,
        printedAt: _dateFormat.format(DateTime.now()),
      );

      final printed =
          await _printerService.printReceipt(receipt, printerIp: device.ipAddress);

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
      log('PrintReceiptHelper printOrderReceiptLocally error: $e');
      customSnackBar(
        'Print Receipt',
        'Something went wrong while printing the receipt.',
        snackBarType: SnackBarType.error,
      );
      return false;
    }
  }

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
