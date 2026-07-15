import 'package:get/get.dart';
import 'package:modfirstpos/modules/catalogue/controller/catalogue_controller.dart';

class CatalogueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogueController>(() => CatalogueController());
  }
}