import 'dart:developer';

class OutletResponseModel {
  final int status;
  final String message;
  final OutletPayload? payload;

  OutletResponseModel({
    required this.status,
    required this.message,
    this.payload,
  });

  factory OutletResponseModel.fromJson(Map<String, dynamic> json) {
    OutletPayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = OutletPayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing outlet payload: $e");
    }

    final rawStatus = json['status'];
    final int parsedStatus = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '0') ?? 0;

    return OutletResponseModel(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => status == 1;
}


class OutletPayload {
  final String? signature;
  final OutletInfo? outlet;
  final List<StaffMember> staff;
  final List<OutletOption> serviceCharges;
  final List<OutletOption> creditCards;
  final List<dynamic> timeslot;

  OutletPayload({
    this.signature,
    this.outlet,
    required this.staff,
    required this.serviceCharges,
    required this.creditCards,
    required this.timeslot,
  });

  factory OutletPayload.fromJson(Map<String, dynamic> json) {
    final List<StaffMember> staffList = [];
    final staffData = json['staff'];
    if (staffData != null && staffData is List) {
      for (var item in staffData) {
        if (item is Map<String, dynamic>) {
          try {
            staffList.add(StaffMember.fromJson(item));
          } catch (e) {
            log("Error parsing staff member: $e");
          }
        }
      }
    }

    final List<OutletOption> serviceChargesList = [];
    final scData = json['service_charges'];
    if (scData != null && scData is List) {
      for (var item in scData) {
        if (item is Map<String, dynamic>) {
          try {
            serviceChargesList.add(OutletOption.fromJson(item));
          } catch (e) {
            log("Error parsing service charge: $e");
          }
        }
      }
    }

    final List<OutletOption> creditCardsList = [];
    final ccData = json['credit_cards'];
    if (ccData != null && ccData is List) {
      for (var item in ccData) {
        if (item is Map<String, dynamic>) {
          try {
            creditCardsList.add(OutletOption.fromJson(item));
          } catch (e) {
            log("Error parsing credit card: $e");
          }
        }
      }
    }

    final List<dynamic> timeslotList = [];
    final tsData = json['timeslot'];
    if (tsData != null && tsData is List) {
      timeslotList.addAll(tsData);
    }

    OutletInfo? outlet;
    final outletData = json['outlet'];
    if (outletData != null && outletData is Map<String, dynamic>) {
      try {
        outlet = OutletInfo.fromJson(outletData);
      } catch (e) {
        log("Error parsing outlet info: $e");
      }
    }

    return OutletPayload(
      signature: json['signature']?.toString(),
      outlet: outlet,
      staff: staffList,
      serviceCharges: serviceChargesList,
      creditCards: creditCardsList,
      timeslot: timeslotList,
    );
  }
}


class OutletInfo {
  final String? name;
  final String? category;
  final String? gst;
  final String? locCode;
  final String? deviceId;
  final String? deviceStatus;
  final String? lastAppInvoiceNo;
  final String? locCountry;
  final String? shiftCloseNumber;
  final String? locCurrencyType;
  final String? lastMemberId;
  final String? lastVoucherId;
  final String? lastServiceId;
  final String? saleReturnNo;

  OutletInfo({
    this.name,
    this.category,
    this.gst,
    this.locCode,
    this.deviceId,
    this.deviceStatus,
    this.lastAppInvoiceNo,
    this.locCountry,
    this.shiftCloseNumber,
    this.locCurrencyType,
    this.lastMemberId,
    this.lastVoucherId,
    this.lastServiceId,
    this.saleReturnNo,
  });

  factory OutletInfo.fromJson(Map<String, dynamic> json) {
    return OutletInfo(
      name: json['name']?.toString(),
      category: json['category']?.toString(),
      gst: json['gst']?.toString(),
      locCode: json['loc_code']?.toString(),
      deviceId: json['deviceid']?.toString(),
      deviceStatus: json['device_status']?.toString(),
      lastAppInvoiceNo: json['last_app_invoice_no']?.toString(),
      locCountry: json['loc_country']?.toString(),
      shiftCloseNumber: json['shiftclosenumber']?.toString(),
      locCurrencyType: json['loc_currency_type']?.toString(),
      lastMemberId: json['last_member_id']?.toString(),
      lastVoucherId: json['last_voucher_id']?.toString(),
      lastServiceId: json['last_service_id']?.toString(),
      saleReturnNo: json['sale_return_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'gst': gst,
        'loc_code': locCode,
        'deviceid': deviceId,
        'device_status': deviceStatus,
        'last_app_invoice_no': lastAppInvoiceNo,
        'loc_country': locCountry,
        'shiftclosenumber': shiftCloseNumber,
        'loc_currency_type': locCurrencyType,
        'last_member_id': lastMemberId,
        'last_voucher_id': lastVoucherId,
        'last_service_id': lastServiceId,
        'sale_return_no': saleReturnNo,
      };

  String get displayName => name ?? 'Unknown Outlet';
  String get displayCategory => category ?? '--';
  String get displayCurrency => locCurrencyType ?? 'Rs.';
  bool get isDeviceActive => deviceStatus != '0';
}


class StaffMember {
  final int? id;
  final String? shortName;
  final String? fullName;

  StaffMember({this.id, this.shortName, this.fullName});

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int? parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    return StaffMember(
      id: parsedId,
      shortName: json['short_name']?.toString(),
      fullName: json['full_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'short_name': shortName,
        'full_name': fullName,
      };

  String get displayName => fullName ?? shortName ?? 'Unknown';
  String get displayShort => shortName ?? '--';
}

// ─────────────────────────────────────────────
// Generic Option (service charges + credit cards)
// ─────────────────────────────────────────────
class OutletOption {
  final int? id;
  final String? optionName;

  OutletOption({this.id, this.optionName});

  factory OutletOption.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int? parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    return OutletOption(
      id: parsedId,
      optionName: json['option_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'option_name': optionName,
      };

  String get displayName => optionName ?? '--';
}