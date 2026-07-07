import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/profile/model/get_profile_model.dart';

class GetProfileService {
  final NetworkClient _networkClient = Get.find();

  Future<GetProfileModel> getProfile() async {
    try {
      final response = await _networkClient.get(
        endpoint: ApiConstants.getProfileEndpoint,
        showErrorSnackbar: false,
      );
      log("get Profile response: ${response.data}");
      return GetProfileModel.fromJson(response.data);
    } catch (e) {
      log("GetProfileService getProfile error: $e");
      rethrow;
    }
  }
}