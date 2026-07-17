import 'package:get/get.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // fenix keeps the registration alive so the controller is recreated
    // (never reused after dispose) when drawer navigation rebuilds routes.
    Get.lazyPut<CustomerController>(() => CustomerController(), fenix: true);
  }
}
