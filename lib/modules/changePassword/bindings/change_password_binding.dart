import 'package:get/get.dart';
import 'package:modfirstpos/modules/changePassword/controller/change_password_controller.dart';
import 'package:modfirstpos/modules/changePassword/service/change_password_service.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordService>(() => ChangePasswordService());
    Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
  }
}