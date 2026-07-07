import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/modules/profile/model/update_profile_model.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class UpdateProfileController extends GetxController {
  final GetProfileService _profileService = Get.find<GetProfileService>();
  final ImagePicker _imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillFromExistingProfile();
  }

  void _prefillFromExistingProfile() {
    final getProfileController = Get.isRegistered<GetProfileController>()
        ? Get.find<GetProfileController>()
        : null;

    final profile = getProfileController?.profile.value;

    fullNameController = TextEditingController(text: profile?.fullName ?? '');
    phoneController = TextEditingController(text: profile?.phone ?? '');
    existingImageUrl.value = profile?.imageUrl ?? '';
  }


  Future<void> pickImageFromCamera() => _pickImage(ImageSource.camera);

  Future<void> pickImageFromGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      log("UpdateProfileController pickImage error: $e");
      customSnackBar(
        'Error',
        'Unable to pick image',
        snackBarType: SnackBarType.error,
      );
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  Future<String?> _uploadImageIfNeeded() async {
    if (selectedImage.value == null) {
      return existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null;
    }
    try {
      isUploadingImage.value = true;
      log(
        "Image upload API not integrated yet. Skipping upload, "
        "keeping old image url for now.",
      );
      return existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null;
    } catch (e) {
      log("UpdateProfileController image upload error: $e");
      return existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null;
    } finally {
      isUploadingImage.value = false;
    }
  }


  Future<void> updateProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    try {
      CustomLoadingDialog.show();
      isLoading.value = true;
      final imageUrl = await _uploadImageIfNeeded() ?? '';
      final response = await _profileService.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        image: imageUrl,
      );
      if (!response.isSuccess || response.payload == null) {
        customSnackBar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile',
          snackBarType: SnackBarType.error,
        );
        return;
      }
      await _syncUpdatedProfile(response.payload!);
      customSnackBar(
        'Success',
        'Profile updated successfully',
        snackBarType: SnackBarType.success,
      );
      Get.back();
    } catch (e) {
      log("UpdateProfileController updateProfile error: $e");
      customSnackBar(
        'Error',
        'Something went wrong while updating profile',
        snackBarType: SnackBarType.error,
      );
    } finally {
      CustomLoadingDialog.hide();
      isLoading.value = false;
    }
  }

 
  Future<void> _syncUpdatedProfile(UpdateProfilePayload payload) async {
    try {
      final storedData = await SecureStorageService.getProfileData();
      final mergedData = <String, dynamic>{
        ...?storedData,
        ...payload.toJson(),
      };

      await SecureStorageService.saveProfileData(mergedData);

      if (Get.isRegistered<GetProfileController>()) {
        Get.find<GetProfileController>().refreshProfileFromServer(
          showDialog: false,
        );
      }
    } catch (e) {
      log("UpdateProfileController _syncUpdatedProfile error: $e");
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}