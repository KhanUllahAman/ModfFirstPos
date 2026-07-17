import 'package:get/get.dart';
import 'package:modfirstpos/core/services/website_settings_service.dart';
import 'package:modfirstpos/modules/storeSelection/controller/store_selection_controller.dart';

class StoreSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebsiteSettingsService>(() => WebsiteSettingsService(), fenix: true);
    Get.lazyPut<StoreSelectionController>(() => StoreSelectionController(), fenix: true);
  }
}