import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/pin/model/pin_model.dart';

class PinService {
  final NetworkClient _networkClient = Get.find();

  Future<PinStatusModel> getPinStatus() async {
    try {
      final response = await _networkClient.get(
        endpoint: ApiConstants.pinStatusEndpoint,
        showErrorSnackbar: false,
      );
      log("Pin status response: ${response.data}");
      return PinStatusModel.fromJson(response.data);
    } catch (e) {
      log("PinService getPinStatus error: $e");
      rethrow;
    }
  }

  Future<PinActionModel> setPin({
    required String pin,
    required String confirmPin,
  }) async {
    try {
      final response = await _networkClient.post(
        endpoint: ApiConstants.pinSetEndpoint,
        body: {'pin': pin, 'confirmPin': confirmPin},
        showErrorSnackbar: false,
      );
      log("Set pin response: ${response.data}");
      return PinActionModel.fromJson(response.data);
    } catch (e) {
      log("PinService setPin error: $e");
      rethrow;
    }
  }

  Future<PinActionModel> verifyPin({required String pin}) async {
    try {
      final response = await _networkClient.post(
        endpoint: ApiConstants.pinVerifyEndpoint,
        body: {'pin': pin},
        showErrorSnackbar: false,
      );
      log("Verify pin response: ${response.data}");
      return PinActionModel.fromJson(response.data);
    } catch (e) {
      log("PinService verifyPin error: $e");
      rethrow;
    }
  }

  Future<PinActionModel> changePin({
    required String currentPin,
    required String newPin,
    required String confirmNewPin,
  }) async {
    try {
      final response = await _networkClient.put(
        endpoint: ApiConstants.pinChangeEndpoint,
        body: {
          'currentPin': currentPin,
          'newPin': newPin,
          'confirmNewPin': confirmNewPin,
        },
        showErrorSnackbar: false,
      );
      log("Change pin response: ${response.data}");
      return PinActionModel.fromJson(response.data);
    } catch (e) {
      log("PinService changePin error: $e");
      rethrow;
    }
  }

  Future<PinActionModel> disablePin({required String currentPin}) async {
    try {
      final response = await _networkClient.delete(
        endpoint: ApiConstants.pinDisableEndpoint,
        body: {'currentPin': currentPin},
        showErrorSnackbar: false,
      );
      log("Disable pin response: ${response.data}");
      return PinActionModel.fromJson(response.data);
    } catch (e) {
      log("PinService disablePin error: $e");
      rethrow;
    }
  }

  Future<AutoLockModel> updateAutoLockMinutes(int minutes) async {
    try {
      final response = await _networkClient.put(
        endpoint: ApiConstants.pinAutoLockEndpoint,
        body: {'auto_lock_minutes': minutes},
        showErrorSnackbar: false,
      );
      log("Update auto lock response: ${response.data}");
      return AutoLockModel.fromJson(response.data);
    } catch (e) {
      log("PinService updateAutoLockMinutes error: $e");
      rethrow;
    }
  }
}