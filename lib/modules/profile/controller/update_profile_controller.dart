import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/modules/profile/model/profile_model.dart';
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

  String get displayImageUrl {
    final raw = existingImageUrl.value;
    if (raw.isEmpty) return raw;
    if (raw.startsWith('https')) return raw;
    return 'https://command.modfirst.com/uploads$raw';
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
      final response = await _profileService.uploadImage(selectedImage.value!);

      if (!response.isSuccess || response.payload?.url == null) {
        _pendingErrorMessage = response.message.isNotEmpty
            ? response.message
            : 'Image upload failed';
        return existingImageUrl.value.isNotEmpty
            ? existingImageUrl.value
            : null;
      }

      return response.payload!.url;
    } catch (e) {
      log("UpdateProfileController image upload error: $e");
      _pendingErrorMessage = 'Something went wrong while uploading image';
      return existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  String? _pendingErrorMessage;

  Future<void> updateProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _pendingErrorMessage = null;
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
        _pendingErrorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to update profile';
        return;
      }
      await _syncUpdatedProfile(response.payload!);
    } catch (e) {
      log("UpdateProfileController updateProfile error: $e");
      _pendingErrorMessage = 'Something went wrong while updating profile';
    } finally {
      CustomLoadingDialog.hide();
      isLoading.value = false;
      await Future.delayed(const Duration(milliseconds: 100));
      if (_pendingErrorMessage != null) {
        customSnackBar(
          'Error',
          _pendingErrorMessage!,
          snackBarType: SnackBarType.error,
        );
      } else {
        customSnackBar(
          'Success',
          'Profile updated successfully',
          snackBarType: SnackBarType.success,
        );
        Get.back();
      }
    }
  }

  Future<void> _syncUpdatedProfile(ProfilePayload payload) async {
    try {
      final storedData = await SecureStorageService.getProfileData();
      final mergedData = <String, dynamic>{...?storedData, ...payload.toJson()};

      if (Get.isRegistered<GetProfileController>()) {
        await Get.find<GetProfileController>().updateProfileLocally(mergedData);
      } else {
        await SecureStorageService.saveProfileData(mergedData);
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
