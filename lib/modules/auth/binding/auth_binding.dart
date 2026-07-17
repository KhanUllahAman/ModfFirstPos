import 'package:get/get.dart';
import 'package:modfirstpos/modules/auth/controller/auth_controller.dart';
import 'package:modfirstpos/modules/auth/service/auth_service.dart';
import 'package:modfirstpos/modules/auth/service/send_otp_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<SendOtpService>(() => SendOtpService(), fenix: true);
  }
}