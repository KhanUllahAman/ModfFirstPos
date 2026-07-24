import 'dart:developer';

class VerifyOtpModel {
  final bool success;
  final int status;
  final String message;
  final VerifyOtpPayload? payload;

  VerifyOtpModel({
    required this.success,
    required this.status,
    required this.message,
    this.payload,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    VerifyOtpPayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = VerifyOtpPayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing verify otp payload: $e");
    }
    return VerifyOtpModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => success;
}

class VerifyOtpPayload {
  final String accessToken;
  final String? refreshToken;

  VerifyOtpPayload({required this.accessToken, this.refreshToken});

  factory VerifyOtpPayload.fromJson(Map<String, dynamic> json) {
    // Tokens may arrive flat (accessToken/refreshToken) or nested under
    // "tokens" (matching the shape auth/refresh-token returns).
    final tokens = json['tokens'] is Map<String, dynamic>
        ? json['tokens'] as Map<String, dynamic>
        : json;
    return VerifyOtpPayload(
      accessToken: tokens['accessToken']?.toString() ?? '',
      refreshToken: tokens['refreshToken']?.toString(),
    );
  }
}