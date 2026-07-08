import 'package:get/get.dart';
import 'package:modfirstpos/modules/pin/controller/set_pin_controller.dart';

class SetPinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetPinController>(() => SetPinController());
  }
}