// pin_settings_binding.dart
import 'package:get/get.dart';
import 'package:modfirstpos/modules/pin/controller/pin_settings_controller.dart';

class PinSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinSettingsController>(() => PinSettingsController());
  }
}