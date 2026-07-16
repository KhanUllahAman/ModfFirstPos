import 'package:get/get.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/productVariant/controller/product_variant_controller.dart';

class ProductVariantBinding extends Bindings {
  @override
  void dependencies() {
    // The variant screen adds items to the shared cart owned by
    // HomeController. When this screen is reached without the home route in
    // the stack (e.g. via catalogue), make sure the controller exists.
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
    Get.lazyPut<ProductVariantController>(() => ProductVariantController());
  }
}
