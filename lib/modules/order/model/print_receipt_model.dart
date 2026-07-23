import 'package:modfirstpos/core/utils/json_utils.dart';

class ReceiptCompanyModel {
  final String? name;
  final String? logoUrl;
  final String? tagline;
  final String? phone;
  final String? email;
  final String? address;

  ReceiptCompanyModel({
    this.name,
    this.logoUrl,
    this.tagline,
    this.phone,
    this.email,
    this.address,
  });

  factory ReceiptCompanyModel.fromJson(Map<String, dynamic> json) {
    return ReceiptCompanyModel(
      name: JsonUtils.asStringOrNull(json['name']),
      logoUrl: JsonUtils.asStringOrNull(json['logo_url']),
      tagline: JsonUtils.asStringOrNull(json['tagline']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
      address: JsonUtils.asStringOrNull(json['address']),
    );
  }
}

class ReceiptBranchModel {
  final String? name;
  final String? code;
  final String? address;
  final String? phone;

  ReceiptBranchModel({this.name, this.code, this.address, this.phone});

  factory ReceiptBranchModel.fromJson(Map<String, dynamic> json) {
    return ReceiptBranchModel(
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
      address: JsonUtils.asStringOrNull(json['address']),
      phone: JsonUtils.asStringOrNull(json['phone']),
    );
  }
}

class ReceiptCustomerModel {
  final String? name;
  final String? phone;
  final String? email;

  ReceiptCustomerModel({this.name, this.phone, this.email});

  factory ReceiptCustomerModel.fromJson(Map<String, dynamic> json) {
    return ReceiptCustomerModel(
      name: JsonUtils.asStringOrNull(json['name']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
    );
  }
}

class ReceiptItemModel {
  final String? name;
  final String? variant;
  final int quantity;
  final String? unitPrice;
  final String? lineTotal;

  ReceiptItemModel({
    this.name,
    this.variant,
    this.quantity = 0,
    this.unitPrice,
    this.lineTotal,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      name: JsonUtils.asStringOrNull(json['name']),
      variant: JsonUtils.asStringOrNull(json['variant']),
      quantity: JsonUtils.asInt(json['quantity']),
      unitPrice: JsonUtils.asStringOrNull(json['unit_price']),
      lineTotal: JsonUtils.asStringOrNull(json['line_total']),
    );
  }
}

class ReceiptSummaryModel {
  final String? subtotal;
  final String? discount;
  final String? discountCoupon;
  final String? shipping;
  final String? tax;
  final String? grandTotal;
  final String? paid;
  final String? balance;

  ReceiptSummaryModel({
    this.subtotal,
    this.discount,
    this.discountCoupon,
    this.shipping,
    this.tax,
    this.grandTotal,
    this.paid,
    this.balance,
  });

  factory ReceiptSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReceiptSummaryModel(
      subtotal: JsonUtils.asStringOrNull(json['subtotal']),
      discount: JsonUtils.asStringOrNull(json['discount']),
      discountCoupon: JsonUtils.asStringOrNull(json['discount_coupon']),
      shipping: JsonUtils.asStringOrNull(json['shipping']),
      tax: JsonUtils.asStringOrNull(json['tax']),
      grandTotal: JsonUtils.asStringOrNull(json['grand_total']),
      paid: JsonUtils.asStringOrNull(json['paid']),
      balance: JsonUtils.asStringOrNull(json['balance']),
    );
  }
}

class ReceiptDataModel {
  final ReceiptCompanyModel company;
  final ReceiptBranchModel branch;
  final String? receiptId;
  final String? receiptDate;
  final String? cashier;
  final ReceiptCustomerModel customer;
  final List<ReceiptItemModel> items;
  final ReceiptSummaryModel summary;
  final String? deliveryInfo;
  final String? notes;
  final String? thankYou;
  final String? footerNote;
  final String? printedAt;

  ReceiptDataModel({
    required this.company,
    required this.branch,
    this.receiptId,
    this.receiptDate,
    this.cashier,
    required this.customer,
    required this.items,
    required this.summary,
    this.deliveryInfo,
    this.notes,
    this.thankYou,
    this.footerNote,
    this.printedAt,
  });

  factory ReceiptDataModel.fromJson(Map<String, dynamic> json) {
    return ReceiptDataModel(
      company: ReceiptCompanyModel.fromJson(JsonUtils.asMap(json['company'])),
      branch: ReceiptBranchModel.fromJson(JsonUtils.asMap(json['branch'])),
      receiptId: JsonUtils.asStringOrNull(json['receipt_id']),
      receiptDate: JsonUtils.asStringOrNull(json['receipt_date']),
      cashier: JsonUtils.asStringOrNull(json['cashier']),
      customer:
          ReceiptCustomerModel.fromJson(JsonUtils.asMap(json['customer'])),
      items: JsonUtils.asModelList(json['items'], ReceiptItemModel.fromJson),
      summary: ReceiptSummaryModel.fromJson(JsonUtils.asMap(json['summary'])),
      deliveryInfo: JsonUtils.asStringOrNull(json['delivery_info']),
      notes: JsonUtils.asStringOrNull(json['notes']),
      thankYou: JsonUtils.asStringOrNull(json['thank_you']),
      footerNote: JsonUtils.asStringOrNull(json['footer_note']),
      printedAt: JsonUtils.asStringOrNull(json['printed_at']),
    );
  }
}

class PrintReceiptResponse {
  final bool isSuccess;
  final String message;
  final ReceiptDataModel? payload;

  PrintReceiptResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory PrintReceiptResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return PrintReceiptResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? ReceiptDataModel.fromJson(payload) : null,
    );
  }
}
