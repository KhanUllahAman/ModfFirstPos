import 'package:get/get.dart';
import 'package:modfirstpos/core/services/website_settings_service.dart';
import 'package:modfirstpos/modules/auth/service/send_otp_service.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';
import 'package:modfirstpos/modules/verifyOtp/service/verify_otp_service.dart';
import 'package:modfirstpos/modules/verifyOtp/controller/verify_otp_controller.dart';

class VerifyOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    Get.lazyPut<VerifyOtpService>(() => VerifyOtpService());
    Get.lazyPut<SendOtpService>(() => SendOtpService());
    Get.lazyPut<GetProfileService>(() => GetProfileService());
    Get.lazyPut<WebsiteSettingsService>(() => WebsiteSettingsService());
  }
}