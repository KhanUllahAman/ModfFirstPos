// lib/modules/storeSelection/controller/store_selection_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/services/website_settings_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class StoreItem {
  final String displayName;
  final String slug;
  const StoreItem({required this.displayName, required this.slug});
}

class StoreSelectionController extends GetxController {
  final RxBool isLoading = false.obs;

  final List<StoreItem> stores = const [
    StoreItem(displayName: 'ModFirst', slug: 'modfirst'),
  ];

  Future<void> selectStore(StoreItem store) async {
    try {
      isLoading.value = true;
      CustomLoadingDialog.show();

      final response = await Get.find<WebsiteSettingsService>()
          .fetchAndSaveWebsiteSettings(store.slug);

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
      await SecureStorageService.saveSelectedStore(store.slug);
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
