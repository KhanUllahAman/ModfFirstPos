import 'package:get/get.dart';
import 'package:modfirstpos/modules/about/controller/about_controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutController>(() => AboutController());
  }
}