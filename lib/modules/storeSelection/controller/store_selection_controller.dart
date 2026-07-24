// lib/modules/storeSelection/controller/store_selection_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/services/website_settings_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/storeSelection/model/store_selection_model.dart';
import 'package:modfirstpos/modules/storeSelection/service/store_selection_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class StoreSelectionController extends GetxController {
  final StoreSelectionService _service = StoreSelectionService();

  final RxBool isLoading = false.obs;
  final RxBool isFetchingStores = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SaleSelectionPayload> stores = <SaleSelectionPayload>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      isFetchingStores.value = true;
      errorMessage.value = '';
      final response = await _service.storeSelectionApi();

      if (response.isSuccess && response.payload.isNotEmpty) {
        stores.assignAll(response.payload);
      } else {
        stores.clear();
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'No stores are available right now.';
      }
    } catch (e) {
      log("StoreSelectionController fetchStores error: $e");
      stores.clear();
      errorMessage.value = 'Could not load stores. Please try again.';
    } finally {
      isFetchingStores.value = false;
    }
  }

  String _slugify(String siteName) =>
      siteName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  Future<void> selectStore(SaleSelectionPayload store) async {
    final siteName = store.siteName;
    if (siteName == null || siteName.trim().isEmpty) {
      customSnackBar(
        'Error',
        'This store is missing a valid name.',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    final slug = _slugify(siteName);

    try {
      isLoading.value = true;
      CustomLoadingDialog.show();

      final response = await Get.find<WebsiteSettingsService>()
          .fetchAndSaveWebsiteSettings(slug);

      CustomLoadingDialog.hide();

      if (!response.isSuccess) {
        customSnackBar(
          'Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      await Get.find<AppThemeService>().refreshFromStorage();
      await SecureStorageService.saveSelectedStore(slug);
      await SecureStorageService.saveStoreSelectionDone();

      Get.offAllNamed(Routes.auth);
    } catch (e) {
      log("StoreSelectionController selectStore error: $e");
      CustomLoadingDialog.hide();
      customSnackBar(
        'Error',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
