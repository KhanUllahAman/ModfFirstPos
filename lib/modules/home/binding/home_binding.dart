import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/draft_orders/controller/draft_order_controller.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/checkout/controller/checkout_controller.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // fenix keeps registrations alive across Get.offAllNamed navigation so a
    // disposed controller is always recreated instead of reused.
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CustomerController>(() => CustomerController(), fenix: true);
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<ShiftController>(() => ShiftController(), fenix: true);
    Get.lazyPut<BootstrapController>(() => BootstrapController(), fenix: true);
    Get.lazyPut<DraftOrderController>(() => DraftOrderController(), fenix: true);
  }
}