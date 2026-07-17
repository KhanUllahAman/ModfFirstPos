import 'package:get/get.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}
