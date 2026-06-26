import 'package:get/get.dart';
import 'package:modfirstpos/modules/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AuthService>(() => AuthService());
    // Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
