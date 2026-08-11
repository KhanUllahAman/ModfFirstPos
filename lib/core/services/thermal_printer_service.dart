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
    } else if (data.company.name != null && data.company.name!.isNotEmpty) {
      printer.text(
        data.company.name!,
        styles: _base.copyWith(align: PosAlign.center, bold: true, width: PosTextSize.size2),
      );
    }
    if (data.company.fullAddress != null && data.company.fullAddress!.isNotEmpty) {
      printer.text(data.company.fullAddress!, styles: _base.copyWith(align: PosAlign.center));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!, styles: _base.copyWith(align: PosAlign.center));
    }
    _divider(printer);

    printer.text('SHIFT CLOSING REPORT', styles: _base.copyWith(align: PosAlign.center, bold: true));
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

    printer.text('ORDERS', styles: _base.copyWith(bold: true));
    _summaryRow(printer, 'Total', '${data.orders.total}');
    _summaryRow(printer, 'Completed', '${data.orders.completed}');
    _summaryRow(printer, 'Cancelled', '${data.orders.cancelled}');
    _divider(printer);

    printer.text('SALES', styles: _base.copyWith(bold: true));
    _summaryRow(printer, 'Gross Sales', data.sales.grossSales);
    _summaryRow(printer, 'Discounts', data.sales.discounts);
    _summaryRow(printer, 'Shipping', data.sales.shipping);
    _summaryRow(printer, 'Tax', data.sales.tax);
    _summaryRow(printer, 'Net Sales', data.sales.netSales, bold: true);
    _summaryRow(printer, 'Collected', data.sales.collected);
    _summaryRow(printer, 'Outstanding', data.sales.outstanding);
    _divider(printer);

    if (data.refunds.count > 0) {
      printer.text('REFUNDS', styles: _base.copyWith(bold: true));
      _summaryRow(printer, 'Count', '${data.refunds.count}');
      _summaryRow(printer, 'Amount', data.refunds.amount);
      _divider(printer);
    }

    printer.text('CASH RECONCILIATION', styles: _base.copyWith(bold: true));
    _summaryRow(printer, 'Opening Float', data.cashReconciliation.openingFloat);
    _summaryRow(printer, 'Cash Collected', data.cashReconciliation.cashCollected);
    _summaryRow(printer, 'Cash Refunded', data.cashReconciliation.cashRefunded);
    _summaryRow(printer, 'Expected Cash', data.cashReconciliation.expectedCash);
    _summaryRow(printer, 'Counted Cash', data.cashReconciliation.countedCash);
    _summaryRow(printer, 'Variance', data.cashReconciliation.variance, bold: true);

    if (data.shift.closingNotes != null && data.shift.closingNotes!.isNotEmpty) {
      _divider(printer);
      printer.text('Notes: ${data.shift.closingNotes}', styles: _base);
    }
    if (data.footer != null && data.footer!.isNotEmpty) {
      printer.feed(1);
      printer.text(data.footer!, styles: _base.copyWith(align: PosAlign.center));
    }
    printer.feed(1);
  }

  /// Base style every slip line uses unless overridden. Deliberately plain
  /// Font A — esc_pos_printer computes `printer.row()` column widths using
  /// Font A's character metrics, so printing Font B (condensed) text inside
  /// a row miscalculates the column split and corrupts the layout (headers
  /// merging together, numbers splitting across lines). Font A is the only
  /// font that measures correctly in both `row()` and plain `text()`.
  static const _base = PosStyles(height: PosTextSize.size1);

  void _writeReceipt(
    NetworkPrinter printer,
    ReceiptDataModel data,
    img.Image? logo,
  ) {
    if (logo != null) {
      printer.image(logo, align: PosAlign.center);
      printer.feed(0);
    } else if (data.company.name != null && data.company.name!.isNotEmpty) {
      // Only print the store name as text when there's no logo to show it —
      // avoids a redundant/mismatched name line sitting right under the logo.
      printer.text(
        data.company.name!,
        styles: _base.copyWith(align: PosAlign.center, bold: true, width: PosTextSize.size2),
      );
    }
    if (data.company.tagline != null && data.company.tagline!.isNotEmpty) {
      printer.text(data.company.tagline!, styles: _base.copyWith(align: PosAlign.center));
    }
    if (data.company.address != null && data.company.address!.isNotEmpty) {
      printer.text(data.company.address!, styles: _base.copyWith(align: PosAlign.center));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!, styles: _base.copyWith(align: PosAlign.center));
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
      _smallRow(printer, 'Customer', data.customer.name!);
    }
    if (data.customer.phone != null && data.customer.phone!.isNotEmpty) {
      _smallRow(printer, 'Phone', data.customer.phone!);
    }
    if (data.customer.name != null || data.customer.phone != null) {
      _divider(printer);
    }

    _itemLine(printer, 'ITEM', 'QTY', 'TOTAL', bold: true);
    _divider(printer);
    for (final item in data.items) {
      final label = item.variant != null && item.variant!.isNotEmpty
          ? '${item.name ?? ''} (${item.variant})'
          : (item.name ?? '');
      _itemLine(printer, label, '${item.quantity}', item.lineTotal ?? '');
      _divider(printer);
    }

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
      printer.text(data.deliveryInfo!, styles: _base.copyWith(align: PosAlign.center));
    }
    // 'POS Checkout order' is an internal placeholder the app sends when the
    // cashier leaves notes blank — not something a customer should see.
    if (data.notes != null &&
        data.notes!.isNotEmpty &&
        data.notes!.trim().toLowerCase() != 'pos checkout order') {
      printer.text('Notes: ${data.notes}', styles: _base);
    }
    printer.feed(1);
    printer.text('Thank you for your purchase!',
        styles: _base.copyWith(align: PosAlign.center, bold: true));
    printer.feed(1);
  }

  /// Characters per line for Font A on 80mm paper (576 dots / 12 dots-per-
  /// char). `printer.row()`'s own column-width math doesn't reliably match
  /// this on every printer/profile — it's what was corrupting the item
  /// table and totals (merged headers, numbers splitting mid-value). Every
  /// two-sided line below is instead built as one plain padded string and
  /// sent through a single `printer.text()` call, which always prints
  /// exactly as written.
  static const int _lineWidth = 48;

  /// Uses the printer's own `hr()` so the rule always spans the full paper
  /// width — a fixed-length dashed string falls short once the font changes.
  void _divider(NetworkPrinter printer) {
    printer.hr(ch: '-');
  }

  /// A single "Label: Value" line rather than a 2-column row — with short
  /// labels/values a wide row leaves a large empty gap in the middle.
  void _smallRow(NetworkPrinter printer, String label, String value) {
    printer.text('$label: $value', styles: _base);
  }

  /// Label flush left, amount flush right, on one manually-padded line —
  /// no `printer.row()` involved, so nothing can split across two lines.
  void _summaryRow(NetworkPrinter printer, String label, String? value,
      {bool bold = false}) {
    if (value == null) return;
    final gap = _lineWidth - label.length - value.length;
    final line = gap > 0 ? '$label${' ' * gap}$value' : '$label $value';
    printer.text(line, styles: _base.copyWith(bold: bold));
  }

  /// Item name flush left, qty and amount right-aligned in fixed columns —
  /// built as plain padded text for the same reason as [_summaryRow]. A
  /// name too long for one line wraps onto its own line, with qty/total
  /// printed on the next, still landing under their header columns.
  void _itemLine(NetworkPrinter printer, String name, String qty, String total,
      {bool bold = false}) {
    const qtyWidth = 6;
    const totalWidth = 10;
    const nameWidth = _lineWidth - qtyWidth - totalWidth;

    final qtyCell = qty.padLeft((qtyWidth + qty.length) ~/ 2).padRight(qtyWidth);
    final totalCell = total.padLeft(totalWidth);

    if (name.length <= nameWidth) {
      printer.text('${name.padRight(nameWidth)}$qtyCell$totalCell', styles: _base.copyWith(bold: bold));
    } else {
      printer.text(name, styles: _base.copyWith(bold: bold));
      printer.text('${' ' * nameWidth}$qtyCell$totalCell', styles: _base.copyWith(bold: bold));
    }
  }
}
