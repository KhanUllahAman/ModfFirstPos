import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/profile/model/get_profile_model.dart';
import 'package:modfirstpos/modules/profile/model/update_profile_model.dart';

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


  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String phone,
    required String image,
  }) async {
    try {
      final response = await _networkClient.patch(
        endpoint: ApiConstants.getProfileEndpoint,
        body: {
          'full_name': fullName,
          'phone': phone,
          'image': image,
        },
        showErrorSnackbar: false,
      );
      log("Update Profile response: ${response.data}");
      return UpdateProfileModel.fromJson(response.data);
    } catch (e) {
      log("GetProfileService updateProfile error: $e");
      rethrow;
    }
  }
}