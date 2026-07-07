import 'package:get/get.dart';
import 'package:modfirstpos/modules/forgotPassword/service/forgot_password_service.dart';
import 'package:modfirstpos/modules/forgotPassword/controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
    Get.lazyPut<ForgotPasswordService>(() => ForgotPasswordService());
  }
}