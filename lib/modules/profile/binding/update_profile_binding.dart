import 'package:get/get.dart';
import 'package:modfirstpos/modules/profile/controller/update_profile_controller.dart';
import 'package:modfirstpos/modules/profile/service/get_profile_service.dart';

class UpdateProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetProfileService>(() => GetProfileService());
    Get.lazyPut<UpdateProfileController>(() => UpdateProfileController());
  }
}