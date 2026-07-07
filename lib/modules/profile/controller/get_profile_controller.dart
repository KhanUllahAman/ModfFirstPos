import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/profile/model/get_profile_model.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class GetProfileController extends GetxController {
  final GetProfileService _getProfileService = Get.find<GetProfileService>();

  final Rxn<GetProfilePayload> profile = Rxn<GetProfilePayload>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileFromStorage();
  }

  Future<void> _loadProfileFromStorage() async {
    isLoading.value = true;
    try {
      final storedData = await SecureStorageService.getProfileData();
      if (storedData != null) {
        profile.value = GetProfilePayload.fromJson(storedData);
      } else {
        log("No profile data found in secure storage.");
      }
    } catch (e) {
      log("Error loading profile from storage: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfileFromServer({bool showDialog = true}) async {
    try {
      if (showDialog) CustomLoadingDialog.show();
      isLoading.value = true;

      final response = await _getProfileService.getProfile();

      if (!response.isSuccess || response.payload == null) {
        customSnackBar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to load profile',
          snackBarType: SnackBarType.error,
        );
        return;
      }
      profile.value = response.payload;
      await SecureStorageService.saveProfileData(response.payload!.toJson());
    } catch (e) {
      log("Get profile error: $e");
      customSnackBar(
        'Error',
        'Something went wrong while loading profile',
        snackBarType: SnackBarType.error,
      );
    } finally {
      if (showDialog) CustomLoadingDialog.hide();
      isLoading.value = false;
    }
  }

  void goToUpdateProfile() {
    // Get.toNamed(Routes.updateProfile);
  }
}