import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/changePassword/model/change_password_model.dart';

class ChangePasswordService {
  final NetworkClient _networkClient = Get.find();

  Future<ChangePasswordModel> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _networkClient.post(
        endpoint: ApiConstants.changePasswordEndpoint,
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        showErrorSnackbar: false,
      );
      log("Change Password response: ${response.data}");
      return ChangePasswordModel.fromJson(response.data);
    } catch (e) {
      log("ChangePasswordService changePassword error: $e");
      rethrow;
    }
  }
}