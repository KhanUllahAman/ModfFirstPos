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

  /// Removes this device's FCM token server-side so it stops receiving
  /// push after logout. Best-effort — a failure here shouldn't block the
  /// local logout flow, so callers should swallow errors.
  Future<AuthLoginModel> logout({String? fcmToken}) async {
    final body = <String, dynamic>{
      if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
    };
    final response = await _networkClient.post(
      endpoint: ApiConstants.logoutEndpoint,
      body: body,
      showErrorSnackbar: false,
    );
    log("Logout response: ${response.data}");
    return AuthLoginModel.fromJson(response.data);
  }
}