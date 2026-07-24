import 'package:get/get.dart';
import 'package:modfirstpos/modules/inventory/controller/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryController>(() => InventoryController(), fenix: true);
  }
}
