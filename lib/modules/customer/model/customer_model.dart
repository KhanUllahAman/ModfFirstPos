import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';

class CustomerModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  final String? image;
  final bool isActive;
  final bool isLocked;
  final String? lastLoginDate;
  final String? createdAt;
  final String? updatedAt;
  final bool emailVerified;

  /// True when the customer was created on this device and has not been
  /// pushed to the backend yet (offline-first support).
  final bool isLocalOnly;

  CustomerModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.image,
    this.isActive = true,
    this.isLocked = false,
    this.lastLoginDate,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
    this.isLocalOnly = false,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: JsonUtils.asInt(json['id']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      email: JsonUtils.asStringOrNull(json['email']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      address: JsonUtils.asStringOrNull(json['address']),
      role: JsonUtils.asStringOrNull(json['role']),
      image: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image']),
        baseHost: 'http://13.62.114.94:3000',
      ),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
      isLocked: JsonUtils.asBool(json['is_locked']),
      lastLoginDate: JsonUtils.asStringOrNull(json['last_login_date']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      emailVerified: JsonUtils.asBool(json['email_verified']),
      isLocalOnly: JsonUtils.asBool(json['is_local_only']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'image': image,
      'is_active': isActive,
      'is_locked': isLocked,
      'last_login_date': lastLoginDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'email_verified': emailVerified,
      'is_local_only': isLocalOnly,
    };
  }

  CustomerModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    bool? isLocalOnly,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role,
      image: image,
      isActive: isActive,
      isLocked: isLocked,
      lastLoginDate: lastLoginDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      emailVerified: emailVerified,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    );
  }

  String get displayName {
    final name = fullName?.trim();
    return (name == null || name.isEmpty) ? 'Unnamed Customer' : name;
  }
}

class CreateCustomerResponse {
  final bool isSuccess;
  final String message;
  final CustomerModel? payload;

  CreateCustomerResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return CreateCustomerResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? CustomerModel.fromJson(payload) : null,
    );
  }
}

class CustomerListResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final List<CustomerModel> payload;
  final PaginationModel pagination;

  CustomerListResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      status: JsonUtils.asInt(json['status'], fallback: 200),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], CustomerModel.fromJson),
      pagination: PaginationModel.fromJson(JsonUtils.asMap(json['pagination'])),
    );
  }
}
