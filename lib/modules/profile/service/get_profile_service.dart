import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/profile/model/profile_model.dart';

class GetProfileService {
  final NetworkClient _networkClient = Get.find();

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _networkClient.get(
        endpoint: ApiConstants.getProfileEndpoint,
        showErrorSnackbar: false,
      );
      log("get Profile response: ${response.data}");
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      log("GetProfileService getProfile error: $e");
      rethrow;
    }
  }

  Future<ProfileModel> updateProfile({
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
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      log("GetProfileService updateProfile error: $e");
      rethrow;
    }
  }

  Future<ImageUploadModel> uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': [
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        ],
      });
      final response = await _networkClient.postFormData(
        endpoint: ApiConstants.uploadImageEndpoint,
        formData: formData,
        showErrorSnackbar: false,
      );
      log("Upload Image response: ${response.data}");
      return ImageUploadModel.fromJson(response.data);
    } catch (e) {
      log("GetProfileService uploadImage error: $e");
      rethrow;
    }
  }
}