import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/verifyOtp/model/verify_otp_model.dart';

class VerifyOtpService {
  final NetworkClient _networkClient = Get.find();

  Future<VerifyOtpModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final body = {"email": email, "otp": otp};
      final response = await _networkClient.post(
        endpoint: ApiConstants.verifyOtpEndpoint,
        isLoginRequest: true,
        body: body,
      );
      log("verify otp response: ${response.data}");
      log("body verify otp: ${body.toString()}");
      return VerifyOtpModel.fromJson(response.data);
    } catch (e) {
      log("VerifyOtpService verifyOtp error: $e");
      rethrow;
    }
  }
}