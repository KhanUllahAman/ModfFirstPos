import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/local_shift_receipt_builder.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/order/repository/pending_order_repository.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';
import 'package:modfirstpos/modules/shift/repository/shift_local_repository.dart';
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

  /// Offline-first: the local `pending_shifts` row is the source of truth
  /// for "is there a shift open right now". Only when there's genuinely no
  /// local record do we fall back to the last-synced bootstrap snapshot
  /// (no extra network call — bootstrap is already cached).
  Future<void> checkCurrentShift() async {
    try {
      isLoading.value = true;
      final localRow = await ShiftLocalRepository.getCurrentOpenRow();
      if (localRow != null) {
        currentShift.value = ShiftLocalRepository.rowToShiftModel(localRow);
        return;
      }

      final bootstrapShift = Get.isRegistered<BootstrapController>()
          ? Get.find<BootstrapController>().data.value?.openShift
          : null;
      currentShift.value =
          (bootstrapShift != null && bootstrapShift.isOpen) ? bootstrapShift : null;
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

  /// Opens a shift entirely offline — saved to the local queue and synced
  /// automatically (or via Menu > Sync Shifts) once online.
  Future<bool> openShift({
    required double openingFloat,
    String? openingNotes,
  }) async {
    try {
      isOpeningShift.value = true;
      final row = await ShiftLocalRepository.addOpen(
        openingFloat: openingFloat,
        openingNotes: openingNotes,
      );
      currentShift.value = ShiftLocalRepository.rowToShiftModel(row);
      await ShiftCacheStorage.saveShift(currentShift.value!);

      customSnackBar(
        'Shift Opened',
        'Shift opened. It will sync automatically once online.',
        snackBarType: SnackBarType.success,
      );

      if (Get.isRegistered<SyncService>()) {
        final sync = Get.find<SyncService>();
        await sync.refreshPendingCount();
        unawaited(sync.syncShiftsNow());
      }
      return true;
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

  /// Pause/resume has no offline equivalent from the backend — only
  /// available once the shift has synced (real, positive id). The Shift
  /// view hides these buttons for local-only (id < 0) shifts.
  Future<void> pauseShift() => _updateStatus('paused');

  Future<void> resumeShift() => _updateStatus('open');

  Future<void> _updateStatus(String status) async {
    final shift = currentShift.value;
    if (shift == null || shift.id <= 0) return;
    try {
      isUpdatingStatus.value = true;
      final response = await _service.updateStatus(
        shiftId: shift.id,
        status: status,
      );

      if (response.isSuccess) {
        final row = await ShiftLocalRepository.ensureLocalRow(shift);
        await ShiftLocalRepository.updateLiveStatus(
          JsonUtils.asInt(row['local_id']),
          status,
        );
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

  /// Closes the current shift entirely offline — expected cash/variance are
  /// computed on-device from the cash orders taken during this shift, then
  /// queued for sync just like the open.
  Future<bool> closeShift({
    required double countedCash,
    String? closingNotes,
  }) async {
    final shift = currentShift.value;
    if (shift == null) return false;
    try {
      isClosingShift.value = true;
      final row = await ShiftLocalRepository.getCurrentOpenRow() ??
          await ShiftLocalRepository.ensureLocalRow(shift);

      final localId = JsonUtils.asInt(row['local_id']);
      final clientReference = row['client_reference'] as String;
      final cashCollected =
          await ShiftLocalRepository.cashCollectedForShift(clientReference);
      final expectedCash = shift.openingFloat + cashCollected;
      final variance = countedCash - expectedCash;

      await ShiftLocalRepository.closeLocal(
        localId: localId,
        countedCash: countedCash,
        expectedCash: expectedCash,
        variance: variance,
        closingNotes: closingNotes,
      );

      await ShiftCacheStorage.clearShift();
      // Reflect "No Active Shift" immediately — no manual refresh needed.
      currentShift.value = null;

      final varianceLabel = variance == 0
          ? 'balanced'
          : (variance > 0 ? 'over by ${variance.toStringAsFixed(2)}' : 'short by ${(-variance).toStringAsFixed(2)}');
      customSnackBar(
        'Shift Closed',
        'Shift closed — cash $varianceLabel. It will sync automatically once online.',
        snackBarType: SnackBarType.success,
      );

      if (Get.isRegistered<SyncService>()) {
        final sync = Get.find<SyncService>();
        await sync.refreshPendingCount();
        unawaited(sync.syncShiftsNow());
      }
      return true;
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

  /// Builds the shift-closing receipt entirely from local data (bootstrap
  /// snapshot + this device's own offline orders for the shift) and prints
  /// it directly — no server call, no dependency on the shift having synced.
  Future<void> printReceipt() async {
    final shift = currentShift.value;
    if (shift == null) return;
    await _printReceiptLocally(shift);
  }

  Future<void> _printReceiptLocally(ShiftModel shift) async {
    try {
      isPrinting.value = true;

      final bootstrap = Get.isRegistered<BootstrapController>()
          ? Get.find<BootstrapController>().data.value
          : null;
      if (bootstrap == null) {
        customSnackBar(
          'Print Receipt',
          'Store data not loaded yet. Please sync first.',
          snackBarType: SnackBarType.warning,
        );
        return;
      }

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

      final row = await ShiftLocalRepository.getCurrentOpenRow() ??
          await ShiftLocalRepository.ensureLocalRow(shift);
      final clientReference = row['client_reference'] as String;
      final orders =
          await PendingOrderRepository.getByShiftReference(clientReference);

      final receipt = LocalShiftReceiptBuilder.build(
        bootstrap: bootstrap,
        shift: shift,
        device: device,
        orders: orders,
      );

      final printed = await _printerService.printShiftReceipt(
        receipt,
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
