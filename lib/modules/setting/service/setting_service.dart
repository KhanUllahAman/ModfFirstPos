import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';

class SettingService {
  final NetworkClient _client = NetworkClient();

  Future<PosDeviceListResponse> getMyBranchDevices() async {
    try {
      final response = await _client.get(
        endpoint: ApiConstants.posDeviceMyBranchEndpoint,
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      return PosDeviceListResponse.fromJson(data);
    } catch (e) {
      log("SettingService getMyBranchDevices error: $e");
      return PosDeviceListResponse(
        isSuccess: false,
        message: e.toString(),
        payload: const [],
      );
    }
  }

  Future<PosDeviceResponse> updateDevice({
    required int id,
    required PosDeviceModel device,
  }) async {
    try {
      final response = await _client.put(
        endpoint: ApiConstants.posDeviceUpdateEndpoint(id),
        body: device.toJson(),
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      return PosDeviceResponse.fromJson(data);
    } catch (e) {
      log("SettingService updateDevice error: $e");
      return PosDeviceResponse(isSuccess: false, message: e.toString());
    }
  }
}
