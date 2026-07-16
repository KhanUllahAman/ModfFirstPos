import 'package:get/get.dart';
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/modules/pin/service/pin_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);

    Get.put<NetworkClient>(NetworkClient(), permanent: true);

    Get.put<SyncService>(SyncService(), permanent: true);

    Get.put<PinService>(PinService(), permanent: true);
    Get.put<PinController>(PinController(), permanent: true);
  }
}
