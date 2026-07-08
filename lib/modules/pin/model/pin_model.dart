import 'dart:developer';

class PinStatusModel {
  final bool success;
  final int status;
  final String message;
  final PinStatusPayload? payload;

  PinStatusModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
  });

  factory PinStatusModel.fromJson(Map<String, dynamic> json) {
    PinStatusPayload? payload;
    try {
      final data = json['payload'];
      if (data is Map<String, dynamic>) {
        payload = PinStatusPayload.fromJson(data);
      }
    } catch (e) {
      log("Error parsing pin status payload: $e");
    }
    return PinStatusModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => success;
}

class PinStatusPayload {
  final bool pinEnabled;
  final int autoLockMinutes;

  PinStatusPayload({required this.pinEnabled, required this.autoLockMinutes});

  factory PinStatusPayload.fromJson(Map<String, dynamic> json) {
    return PinStatusPayload(
      pinEnabled: json['pin_enabled'] == true,
      autoLockMinutes: json['auto_lock_minutes'] is num
          ? (json['auto_lock_minutes'] as num).toInt()
          : 10,
    );
  }
}


class PinActionModel {
  final bool success;
  final int status;
  final String message;
  final List<String>? validationErrors;

  PinActionModel({
    required this.success,
    required this.status,
    required this.message,
    this.validationErrors,
  });

  factory PinActionModel.fromJson(Map<String, dynamic> json) {
    List<String>? validationErrors;
    try {
      final data = json['payload'];
      if (data is List) {
        validationErrors = data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      log("Error parsing pin action payload: $e");
    }
    return PinActionModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      validationErrors: validationErrors,
    );
  }

  bool get isSuccess => success;

  String get displayMessage {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return validationErrors!.join('\n');
    }
    return message.isNotEmpty ? message : 'Something went wrong';
  }
}

class AutoLockModel {
  final bool success;
  final int status;
  final String message;
  final int? autoLockMinutes;

  AutoLockModel({
    required this.success,
    required this.status,
    required this.message,
    this.autoLockMinutes,
  });

  factory AutoLockModel.fromJson(Map<String, dynamic> json) {
    int? minutes;
    try {
      final data = json['payload'];
      if (data is Map<String, dynamic>) {
        minutes = data['auto_lock_minutes'] is num
            ? (data['auto_lock_minutes'] as num).toInt()
            : null;
      }
    } catch (e) {
      log("Error parsing auto lock payload: $e");
    }
    return AutoLockModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      autoLockMinutes: minutes,
    );
  }

  bool get isSuccess => success;
}