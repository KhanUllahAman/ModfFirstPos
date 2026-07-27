import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';

class BootstrapService {
  final NetworkClient _client = NetworkClient();


  Future<(BootstrapResponse, Map<String, dynamic>?)> fetchBootstrap() async {
    try {
      final response = await _client.get(
        endpoint: ApiConstants.posBootstrapEndpoint,
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      final parsed = BootstrapResponse.fromJson(data);
      final rawPayload = data['payload'] is Map<String, dynamic>
          ? data['payload'] as Map<String, dynamic>
          : null;
      return (parsed, rawPayload);
    } catch (e) {
      log("BootstrapService fetchBootstrap error: $e");
      return (
        BootstrapResponse(isSuccess: false, message: e.toString()),
        null,
      );
    }
  }
}
