import 'package:get/get.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';

class ShiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShiftController>(() => ShiftController(), fenix: true);
  }
}
