class SendOtpModel {
  final bool success;
  final int status;
  final String message;
  final Map<String, dynamic> payload;

  SendOtpModel({
    required this.success,
    required this.status,
    required this.message,
    required this.payload,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : {},
    );
  }

  bool get isSuccess => success;
}