import 'dart:developer';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:modfirstpos/modules/order/model/print_receipt_model.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

/// Sends a formatted receipt to a network ESC/POS thermal printer
/// (tested against Epson TM-m30, 80mm paper) over the printer's IP address.
class ThermalPrinterService {
  /// Small in-memory cache so a logo already fetched once this app session
  /// isn't re-downloaded on every print — and a slow/unreachable logo URL
  /// on an offline sale only ever costs one timeout, not one per receipt.
  static final Map<String, img.Image?> _logoCache = {};

  Future<bool> printReceipt(
    ReceiptDataModel data, {
    required String printerIp,
    int port = 9100,
  }) async {
    if (printerIp.trim().isEmpty) {
      log('ThermalPrinterService: no printer IP configured');
      return false;
    }

    NetworkPrinter? printer;
    try {
      final profile = await CapabilityProfile.load();
      printer = NetworkPrinter(PaperSize.mm80, profile);
      final result = await printer.connect(printerIp.trim(), port: port);

      if (result != PosPrintResult.success) {
        log('ThermalPrinterService: connect failed ($result) to $printerIp:$port');
        return false;
      }

      final logo = await _loadLogo(data.company.logoUrl);
      _writeReceipt(printer, data, logo);
      printer.cut();
      printer.disconnect();
      return true;
    } catch (e) {
      log('ThermalPrinterService printReceipt error: $e');
      try {
        printer?.disconnect();
      } catch (_) {}
      return false;
    }
  }

  Future<bool> printShiftReceipt(
    ShiftReceiptModel data, {
    required String printerIp,
    int port = 9100,
  }) async {
    if (printerIp.trim().isEmpty) {
      log('ThermalPrinterService: no printer IP configured');
      return false;
    }

    NetworkPrinter? printer;
    try {
      final profile = await CapabilityProfile.load();
      printer = NetworkPrinter(PaperSize.mm80, profile);
      final result = await printer.connect(printerIp.trim(), port: port);

      if (result != PosPrintResult.success) {
        log('ThermalPrinterService: connect failed ($result) to $printerIp:$port');
        return false;
      }

      final logo = await _loadLogo(data.company.logoUrl);
      _writeShiftReceipt(printer, data, logo);
      printer.cut();
      printer.disconnect();
      return true;
    } catch (e) {
      log('ThermalPrinterService printShiftReceipt error: $e');
      try {
        printer?.disconnect();
      } catch (_) {}
      return false;
    }
  }

