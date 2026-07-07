import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/auth/model/auth_model.dart';

class AuthService {
  final NetworkClient _networkClient = Get.find();

  Future<AuthLoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {"email": email, "password": password};
      final response = await _networkClient.post(
        endpoint: ApiConstants.loginEndpoint,
        isLoginRequest: true,
        body: body,
        showErrorSnackbar: false,
      );
      log("Login response: ${response.data}");
      return AuthLoginModel.fromJson(response.data);
    } catch (e) {
      log("AuthService login error: $e");
      rethrow;
    }
  }
}