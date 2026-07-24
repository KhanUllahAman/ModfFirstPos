import 'dart:developer';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:modfirstpos/modules/order/model/print_receipt_model.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

/// Sends a formatted receipt to a network ESC/POS thermal printer
/// (tested against Epson TM-m30, 80mm paper) over the printer's IP address.
class ThermalPrinterService {
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

      _writeReceipt(printer, data);
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

      _writeShiftReceipt(printer, data);
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

  void _writeShiftReceipt(NetworkPrinter printer, ShiftReceiptModel data) {
    printer.text(
      data.company.name ?? 'Shift Report',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    if (data.company.tagline != null && data.company.tagline!.isNotEmpty) {
      printer.text(data.company.tagline!,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (data.company.fullAddress != null && data.company.fullAddress!.isNotEmpty) {
      printer.text(data.company.fullAddress!,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!,
          styles: const PosStyles(align: PosAlign.center));
    }
    printer.hr();

    printer.text('SHIFT CLOSING REPORT',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    printer.hr();

    if (data.branch.name != null && data.branch.name!.isNotEmpty) {
      printer.text('Branch: ${data.branch.name}');
    }
    if (data.device.name != null && data.device.name!.isNotEmpty) {
      printer.text('Device: ${data.device.name}');
    }
    if (data.shift.code != null) printer.text('Shift: ${data.shift.code}');
    if (data.shift.status != null) printer.text('Status: ${data.shift.status}');
    if (data.shift.cashier != null) printer.text('Cashier: ${data.shift.cashier}');
    if (data.shift.openedAt != null) printer.text('Opened: ${data.shift.openedAt}');
    if (data.shift.closedAt != null) printer.text('Closed: ${data.shift.closedAt}');
    if (data.shift.duration != null) printer.text('Duration: ${data.shift.duration}');
    printer.hr();

    printer.text('Orders', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Total', '${data.orders.total}');
    _summaryRow(printer, 'Completed', '${data.orders.completed}');
    _summaryRow(printer, 'Cancelled', '${data.orders.cancelled}');
    printer.hr();

    printer.text('Sales', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Gross Sales', data.sales.grossSales);
    _summaryRow(printer, 'Discounts', data.sales.discounts);
    _summaryRow(printer, 'Shipping', data.sales.shipping);
    _summaryRow(printer, 'Tax', data.sales.tax);
    _summaryRow(printer, 'Net Sales', data.sales.netSales, bold: true);
    _summaryRow(printer, 'Collected', data.sales.collected);
    _summaryRow(printer, 'Outstanding', data.sales.outstanding);
    printer.hr();

    if (data.refunds.count > 0) {
      printer.text('Refunds', styles: const PosStyles(bold: true));
      _summaryRow(printer, 'Count', '${data.refunds.count}');
      _summaryRow(printer, 'Amount', data.refunds.amount);
      printer.hr();
    }

    printer.text('Cash Reconciliation', styles: const PosStyles(bold: true));
    _summaryRow(printer, 'Opening Float', data.cashReconciliation.openingFloat);
    _summaryRow(printer, 'Cash Collected', data.cashReconciliation.cashCollected);
    _summaryRow(printer, 'Cash Refunded', data.cashReconciliation.cashRefunded);
    _summaryRow(printer, 'Expected Cash', data.cashReconciliation.expectedCash);
    _summaryRow(printer, 'Counted Cash', data.cashReconciliation.countedCash);
    _summaryRow(printer, 'Variance', data.cashReconciliation.variance, bold: true);
    printer.hr();

    if (data.shift.closingNotes != null && data.shift.closingNotes!.isNotEmpty) {
      printer.text('Notes: ${data.shift.closingNotes}');
    }
    if (data.footer != null && data.footer!.isNotEmpty) {
      printer.text(data.footer!, styles: const PosStyles(align: PosAlign.center));
    }
    printer.feed(2);
  }

  void _writeReceipt(NetworkPrinter printer, ReceiptDataModel data) {
    printer.text(
      data.company.name ?? 'Receipt',
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    if (data.company.tagline != null && data.company.tagline!.isNotEmpty) {
      printer.text(data.company.tagline!,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (data.company.address != null && data.company.address!.isNotEmpty) {
      printer.text(data.company.address!,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (data.company.phone != null && data.company.phone!.isNotEmpty) {
      printer.text(data.company.phone!,
          styles: const PosStyles(align: PosAlign.center));
    }
    printer.hr();

    if (data.branch.name != null && data.branch.name!.isNotEmpty) {
      printer.text('Branch: ${data.branch.name}');
    }
    if (data.receiptId != null) printer.text('Receipt #: ${data.receiptId}');
    if (data.receiptDate != null) printer.text('Date: ${data.receiptDate}');
    if (data.cashier != null) printer.text('Cashier: ${data.cashier}');
    printer.hr();

    if (data.customer.name != null && data.customer.name!.isNotEmpty) {
      printer.text('Customer: ${data.customer.name}',
          styles: const PosStyles(bold: true));
    }
    if (data.customer.phone != null && data.customer.phone!.isNotEmpty) {
      printer.text('Phone: ${data.customer.phone}');
    }
    printer.hr();

    printer.row([
      PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center)),
      PosColumn(
          text: 'Total',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right)),
    ]);
    for (final item in data.items) {
      final label = item.variant != null && item.variant!.isNotEmpty
          ? '${item.name ?? ''} (${item.variant})'
          : (item.name ?? '');
      printer.row([
        PosColumn(text: label, width: 6),
        PosColumn(
            text: '${item.quantity}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: item.lineTotal ?? '',
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }
    printer.hr();

    _summaryRow(printer, 'Subtotal', data.summary.subtotal);
    _summaryRow(printer, 'Discount', data.summary.discount);
    _summaryRow(printer, 'Shipping', data.summary.shipping);
    _summaryRow(printer, 'Tax', data.summary.tax);
    printer.hr();
    _summaryRow(printer, 'Grand Total', data.summary.grandTotal, bold: true);
    _summaryRow(printer, 'Paid', data.summary.paid);
    _summaryRow(printer, 'Balance', data.summary.balance, bold: true);
    printer.hr();

    if (data.deliveryInfo != null && data.deliveryInfo!.isNotEmpty) {
      printer.text(data.deliveryInfo!, styles: const PosStyles(align: PosAlign.center));
    }
    if (data.notes != null && data.notes!.isNotEmpty) {
      printer.text('Notes: ${data.notes}');
    }
    if (data.footerNote != null && data.footerNote!.isNotEmpty) {
      printer.text(data.footerNote!,
          styles: const PosStyles(align: PosAlign.center));
    }
    printer.feed(2);
  }

  void _summaryRow(NetworkPrinter printer, String label, String? value,
      {bool bold = false}) {
    if (value == null) return;
    printer.row([
      PosColumn(
          text: label, width: 8, styles: PosStyles(bold: bold)),
      PosColumn(
          text: value,
          width: 4,
          styles: PosStyles(bold: bold, align: PosAlign.right)),
    ]);
  }
}
