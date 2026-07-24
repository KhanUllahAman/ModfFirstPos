import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/storeSelection/model/store_selection_model.dart';

class StoreSelectionService {
  final NetworkClient _networkClient = Get.find();

  Future<SaleSelectionModel> storeSelectionApi() async {
    try {
      final response = await _networkClient.get(
        endpoint: ApiConstants.storeSelectionListEndPoint,
        showErrorSnackbar: false,
      );
      log("Store Selection response: ${response.data}");
      return SaleSelectionModel.fromJson(response.data);
    } catch (e) {
      log("Store Selection  error: $e");
      rethrow;
    }
  }
}