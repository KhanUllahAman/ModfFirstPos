import 'package:get/get.dart';
import 'package:modfirstpos/modules/reporting/controller/reporting_controller.dart';

class ReportingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportingController>(() => ReportingController(), fenix: true);
  }
}
