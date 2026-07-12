import 'package:get/get.dart';
import 'package:modfirstpos/modules/productVariant/controller/product_variant_controller.dart';

class ProductVariantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductVariantController>(() => ProductVariantController());
  }
}