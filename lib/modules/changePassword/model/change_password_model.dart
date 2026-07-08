import 'dart:developer';

class ChangePasswordModel {
  final bool success;
  final int status;
  final String message;
  final ChangePasswordPayload? payload;
  final List<String>? validationErrors;

  ChangePasswordModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
    this.validationErrors,
  });

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    ChangePasswordPayload? payload;
    List<String>? validationErrors;
    try {
      final payloadData = json['payload'];
      if (payloadData is Map<String, dynamic>) {
        payload = ChangePasswordPayload.fromJson(payloadData);
      } else if (payloadData is List) {
        validationErrors = payloadData.map((e) => e.toString()).toList();
      }
    } catch (e) {
      log("Error parsing change password payload: $e");
    }
    return ChangePasswordModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
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

class ChangePasswordPayload {
  final String? message;

  ChangePasswordPayload({this.message});

  factory ChangePasswordPayload.fromJson(Map<String, dynamic> json) {
    return ChangePasswordPayload(message: json['message']?.toString());
  }
}