import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';

class BootstrapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BootstrapController>(() => BootstrapController(), fenix: true);
  }
}
