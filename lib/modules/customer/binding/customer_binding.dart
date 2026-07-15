import 'package:get/get.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}
