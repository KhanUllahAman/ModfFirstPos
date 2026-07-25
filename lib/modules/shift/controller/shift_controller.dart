import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';
import 'package:modfirstpos/modules/shift/service/shift_service.dart';
import 'package:modfirstpos/modules/shift/storage/shift_cache_storage.dart';
import 'package:modfirstpos/modules/shift/widgets/open_shift_dialog.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class ShiftController extends GetxController {
  final ShiftService _service = ShiftService();
  final ThermalPrinterService _printerService = ThermalPrinterService();

  final Rxn<ShiftModel> currentShift = Rxn<ShiftModel>();

  final RxBool isLoading = false.obs;
  final RxBool isOpeningShift = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxBool isClosingShift = false.obs;
  final RxBool isPrinting = false.obs;

  bool _openPromptShown = false;
  bool _startupCheckDone = false;

  Future<void> ensureShiftCheckedOnStartup(BuildContext context) async {
    if (_startupCheckDone) return;
    _startupCheckDone = true;
    await checkCurrentShift();
    if (context.mounted) maybeShowOpenShiftPrompt(context);
  }

  /// Resets the one-shot startup flags so the "open shift" prompt can fire
  /// again on the next login — the controller instance (fenix: true)
  /// otherwise survives logout and skips the check forever.
  void resetForLogout() {
    _startupCheckDone = false;
    _openPromptShown = false;
    currentShift.value = null;
  }

  Future<void> checkCurrentShift() async {
    try {
      isLoading.value = true;
      final response = await _service.getCurrentShift();
      if (response.isSuccess && response.payload != null) {
        currentShift.value = response.payload;
        await ShiftCacheStorage.saveShift(response.payload!);
      } else {
        currentShift.value = null;
      }
    } catch (e) {
      log("ShiftController checkCurrentShift error: $e");
      currentShift.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  
  void maybeShowOpenShiftPrompt(BuildContext context) {
    if (_openPromptShown || currentShift.value != null) return;
    _openPromptShown = true;
    OpenShiftDialog.show(context);
  }

  Future<bool> openShift({
    required double openingFloat,
    String? openingNotes,
  }) async {
    try {
      isOpeningShift.value = true;
      final response = await _service.openShift(
        openingFloat: openingFloat,
        openingNotes: openingNotes,
      );

      if (response.isSuccess && response.payload != null) {
        currentShift.value = response.payload;
        await ShiftCacheStorage.saveShift(response.payload!);
        customSnackBar(
          'Shift Opened',
          response.message.isNotEmpty
              ? response.message
              : 'Shift opened successfully.',
          snackBarType: SnackBarType.success,
        );
        return true;
      }

      customSnackBar(
        'Could Not Open Shift',
        response.message.isNotEmpty
            ? response.message
            : 'Something went wrong.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } catch (e) {
      log("ShiftController openShift error: $e");
      customSnackBar(
        'Could Not Open Shift',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } finally {
      isOpeningShift.value = false;
    }
  }

  Future<void> pauseShift() => _updateStatus('paused');

  Future<void> resumeShift() => _updateStatus('open');

  Future<void> _updateStatus(String status) async {
    final shift = currentShift.value;
    if (shift == null) return;
    try {
      isUpdatingStatus.value = true;
      final response = await _service.updateStatus(
        shiftId: shift.id,
        status: status,
      );

      if (response.isSuccess) {
        // The status-update response doesn't include totals/branch/device —
        // reload the full current-shift snapshot instead of using it as-is.
        await checkCurrentShift();
        customSnackBar(
          'Shift Updated',
          response.message.isNotEmpty
              ? response.message
              : 'Shift status updated.',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Could Not Update Shift',
          response.message.isNotEmpty
              ? response.message
              : 'Something went wrong.',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("ShiftController _updateStatus error: $e");
      customSnackBar(
        'Could Not Update Shift',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<bool> closeShift({
    required double countedCash,
    String? closingNotes,
  }) async {
    final shift = currentShift.value;
    if (shift == null) return false;
    try {
      isClosingShift.value = true;
      final response = await _service.closeShift(
        shiftId: shift.id,
        countedCash: countedCash,
        closingNotes: closingNotes,
      );

      if (response.isSuccess && response.payload != null) {
        final closedShiftId = response.payload!.id;
        final varianceStatus =
            response.payload!.reconciliation?.varianceStatus;
        await ShiftCacheStorage.clearShift();
        // Reflect "No Active Shift" immediately — no manual refresh needed.
        currentShift.value = null;
        customSnackBar(
          'Shift Closed',
          varianceStatus != null
              ? 'Shift closed — cash $varianceStatus.'
              : 'Shift closed successfully.',
          snackBarType: SnackBarType.success,
        );
        unawaited(_printReceiptForShiftId(closedShiftId));
        return true;
      }

      customSnackBar(
        'Could Not Close Shift',
        response.message.isNotEmpty
            ? response.message
            : 'Something went wrong.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } catch (e) {
      log("ShiftController closeShift error: $e");
      customSnackBar(
        'Could Not Close Shift',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } finally {
      isClosingShift.value = false;
    }
  }

  Future<void> printReceipt() async {
    final shift = currentShift.value;
    if (shift == null) return;
    await _printReceiptForShiftId(shift.id);
  }

  Future<void> _printReceiptForShiftId(int shiftId) async {
    try {
      isPrinting.value = true;

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
        return;
      }

      final receiptResponse = await _service.printReceiptData(
        shiftId: shiftId,
        printType: device.receiptType.isNotEmpty
            ? device.receiptType
            : 'thermal_80mm',
      );

      if (!receiptResponse.isSuccess || receiptResponse.payload == null) {
        customSnackBar(
          'Print Receipt',
          receiptResponse.message.isNotEmpty
              ? receiptResponse.message
              : 'Could not fetch shift receipt data.',
          snackBarType: SnackBarType.error,
        );
        return;
      }

      final printed = await _printerService.printShiftReceipt(
        receiptResponse.payload!,
        printerIp: device.ipAddress,
      );

      if (printed) {
        customSnackBar(
          'Print Receipt',
          'Shift receipt sent to printer.',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Print Receipt',
          'Could not reach the printer at ${device.ipAddress}.',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("ShiftController printReceipt error: $e");
      customSnackBar(
        'Print Receipt',
        'Something went wrong while printing the receipt.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isPrinting.value = false;
    }
  }
}
