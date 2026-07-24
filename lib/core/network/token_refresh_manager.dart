import 'dart:async';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';

/// Coordinates auth/refresh-token calls so concurrent 403s from multiple
/// in-flight requests trigger exactly one refresh, with every caller
/// awaiting the same result instead of racing separate refresh calls.
class TokenRefreshManager {
  TokenRefreshManager._();
  static final TokenRefreshManager instance = TokenRefreshManager._();

  Completer<String?>? _inFlightRefresh;

  /// Returns the new access token on success, or null if it couldn't be
  /// refreshed (no stored refresh token, or the call failed) — the caller
  /// just lets the original request's error surface as usual in that case.
  Future<String?> refreshAccessToken() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing.future;

    final completer = Completer<String?>();
    _inFlightRefresh = completer;

    _performRefresh().then((token) {
      completer.complete(token);
    }).catchError((e) {
      log('TokenRefreshManager refresh error: $e');
      completer.complete(null);
    }).whenComplete(() {
      _inFlightRefresh = null;
    });

    return completer.future;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      log('TokenRefreshManager: no refresh token stored, cannot refresh');
      return null;
    }

    try {
      final response = await NetworkClient().patch(
        endpoint: ApiConstants.refreshTokenEndpoint,
        body: {'refreshToken': refreshToken},
        showErrorSnackbar: false,
      );

      final data = response.data;
      final success = data is Map && data['success'] == true;
      final tokens = success && data['payload'] is Map
          ? (data['payload'] as Map)['tokens']
          : null;

      if (tokens is Map) {
        final newAccessToken = tokens['accessToken']?.toString();
        final newRefreshToken = tokens['refreshToken']?.toString();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await SecureStorageService.saveAccessToken(newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await SecureStorageService.saveRefreshToken(newRefreshToken);
          }
          return newAccessToken;
        }
      }

      log('TokenRefreshManager: refresh response missing tokens');
      return null;
    } catch (e) {
      log('TokenRefreshManager refresh call failed: $e');
      return null;
    }
  }
}
