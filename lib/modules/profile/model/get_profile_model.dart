import 'dart:developer';

class GetProfileModel {
  final bool success;
  final int status;
  final String message;
  final GetProfilePayload? payload;

  GetProfileModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    GetProfilePayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = GetProfilePayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing get profile payload: $e");
    }
    return GetProfileModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => success;
}

class GetProfilePayload {
  final int? id;
  final String? fullName;
  final String? phone;
  final String? imageUrl;
  final String? role;
  final bool? isAdmin;
  final bool? isActive;
  final bool? isdeleted;
  final dynamic pinCode;
  final bool? pinEnabled;
  final int? pinAttempts;
  final int? autoLockMinutes;

  GetProfilePayload({
    this.id,
    this.fullName,
    this.phone,
    this.imageUrl,
    this.role,
    this.isAdmin,
    this.isActive,
    this.isdeleted,
    this.pinCode,
    this.pinEnabled,
    this.pinAttempts,
    this.autoLockMinutes,
  });

  factory GetProfilePayload.fromJson(Map<String, dynamic> json) {
    return GetProfilePayload(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      imageUrl: json['image']?.toString(),
      role: json['role']?.toString(),
      isAdmin: json['is_admin'] as bool?,
      isActive: json['is_active'] as bool?,
      isdeleted: json['is_deleted'] as bool?,
      pinCode: json['pin_code'],
      pinEnabled: json['pin_enabled'] as bool?,
      pinAttempts: json['pin_attempts'] is num
          ? (json['pin_attempts'] as num).toInt()
          : null,
      autoLockMinutes: json['auto_lock_minutes'] is num
          ? (json['auto_lock_minutes'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'image': imageUrl,
    'role': role,
    'is_admin': isAdmin,
    'is_active': isActive,
    'is_deleted': isdeleted,
    'pin_code': pinCode,
    'pin_enabled': pinEnabled,
    'pin_attempts': pinAttempts,
    'auto_lock_minutes': autoLockMinutes,
  };
}
