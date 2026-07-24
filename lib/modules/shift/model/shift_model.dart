import 'package:modfirstpos/core/utils/json_utils.dart';

class ShiftBranchModel {
  final int? id;
  final String? name;
  final String? code;

  ShiftBranchModel({this.id, this.name, this.code});

  factory ShiftBranchModel.fromJson(Map<String, dynamic> json) {
    return ShiftBranchModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
    );
  }
}

class ShiftPosDeviceModel {
  final int? id;
  final String? name;
  final String? deviceCode;

  ShiftPosDeviceModel({this.id, this.name, this.deviceCode});

  factory ShiftPosDeviceModel.fromJson(Map<String, dynamic> json) {
    return ShiftPosDeviceModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      deviceCode: JsonUtils.asStringOrNull(json['device_code']),
    );
  }
}

class ShiftWebsiteSettingModel {
  final int? id;
  final String? siteName;
  final String? currencySymbol;

  ShiftWebsiteSettingModel({this.id, this.siteName, this.currencySymbol});

  factory ShiftWebsiteSettingModel.fromJson(Map<String, dynamic> json) {
    return ShiftWebsiteSettingModel(
      id: JsonUtils.asIntOrNull(json['id']),
      siteName: JsonUtils.asStringOrNull(json['site_name']),
      currencySymbol: JsonUtils.asStringOrNull(json['currency_symbol']),
    );
  }
}

class ShiftOrdersModel {
  final int total;
  final int completed;
  final int cancelled;

  ShiftOrdersModel({this.total = 0, this.completed = 0, this.cancelled = 0});

  factory ShiftOrdersModel.fromJson(Map<String, dynamic> json) {
    return ShiftOrdersModel(
      total: JsonUtils.asInt(json['total']),
      completed: JsonUtils.asInt(json['completed']),
      cancelled: JsonUtils.asInt(json['cancelled']),
    );
  }
}

class ShiftSalesModel {
  final String? grossSales;
  final String? discounts;
  final String? shipping;
  final String? tax;
  final String? netSales;
  final String? collected;
  final String? outstanding;

  ShiftSalesModel({
    this.grossSales,
    this.discounts,
    this.shipping,
    this.tax,
    this.netSales,
    this.collected,
    this.outstanding,
  });

  factory ShiftSalesModel.fromJson(Map<String, dynamic> json) {
    return ShiftSalesModel(
      grossSales: JsonUtils.asStringOrNull(json['gross_sales']),
      discounts: JsonUtils.asStringOrNull(json['discounts']),
      shipping: JsonUtils.asStringOrNull(json['shipping']),
      tax: JsonUtils.asStringOrNull(json['tax']),
      netSales: JsonUtils.asStringOrNull(json['net_sales']),
      collected: JsonUtils.asStringOrNull(json['collected']),
      outstanding: JsonUtils.asStringOrNull(json['outstanding']),
    );
  }
}

class ShiftRefundsModel {
  final int count;
  final String? amount;

  ShiftRefundsModel({this.count = 0, this.amount});

  factory ShiftRefundsModel.fromJson(Map<String, dynamic> json) {
    return ShiftRefundsModel(
      count: JsonUtils.asInt(json['count']),
      amount: JsonUtils.asStringOrNull(json['amount']),
    );
  }
}

class ShiftTotalsModel {
  final ShiftOrdersModel orders;
  final ShiftSalesModel sales;
  final ShiftRefundsModel refunds;
  final List<dynamic> paymentMethods;
  final String? cashCollected;

  ShiftTotalsModel({
    required this.orders,
    required this.sales,
    required this.refunds,
    this.paymentMethods = const [],
    this.cashCollected,
  });

  factory ShiftTotalsModel.fromJson(Map<String, dynamic> json) {
    return ShiftTotalsModel(
      orders: ShiftOrdersModel.fromJson(JsonUtils.asMap(json['orders'])),
      sales: ShiftSalesModel.fromJson(JsonUtils.asMap(json['sales'])),
      refunds: ShiftRefundsModel.fromJson(JsonUtils.asMap(json['refunds'])),
      paymentMethods: json['payment_methods'] is List
          ? json['payment_methods'] as List<dynamic>
          : const [],
      cashCollected: JsonUtils.asStringOrNull(json['cash_collected']),
    );
  }
}

class ShiftReconciliationModel {
  final String? openingFloat;
  final String? cashCollected;
  final String? cashRefunded;
  final String? expectedCash;
  final String? countedCash;
  final String? variance;
  final String? varianceStatus;

  ShiftReconciliationModel({
    this.openingFloat,
    this.cashCollected,
    this.cashRefunded,
    this.expectedCash,
    this.countedCash,
    this.variance,
    this.varianceStatus,
  });

