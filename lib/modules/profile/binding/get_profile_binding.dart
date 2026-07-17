import 'package:get/get.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';

class GetProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetProfileService>(() => GetProfileService(), fenix: true);
    Get.lazyPut<GetProfileController>(() => GetProfileController(), fenix: true);
  }
}