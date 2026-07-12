import 'package:get/get.dart';
import 'package:modfirstpos/modules/categoryProducts/controller/category_products_controller.dart';

class CategoryProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryProductsController>(() => CategoryProductsController());
  }
}