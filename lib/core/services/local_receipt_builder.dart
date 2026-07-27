import 'package:intl/intl.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/order/model/print_receipt_model.dart';

/// Builds a [ReceiptDataModel] entirely from local data (cart + bootstrap
/// snapshot) — used for offline cash/bank_transfer/without_payment sales
/// where there's no server order id yet to fetch a receipt for.
class LocalReceiptBuilder {
  LocalReceiptBuilder._();

  static final _dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mm a");

  static ReceiptDataModel build({
    required BootstrapPayload bootstrap,
    required List<CartItemModel> cartItems,
    required String receiptId,
    CustomerModel? customer,
    required double subtotal,
    required double discount,
    required double tax,
    required double grandTotal,
    String? deliveryInfo,
    String? notes,
  }) {
    final now = DateTime.now();
    final formattedNow = _dateFormat.format(now);

    return ReceiptDataModel(
      company: ReceiptCompanyModel(
        name: bootstrap.store.siteName,
        logoUrl: bootstrap.store.logoUrl,
        tagline: bootstrap.store.siteTagline,
        phone: bootstrap.store.contactPhone,
        email: bootstrap.store.contactEmail,
        address: bootstrap.store.address,
      ),
      branch: ReceiptBranchModel(
        name: bootstrap.branch?.name,
        code: bootstrap.branch?.code,
        address: [bootstrap.branch?.addressLine1, bootstrap.branch?.city]
            .where((e) => e != null && e.isNotEmpty)
            .join(', '),
        phone: bootstrap.branch?.phone,
      ),
      receiptId: receiptId,
      receiptDate: formattedNow,
      cashier: bootstrap.cashier.fullName,
      customer: ReceiptCustomerModel(
        name: customer?.fullName ?? bootstrap.walkInCustomer?.fullName,
        phone: customer?.phone ?? bootstrap.walkInCustomer?.phone,
        email: customer?.email ?? bootstrap.walkInCustomer?.email,
      ),
      items: cartItems
          .map((item) => ReceiptItemModel(
                name: item.product.name,
                variant: null,
                quantity: item.quantity,
                unitPrice: item.product.unitPrice.toStringAsFixed(2),
                lineTotal: item.total.toStringAsFixed(2),
              ))
          .toList(),
      summary: ReceiptSummaryModel(
        subtotal: subtotal.toStringAsFixed(2),
        discount: discount.toStringAsFixed(2),
        tax: tax.toStringAsFixed(2),
        grandTotal: grandTotal.toStringAsFixed(2),
        paid: grandTotal.toStringAsFixed(2),
        balance: '0.00',
      ),
      deliveryInfo: deliveryInfo,
      notes: notes,
      footerNote: bootstrap.store.siteTagline,
      printedAt: now.toIso8601String(),
    );
  }
}
