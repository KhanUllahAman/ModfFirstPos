import 'package:get/get.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';

class GetProfileViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetProfileService>(() => GetProfileService());
    Get.lazyPut<GetProfileController>(() => GetProfileController());
  }
}