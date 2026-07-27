import 'package:get/get.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';

class CustomerInitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerDisplayServerService>(
      CustomerDisplayServerService(),
      permanent: true,
    );
  }
}