  factory ShiftReconciliationModel.fromJson(Map<String, dynamic> json) {
    return ShiftReconciliationModel(
      openingFloat: JsonUtils.asStringOrNull(json['opening_float']),
      cashCollected: JsonUtils.asStringOrNull(json['cash_collected']),
      cashRefunded: JsonUtils.asStringOrNull(json['cash_refunded']),
      expectedCash: JsonUtils.asStringOrNull(json['expected_cash']),
      countedCash: JsonUtils.asStringOrNull(json['counted_cash']),
      variance: JsonUtils.asStringOrNull(json['variance']),
      varianceStatus: JsonUtils.asStringOrNull(json['variance_status']),
    );
  }
}

class ShiftModel {
  final int id;
  final String shiftCode;
  final int? websiteSettingId;
  final int? branchId;
  final int? posDeviceId;
  final int? userId;
  final String status;
  final String? statusLabel;
  final double openingFloat;
  final double? countedCash;
  final double? expectedCash;
  final double? variance;
  final String? openedAt;
  final String? closedAt;
  final String? openingNotes;
  final String? closingNotes;
  final ShiftBranchModel? branch;
  final ShiftPosDeviceModel? posDevice;
  final ShiftWebsiteSettingModel? websiteSetting;
  final ShiftTotalsModel? totals;
  final ShiftReconciliationModel? reconciliation;

  ShiftModel({
    required this.id,
    required this.shiftCode,
    this.websiteSettingId,
    this.branchId,
    this.posDeviceId,
    this.userId,
    required this.status,
    this.statusLabel,
    required this.openingFloat,
    this.countedCash,
    this.expectedCash,
    this.variance,
    this.openedAt,
    this.closedAt,
    this.openingNotes,
    this.closingNotes,
    this.branch,
    this.posDevice,
    this.websiteSetting,
    this.totals,
    this.reconciliation,
  });

  bool get isOpen => status == 'open';
  bool get isPaused => status == 'paused';
  bool get isClosed => status == 'closed' || status == 'ended';

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: JsonUtils.asInt(json['id']),
      shiftCode: JsonUtils.asString(json['shift_code']),
      websiteSettingId: JsonUtils.asIntOrNull(json['website_setting_id']),
      branchId: JsonUtils.asIntOrNull(json['branch_id']),
      posDeviceId: JsonUtils.asIntOrNull(json['pos_device_id']),
      userId: JsonUtils.asIntOrNull(json['user_id']),
      status: JsonUtils.asString(json['status']),
      statusLabel: JsonUtils.asStringOrNull(json['status_label']),
      openingFloat: JsonUtils.asDouble(json['opening_float']),
      countedCash: JsonUtils.asDoubleOrNull(json['counted_cash']),
      expectedCash: JsonUtils.asDoubleOrNull(json['expected_cash']),
      variance: JsonUtils.asDoubleOrNull(json['variance']),
      openedAt: JsonUtils.asStringOrNull(json['opened_at']),
      closedAt: JsonUtils.asStringOrNull(json['closed_at']),
      openingNotes: JsonUtils.asStringOrNull(json['opening_notes']),
      closingNotes: JsonUtils.asStringOrNull(json['closing_notes']),
      branch: JsonUtils.asMapOrNull(json['branch']) != null
          ? ShiftBranchModel.fromJson(JsonUtils.asMap(json['branch']))
          : null,
      posDevice: JsonUtils.asMapOrNull(json['posDevice']) != null
          ? ShiftPosDeviceModel.fromJson(JsonUtils.asMap(json['posDevice']))
          : null,
      websiteSetting: JsonUtils.asMapOrNull(json['websiteSetting']) != null
          ? ShiftWebsiteSettingModel.fromJson(
              JsonUtils.asMap(json['websiteSetting']))
          : null,
      totals: JsonUtils.asMapOrNull(json['totals']) != null
          ? ShiftTotalsModel.fromJson(JsonUtils.asMap(json['totals']))
          : null,
      reconciliation: JsonUtils.asMapOrNull(json['reconciliation']) != null
          ? ShiftReconciliationModel.fromJson(
              JsonUtils.asMap(json['reconciliation']))
          : null,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'shift_code': shiftCode,
        'website_setting_id': websiteSettingId,
        'branch_id': branchId,
        'pos_device_id': posDeviceId,
        'user_id': userId,
        'status': status,
        'status_label': statusLabel,
        'opening_float': openingFloat,
        'counted_cash': countedCash,
        'expected_cash': expectedCash,
        'variance': variance,
        'opened_at': openedAt,
        'closed_at': closedAt,
        'opening_notes': openingNotes,
        'closing_notes': closingNotes,
      };
}

class ShiftResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final ShiftModel? payload;

  ShiftResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.payload,
  });

  factory ShiftResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return ShiftResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      status: JsonUtils.asInt(json['status']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? ShiftModel.fromJson(payload) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Shift closing receipt (print-receipt payload) — a differently-shaped,
// richer snapshot returned only by pos-shifts/:id/print-receipt.
// ---------------------------------------------------------------------------

class ShiftReceiptCompanyModel {
  final String? name;
  final String? tagline;
  final String? logoUrl;
  final String? phone;
  final String? email;
  final String? fullAddress;
  final String? currencySymbol;

  ShiftReceiptCompanyModel({
    this.name,
    this.tagline,
    this.logoUrl,
    this.phone,
    this.email,
    this.fullAddress,
    this.currencySymbol,
  });

  factory ShiftReceiptCompanyModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptCompanyModel(
      name: JsonUtils.asStringOrNull(json['name']),
      tagline: JsonUtils.asStringOrNull(json['tagline']),
      logoUrl: JsonUtils.asStringOrNull(json['logo_url']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
      fullAddress: JsonUtils.asStringOrNull(json['full_address']),
      currencySymbol: JsonUtils.asStringOrNull(json['currency_symbol']),
    );
  }
}

class ShiftReceiptBranchModel {
  final String? name;
  final String? code;
  final String? fullAddress;
  final String? phone;
  final String? managerName;

  ShiftReceiptBranchModel({
    this.name,
    this.code,
    this.fullAddress,
    this.phone,
    this.managerName,
  });

  factory ShiftReceiptBranchModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptBranchModel(
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
      fullAddress: JsonUtils.asStringOrNull(json['full_address']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      managerName: JsonUtils.asStringOrNull(json['manager_name']),
    );
  }
}

class ShiftReceiptDeviceModel {
  final String? name;
  final String? code;
  final String? type;
  final String? location;

  ShiftReceiptDeviceModel({this.name, this.code, this.type, this.location});

  factory ShiftReceiptDeviceModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptDeviceModel(
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
      type: JsonUtils.asStringOrNull(json['type']),
      location: JsonUtils.asStringOrNull(json['location']),
    );
  }
}

class ShiftReceiptShiftInfoModel {
  final String? code;
  final String? status;
  final String? cashier;
  final String? cashierEmail;
  final String? openedAt;
  final String? closedAt;
  final String? duration;
  final String? openingNotes;
  final String? closingNotes;

  ShiftReceiptShiftInfoModel({
    this.code,
    this.status,
    this.cashier,
    this.cashierEmail,
    this.openedAt,
    this.closedAt,
    this.duration,
    this.openingNotes,
    this.closingNotes,
  });

  factory ShiftReceiptShiftInfoModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptShiftInfoModel(
      code: JsonUtils.asStringOrNull(json['code']),
      status: JsonUtils.asStringOrNull(json['status']),
      cashier: JsonUtils.asStringOrNull(json['cashier']),
      cashierEmail: JsonUtils.asStringOrNull(json['cashier_email']),
      openedAt: JsonUtils.asStringOrNull(json['opened_at']),
      closedAt: JsonUtils.asStringOrNull(json['closed_at']),
      duration: JsonUtils.asStringOrNull(json['duration']),
      openingNotes: JsonUtils.asStringOrNull(json['opening_notes']),
      closingNotes: JsonUtils.asStringOrNull(json['closing_notes']),
    );
  }
}

class ShiftReceiptModel {
  final ShiftReceiptCompanyModel company;
  final ShiftReceiptBranchModel branch;
  final ShiftReceiptDeviceModel device;
  final ShiftReceiptShiftInfoModel shift;
  final ShiftOrdersModel orders;
  final ShiftSalesModel sales;
  final ShiftRefundsModel refunds;
  final ShiftReconciliationModel cashReconciliation;
  final String? currency;
  final String? printedAt;
  final String? footer;

  ShiftReceiptModel({
    required this.company,
    required this.branch,
    required this.device,
    required this.shift,
    required this.orders,
    required this.sales,
    required this.refunds,
    required this.cashReconciliation,
    this.currency,
    this.printedAt,
    this.footer,
  });

  factory ShiftReceiptModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptModel(
      company:
          ShiftReceiptCompanyModel.fromJson(JsonUtils.asMap(json['company'])),
      branch:
          ShiftReceiptBranchModel.fromJson(JsonUtils.asMap(json['branch'])),
      device:
          ShiftReceiptDeviceModel.fromJson(JsonUtils.asMap(json['device'])),
      shift: ShiftReceiptShiftInfoModel.fromJson(
          JsonUtils.asMap(json['shift'])),
      orders: ShiftOrdersModel.fromJson(JsonUtils.asMap(json['orders'])),
      sales: ShiftSalesModel.fromJson(JsonUtils.asMap(json['sales'])),
      refunds: ShiftRefundsModel.fromJson(JsonUtils.asMap(json['refunds'])),
      cashReconciliation: ShiftReconciliationModel.fromJson(
          JsonUtils.asMap(json['cash_reconciliation'])),
      currency: JsonUtils.asStringOrNull(json['currency']),
      printedAt: JsonUtils.asStringOrNull(json['printed_at']),
      footer: JsonUtils.asStringOrNull(json['footer']),
    );
  }
}

class ShiftReceiptResponse {
  final bool isSuccess;
  final String message;
  final ShiftReceiptModel? payload;

  ShiftReceiptResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory ShiftReceiptResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return ShiftReceiptResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? ShiftReceiptModel.fromJson(payload) : null,
    );
  }
}
