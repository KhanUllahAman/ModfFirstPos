import 'package:modfirstpos/core/utils/json_utils.dart';
import 'dart:developer';

class ProfileModel {
  final bool success;
  final int status;
  final String message;
  final ProfilePayload? payload;

  ProfileModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    ProfilePayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = ProfilePayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing profile payload: $e");
    }
    return ProfileModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => success;
}

class ProfilePayload {
  final int? id;
  final String? fullName;
  final String? email;
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

  ProfilePayload({
    this.id,
    this.fullName,
    this.email,
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

  factory ProfilePayload.fromJson(Map<String, dynamic> json) {
    return ProfilePayload(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      imageUrl: json['image']?.toString(),
      role: json['role']?.toString(),
      isAdmin: JsonUtils.asBoolOrNull(json['is_admin']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isdeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      pinCode: json['pin_code'],
      pinEnabled: JsonUtils.asBoolOrNull(json['pin_enabled']),
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
    'email': email,
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

  ProfilePayload copyWithJson(Map<String, dynamic> updates) {
    final merged = <String, dynamic>{...toJson(), ...updates};
    return ProfilePayload.fromJson(merged);
  }

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    return 'https://command.modfirst.com$imageUrl';
  }
}

class ImageUploadModel {
  final bool success;
  final int status;
  final String message;
  final ImageUploadPayload? payload;

  ImageUploadModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
  });

  factory ImageUploadModel.fromJson(Map<String, dynamic> json) {
    ImageUploadPayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = ImageUploadPayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing image upload payload: $e");
    }
    return ImageUploadModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => success;
}

class ImageUploadPayload {
  final String? url;
  final String? absoluteUrl;
  final String? filename;
  final int? size;
  final String? originalName;

  ImageUploadPayload({
    this.url,
    this.absoluteUrl,
    this.filename,
    this.size,
    this.originalName,
  });

  factory ImageUploadPayload.fromJson(Map<String, dynamic> json) {
    return ImageUploadPayload(
      url: json['url']?.toString(),
      absoluteUrl: json['absolute_url']?.toString(),
      filename: json['filename']?.toString(),
      size: json['size'] is num ? (json['size'] as num).toInt() : null,
      originalName: json['originalName']?.toString(),
    );
  }

  /// Prefer the server-provided absolute URL; fall back to prefixing the
  /// relative [url] the same way [ProfilePayload.fullImageUrl] does.
  String? get displayUrl {
    if (absoluteUrl != null && absoluteUrl!.isNotEmpty) return absoluteUrl;
    if (url == null || url!.isEmpty) return null;
    if (url!.startsWith('http://') || url!.startsWith('https://')) return url;
    return 'https://command.modfirst.com$url';
  }
}
