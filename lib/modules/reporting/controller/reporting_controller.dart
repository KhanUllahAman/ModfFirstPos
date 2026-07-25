import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/reporting/service/reporting_service.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class ReportingController extends GetxController {
  final ReportingService _service = ReportingService();

  final ScrollController horizontalTableScrollController = ScrollController();
  final ScrollController verticalTableScrollController = ScrollController();

  @override
  void onClose() {
    horizontalTableScrollController.dispose();
    verticalTableScrollController.dispose();
    super.onClose();
  }

  final List<Map<String, String>> periodOptions = const [
    {'value': 'today', 'label': 'Today'},
    {'value': 'yesterday', 'label': 'Yesterday'},
    {'value': 'last_7_days', 'label': 'Last 7 Days'},
    {'value': 'last_30_days', 'label': 'Last 30 Days'},
    {'value': 'this_month', 'label': 'This Month'},
    {'value': 'last_month', 'label': 'Last Month'},
    {'value': 'this_year', 'label': 'This Year'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  final List<Map<String, String>> sortByOptions = const [
    {'value': 'order_date', 'label': 'Order Date'},
    {'value': 'total_amount', 'label': 'Total Amount'},
    {'value': 'paid_amount', 'label': 'Paid Amount'},
    {'value': 'discount_amount', 'label': 'Discount Amount'},
    {'value': 'tax_amount', 'label': 'Tax Amount'},
    {'value': 'order_number', 'label': 'Order Number'},
  ];

  final RxString selectedPeriod = 'this_month'.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxString sortBy = 'order_date'.obs;
  final RxString sortOrder = 'desc'.obs;

  final RxBool isGenerating = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasReport = false.obs;

  Uint8List? _excelBytes;

  final RxList<String> sheetNames = <String>[].obs;
  final RxString activeSheet = ''.obs;
  final RxList<String> previewHeaders = <String>[].obs;
  final RxList<List<String>> previewRows = <List<String>>[].obs;

  bool get isCustomPeriod => selectedPeriod.value == 'custom';

  void selectPeriod(String value) {
    selectedPeriod.value = value;
  }

  void selectSortBy(String value) => sortBy.value = value;

  void selectSortOrder(String value) => sortOrder.value = value;

  void setStartDate(DateTime date) => startDate.value = date;

  void setEndDate(DateTime date) => endDate.value = date;

  void selectSheet(String name) {
    activeSheet.value = name;
    _renderSheet(name);
  }

  Future<void> generateReport() async {
    if (isCustomPeriod && (startDate.value == null || endDate.value == null)) {
      customSnackBar(
        'Missing Dates',
        'Please select both start and end date for a custom range',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    isGenerating.value = true;
    try {
      final bytes = await _service.fetchDurationReportExcel(
        period: selectedPeriod.value,
        startDate: isCustomPeriod ? _formatDate(startDate.value) : null,
        endDate: isCustomPeriod ? _formatDate(endDate.value) : null,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );

      if (bytes.isEmpty) {
        customSnackBar(
          'No Data',
          'The report came back empty',
          snackBarType: SnackBarType.error,
        );
        return;
      }

      _excelBytes = Uint8List.fromList(bytes);
      _parseExcel(_excelBytes!);
      hasReport.value = true;
    } catch (e) {
      log("ReportingController generateReport error: $e");
      customSnackBar(
        'Error',
        'Failed to generate report',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  void _parseExcel(Uint8List bytes) {
    try {
      final workbook = xls.Excel.decodeBytes(bytes);
      sheetNames.assignAll(workbook.tables.keys);
      if (sheetNames.isNotEmpty) {
        activeSheet.value = sheetNames.first;
        _renderSheetFromWorkbook(workbook, sheetNames.first);
      }
    } catch (e) {
      log("ReportingController _parseExcel error: $e");
      previewHeaders.clear();
      previewRows.clear();
    }
  }

  void _renderSheet(String name) {
    if (_excelBytes == null) return;
    final workbook = xls.Excel.decodeBytes(_excelBytes!);
    _renderSheetFromWorkbook(workbook, name);
  }

  void _renderSheetFromWorkbook(xls.Excel workbook, String sheetName) {
    final sheet = workbook.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      previewHeaders.clear();
      previewRows.clear();
      return;
    }

    final rows = sheet.rows
        .map((row) => row.map((cell) => cell?.value?.toString() ?? '').toList())
        .toList();

    previewHeaders.assignAll(rows.first);
    previewRows.assignAll(rows.skip(1).take(200).toList());
  }

  Future<void> downloadReport() async {
    final bytes = _excelBytes;
    if (bytes == null) return;

    isSaving.value = true;
    try {
      final fileName =
          'duration_report_${selectedPeriod.value}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Duration Report',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: bytes,
      );

      if (savedPath == null) return;

      // On some desktop platforms saveFile() only returns the chosen path
      // without writing the bytes, so write explicitly to be safe.
      final file = File(savedPath);
      if (!await file.exists() || await file.length() != bytes.length) {
        await file.writeAsBytes(bytes, flush: true);
      }

      customSnackBar(
        'Saved',
        'Report saved successfully',
        snackBarType: SnackBarType.success,
      );
    } catch (e) {
      log("ReportingController downloadReport error: $e");
      customSnackBar(
        'Error',
        'Failed to save report',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
