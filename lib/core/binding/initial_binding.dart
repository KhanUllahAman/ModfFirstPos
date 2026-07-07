import 'package:get/get.dart';
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/network_client.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ConnectivityService>(
      ConnectivityService(),
      permanent: true,
    );

    Get.put<NetworkClient>(
      NetworkClient(),
      permanent: true,
    );
  }
}