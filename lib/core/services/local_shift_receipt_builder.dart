import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

/// Builds a [ShiftReceiptModel] entirely from local data (bootstrap snapshot
/// + this device's own `pending_orders` rows for the shift) — no server
/// call, so the shift-closing receipt can print even before/without ever
/// syncing.
class LocalShiftReceiptBuilder {
  LocalShiftReceiptBuilder._();

  static final _dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mm a");

  static ShiftReceiptModel build({
    required BootstrapPayload bootstrap,
    required ShiftModel shift,
    PosDeviceModel? device,
    required List<Map<String, dynamic>> orders,
  }) {
    double subtotal = 0, discount = 0, tax = 0, netSales = 0, collected = 0, outstanding = 0;

    for (final row in orders) {
      try {
        final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
        final local = JsonUtils.asMap(data['local']);
        final sync = JsonUtils.asMap(data['sync']);
        final grandTotal = JsonUtils.asDouble(local['grand_total']);

        subtotal += JsonUtils.asDouble(local['subtotal']);
        discount += JsonUtils.asDouble(local['discount']);
        tax += JsonUtils.asDouble(local['tax']);
        netSales += grandTotal;
        if (sync['payment_method'] == 'without_payment') {
          outstanding += grandTotal;
        } else {
          collected += grandTotal;
        }
      } catch (_) {
        // Skip a malformed row rather than fail the whole receipt.
      }
    }

    final openingFloat = shift.openingFloat;
    final countedCash = shift.countedCash;
    final expectedCash = shift.expectedCash ?? openingFloat;
    final variance = shift.variance;

    return ShiftReceiptModel(
      company: ShiftReceiptCompanyModel(
        name: bootstrap.store.siteName,
        tagline: bootstrap.store.siteTagline,
        logoUrl: bootstrap.store.logoBlackUrl ?? bootstrap.store.logoUrl,
        phone: bootstrap.store.contactPhone,
        email: bootstrap.store.contactEmail,
        fullAddress: bootstrap.store.address,
        currencySymbol: bootstrap.store.currencySymbol,
      ),
      branch: ShiftReceiptBranchModel(
        name: bootstrap.branch?.name,
        code: bootstrap.branch?.code,
        fullAddress: [bootstrap.branch?.addressLine1, bootstrap.branch?.city]
            .where((e) => e != null && e.isNotEmpty)
            .join(', '),
        phone: bootstrap.branch?.phone,
      ),
      device: ShiftReceiptDeviceModel(
        name: device?.name,
        code: device?.deviceCode,
      ),
      shift: ShiftReceiptShiftInfoModel(
        code: shift.shiftCode,
        status: shift.statusLabel ?? shift.status,
        cashier: bootstrap.cashier.fullName,
        cashierEmail: bootstrap.cashier.email,
        openedAt: shift.openedAt,
        closedAt: shift.closedAt,
        openingNotes: shift.openingNotes,
        closingNotes: shift.closingNotes,
      ),
      orders: ShiftOrdersModel(
        total: orders.length,
        completed: orders.length,
        cancelled: 0,
      ),
      sales: ShiftSalesModel(
        grossSales: subtotal.toStringAsFixed(2),
        discounts: discount.toStringAsFixed(2),
        shipping: '0.00',
        tax: tax.toStringAsFixed(2),
        netSales: netSales.toStringAsFixed(2),
        collected: collected.toStringAsFixed(2),
        outstanding: outstanding.toStringAsFixed(2),
      ),
      refunds: ShiftRefundsModel(count: 0, amount: '0.00'),
      cashReconciliation: ShiftReconciliationModel(
        openingFloat: openingFloat.toStringAsFixed(2),
        cashCollected: collected.toStringAsFixed(2),
        cashRefunded: '0.00',
        expectedCash: expectedCash.toStringAsFixed(2),
        countedCash: countedCash?.toStringAsFixed(2),
        variance: variance?.toStringAsFixed(2),
      ),
      currency: bootstrap.store.currencySymbol,
      printedAt: _dateFormat.format(DateTime.now()),
      footer: bootstrap.store.siteTagline,
    );
  }
}
