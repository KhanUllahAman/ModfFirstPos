import 'package:modfirstpos/core/utils/json_utils.dart';

class BranchModel {
  final int id;
  final String? name;
  final String? code;
  final String? description;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? managerName;
  final String? managerEmail;
  final String? managerPhone;
  final bool isActive;

  BranchModel({
    required this.id,
    this.name,
    this.code,
    this.description,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.phone,
    this.email,
    this.managerName,
    this.managerEmail,
    this.managerPhone,
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: JsonUtils.asInt(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
      description: JsonUtils.asStringOrNull(json['description']),
      addressLine1: JsonUtils.asStringOrNull(json['address_line_1']),
      addressLine2: JsonUtils.asStringOrNull(json['address_line_2']),
      city: JsonUtils.asStringOrNull(json['city']),
      state: JsonUtils.asStringOrNull(json['state']),
      country: JsonUtils.asStringOrNull(json['country']),
      postalCode: JsonUtils.asStringOrNull(json['postal_code']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
      managerName: JsonUtils.asStringOrNull(json['manager_name']),
      managerEmail: JsonUtils.asStringOrNull(json['manager_email']),
      managerPhone: JsonUtils.asStringOrNull(json['manager_phone']),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
    );
  }
}

class PosDeviceModel {
  final int id;
  final int? branchId;
  final String name;
  final String deviceCode;
  final String deviceType;
  final String ipAddress;
  final String? macAddress;
  final String? customerIp;
  final String location;
  final String receiptType;
  final bool isActive;
  final BranchModel? branch;

  PosDeviceModel({
    required this.id,
    this.branchId,
    required this.name,
    required this.deviceCode,
    required this.deviceType,
    required this.ipAddress,
    this.macAddress,
    this.customerIp,
    required this.location,
    required this.receiptType,
    this.isActive = true,
    this.branch,
  });

  factory PosDeviceModel.fromJson(Map<String, dynamic> json) {
    return PosDeviceModel(
      id: JsonUtils.asInt(json['id']),
      branchId: JsonUtils.asIntOrNull(json['branch_id']),
      name: JsonUtils.asString(json['name']),
      deviceCode: JsonUtils.asString(json['device_code']),
      deviceType: JsonUtils.asString(json['device_type']),
      ipAddress: JsonUtils.asString(json['ip_address']),
      macAddress: JsonUtils.asStringOrNull(json['mac_address']),
      customerIp: JsonUtils.asStringOrNull(json['customer_ip']),
      location: JsonUtils.asString(json['location']),
      receiptType: JsonUtils.asString(json['receipt_type']),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
      branch: JsonUtils.asMapOrNull(json['branch']) != null
          ? BranchModel.fromJson(JsonUtils.asMap(json['branch']))
          : null,
    );
  }

  /// Only the fields accepted by PUT pos-device/:id.
  Map<String, dynamic> toJson() => {
        'name': name,
        'device_code': deviceCode,
        'device_type': deviceType,
        'ip_address': ipAddress,
        'customer_ip': customerIp,
        'location': location,
        'receipt_type': receiptType,
        'is_active': isActive,
      };

  /// Full JSON (including id/branch) — used for local caching only.
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'branch_id': branchId,
        ...toJson(),
        'mac_address': macAddress,
      };

  PosDeviceModel copyWith({
    String? name,
    String? deviceCode,
    String? deviceType,
    String? ipAddress,
    String? customerIp,
    String? location,
    String? receiptType,
    bool? isActive,
  }) {
    return PosDeviceModel(
      id: id,
      branchId: branchId,
      name: name ?? this.name,
      deviceCode: deviceCode ?? this.deviceCode,
      deviceType: deviceType ?? this.deviceType,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress,
      customerIp: customerIp ?? this.customerIp,
      location: location ?? this.location,
      receiptType: receiptType ?? this.receiptType,
      isActive: isActive ?? this.isActive,
      branch: branch,
    );
  }
}

class PosDeviceListResponse {
  final bool isSuccess;
  final String message;
  final List<PosDeviceModel> payload;

  PosDeviceListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
  });

  factory PosDeviceListResponse.fromJson(Map<String, dynamic> json) {
    return PosDeviceListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], PosDeviceModel.fromJson),
    );
  }
}

class PosDeviceResponse {
  final bool isSuccess;
  final String message;
  final PosDeviceModel? payload;

  PosDeviceResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory PosDeviceResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return PosDeviceResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? PosDeviceModel.fromJson(payload) : null,
    );
  }
}
