import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/models/website_settings_model.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/services/website_settings_storage_service.dart';

class WebsiteSettingsService {
  final NetworkClient _client = NetworkClient();

  Future<WebsiteSettingsResponse> fetchAndSaveWebsiteSettings() async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.websiteSettingsEndpoint,
        body: {
          "filters": {
            "site_name": ["ModFirst"],
          },
        },
        showErrorSnackbar: false,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      final parsed = WebsiteSettingsResponse.fromJson(data);
      if (parsed.isSuccess && parsed.payload.isNotEmpty) {
        await WebsiteSettingsStorageService.saveFromModel(parsed.payload.first);
      }

      return parsed;
    } catch (e) {
      log("WebsiteSettingsService fetchAndSaveWebsiteSettings error: $e");
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