  /// Downloads and decodes the store logo for the printer's fixed 80mm
  /// (~576px) head width. Never throws — a missing/unreachable logo (very
  /// common on a genuinely offline sale) just means the receipt prints
  /// without one, capped at 2.5s so it can't stall the print queue.
  Future<img.Image?> _loadLogo(String? logoUrl) async {
    final url = logoUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (_logoCache.containsKey(url)) return _logoCache[url];

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) {
        _logoCache[url] = null;
        return null;
      }
      final decoded = img.decodeImage(response.bodyBytes);
      if (decoded == null) {
        _logoCache[url] = null;
        return null;
      }
      // Fit within a compact ~180px-wide print area — keeps the header
      // short (small/beautiful slip) instead of a full-width logo block.
      final resized = decoded.width > 180
          ? img.copyResize(decoded, width: 180)
          : decoded;
      _logoCache[url] = resized;
      return resized;
    } catch (e) {
      log('ThermalPrinterService _loadLogo error: $e');
      _logoCache[url] = null;
      return null;
    }
  }

  void _writeShiftReceipt(
    NetworkPrinter printer,
    ShiftReceiptModel data,
    img.Image? logo,
  ) {
    if (logo != null) {
      printer.image(logo, align: PosAlign.center);
      printer.feed(0);
    }
    printer.text(
      data.company.name ?? 'Shift Report',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size2,
      ),
    );
    if (data.company.fullAddress != null && data.company.fullAddress!.isNotEmpty) {
      printer.text(data.company.fullAddress!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    _divider(printer);

    printer.text('SHIFT CLOSING REPORT',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    _divider(printer);

    if (data.branch.name != null && data.branch.name!.isNotEmpty) {
      _smallRow(printer, 'Branch', data.branch.name!);
    }
    if (data.device.name != null && data.device.name!.isNotEmpty) {
      _smallRow(printer, 'Device', data.device.name!);
    }
    if (data.shift.code != null) _smallRow(printer, 'Shift', data.shift.code!);
    if (data.shift.status != null) _smallRow(printer, 'Status', data.shift.status!);
    if (data.shift.cashier != null) _smallRow(printer, 'Cashier', data.shift.cashier!);
    if (data.shift.openedAt != null) _smallRow(printer, 'Opened', data.shift.openedAt!);
    if (data.shift.closedAt != null) _smallRow(printer, 'Closed', data.shift.closedAt!);
    if (data.shift.duration != null) _smallRow(printer, 'Duration', data.shift.duration!);
    _divider(printer);

    printer.text('ORDERS', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Total', '${data.orders.total}');
    _summaryRow(printer, 'Completed', '${data.orders.completed}');
    _summaryRow(printer, 'Cancelled', '${data.orders.cancelled}');
    _divider(printer);

    printer.text('SALES', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Gross Sales', data.sales.grossSales);
    _summaryRow(printer, 'Discounts', data.sales.discounts);
    _summaryRow(printer, 'Shipping', data.sales.shipping);
    _summaryRow(printer, 'Tax', data.sales.tax);
    _summaryRow(printer, 'Net Sales', data.sales.netSales, bold: true);
    _summaryRow(printer, 'Collected', data.sales.collected);
    _summaryRow(printer, 'Outstanding', data.sales.outstanding);
    _divider(printer);

    if (data.refunds.count > 0) {
      printer.text('REFUNDS', styles: const PosStyles(bold: true));
      _summaryRow(printer, 'Count', '${data.refunds.count}');
      _summaryRow(printer, 'Amount', data.refunds.amount);
      _divider(printer);
    }

    printer.text('CASH RECONCILIATION', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Opening Float', data.cashReconciliation.openingFloat);
    _summaryRow(printer, 'Cash Collected', data.cashReconciliation.cashCollected);
    _summaryRow(printer, 'Cash Refunded', data.cashReconciliation.cashRefunded);
    _summaryRow(printer, 'Expected Cash', data.cashReconciliation.expectedCash);
    _summaryRow(printer, 'Counted Cash', data.cashReconciliation.countedCash);
    _summaryRow(printer, 'Variance', data.cashReconciliation.variance, bold: true);

    if (data.shift.closingNotes != null && data.shift.closingNotes!.isNotEmpty) {
      _divider(printer);
      printer.text('Notes: ${data.shift.closingNotes}',
          styles: const PosStyles(height: PosTextSize.size1));
    }
    if (data.footer != null && data.footer!.isNotEmpty) {
      printer.feed(1);
      printer.text(data.footer!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    printer.feed(1);
  }

  void _writeReceipt(
    NetworkPrinter printer,
    ReceiptDataModel data,
    img.Image? logo,
  ) {
    if (logo != null) {
      printer.image(logo, align: PosAlign.center);
      printer.feed(0);
    }
    printer.text(
      data.company.name ?? 'Receipt',
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size1),
    );
    if (data.company.tagline != null && data.company.tagline!.isNotEmpty) {
      printer.text(data.company.tagline!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    if (data.company.address != null && data.company.address!.isNotEmpty) {
      printer.text(data.company.address!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    _divider(printer);

    if (data.branch.name != null && data.branch.name!.isNotEmpty) {
      _smallRow(printer, 'Branch', data.branch.name!);
    }
    if (data.receiptId != null) _smallRow(printer, 'Receipt #', data.receiptId!);
    if (data.receiptDate != null) _smallRow(printer, 'Date', data.receiptDate!);
    if (data.cashier != null) _smallRow(printer, 'Cashier', data.cashier!);
    _divider(printer);

    if (data.customer.name != null && data.customer.name!.isNotEmpty) {
      printer.text(data.customer.name!,
          styles: const PosStyles(bold: true, height: PosTextSize.size1));
    }
    if (data.customer.phone != null && data.customer.phone!.isNotEmpty) {
      printer.text(data.customer.phone!,
          styles: const PosStyles(height: PosTextSize.size1));
    }
    if (data.customer.name != null || data.customer.phone != null) {
      _divider(printer);
    }

    printer.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size1)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center, height: PosTextSize.size1)),
      PosColumn(
          text: 'Total',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size1)),
    ]);
    for (final item in data.items) {
      final label = item.variant != null && item.variant!.isNotEmpty
          ? '${item.name ?? ''} (${item.variant})'
          : (item.name ?? '');
      printer.row([
        PosColumn(text: label, width: 6, styles: const PosStyles(height: PosTextSize.size1)),
        PosColumn(
            text: '${item.quantity}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1)),
        PosColumn(
            text: item.lineTotal ?? '',
            width: 4,
            styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1)),
      ]);
    }
    _divider(printer);

    _summaryRow(printer, 'Subtotal', data.summary.subtotal);
    _summaryRow(printer, 'Discount', data.summary.discount);
    _summaryRow(printer, 'Shipping', data.summary.shipping);
    _summaryRow(printer, 'Tax', data.summary.tax);
    _divider(printer);
    _summaryRow(printer, 'Grand Total', data.summary.grandTotal, bold: true);
    _summaryRow(printer, 'Paid', data.summary.paid);
    _summaryRow(printer, 'Balance', data.summary.balance, bold: true);

    if (data.deliveryInfo != null && data.deliveryInfo!.isNotEmpty) {
      _divider(printer);
      printer.text(data.deliveryInfo!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    if (data.notes != null && data.notes!.isNotEmpty) {
      printer.text('Notes: ${data.notes}',
          styles: const PosStyles(height: PosTextSize.size1));
    }
    printer.feed(1);
    printer.text('Thank you for your purchase!',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size1));
    if (data.footerNote != null && data.footerNote!.isNotEmpty) {
      printer.text(data.footerNote!,
          styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
    }
    printer.feed(1);
  }

  /// A tighter, dashed divider instead of `printer.hr()`'s full solid
  /// line — reads lighter on a compact slip.
  void _divider(NetworkPrinter printer) {
    printer.text('- - - - - - - - - - - - - - - - - - - -',
        styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1));
  }

  void _smallRow(NetworkPrinter printer, String label, String value) {
    printer.row([
      PosColumn(
          text: label,
          width: 4,
          styles: const PosStyles(height: PosTextSize.size1, align: PosAlign.left)),
      PosColumn(
          text: value,
          width: 8,
          styles: const PosStyles(height: PosTextSize.size1, align: PosAlign.right)),
    ]);
  }

  void _summaryRow(NetworkPrinter printer, String label, String? value,
      {bool bold = false}) {
    if (value == null) return;
    printer.row([
      PosColumn(
          text: label,
          width: 8,
          styles: PosStyles(bold: bold, height: PosTextSize.size1)),
      PosColumn(
          text: value,
          width: 4,
          styles: PosStyles(bold: bold, align: PosAlign.right, height: PosTextSize.size1)),
    ]);
  }
}
