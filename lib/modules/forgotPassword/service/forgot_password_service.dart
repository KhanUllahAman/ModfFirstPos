import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/forgotPassword/model/forgot_password_model.dart';

class ForgotPasswordService {
  final NetworkClient _networkClient = Get.find();

  Future<ForgotPasswordModel> forgotPassword({
    required String email,
  }) async {
    try {
      final body = {
        "email": email,
      };
      final response = await _networkClient.post(
        endpoint: ApiConstants.forgotPasswordEndpoint,
        isLoginRequest: false,
        body: body,
      );
      log("Forgot Password response: ${response.data}");
      log("body forgot password: ${body.toString()}");
      return ForgotPasswordModel.fromJson(response.data);
    } catch (e) {
      log("ForgotPasswordService forgotPassword error: $e");
      rethrow;
    }
  }
}
