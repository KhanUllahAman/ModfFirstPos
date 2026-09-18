import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/auth/model/send_otp_model.dart';

class SendOtpService {
  final NetworkClient _networkClient = Get.find();

  Future<SendOtpModel> sendOtp({required String email}) async {
    try {
      final body = {"email": email};
      final response = await _networkClient.post(
        endpoint: ApiConstants.sendOtpEndpoint,
        isLoginRequest: true,
        body: body,
        showErrorSnackbar: false,
      );
      log("send otp response: ${response.data}");
      log("body send otp: ${body.toString()}");
      return SendOtpModel.fromJson(response.data);
    } catch (e) {
      log("SendOtpService sendOtp error: $e");
      rethrow;
    }
  }
}