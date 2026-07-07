class ForgotPasswordModel {
  final bool success;
  final int status;
  final String message;

  ForgotPasswordModel({
    required this.success,
    required this.status,
    required this.message,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      success: json['success'] == true,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => success;
}