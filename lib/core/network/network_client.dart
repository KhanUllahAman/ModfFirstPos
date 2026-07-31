import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/api_interceptor.dart';
import 'package:modfirstpos/core/network/app_config_apikey.dart';
import 'package:modfirstpos/core/network/cert_pinning.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import '../exceptions/app_exceptions.dart';
import '../exceptions/exception_handler.dart';

/// Debug-only logging — never prints in release/profile builds, so tokens
/// and API keys can't end up in a shipped app's logcat.
void _log(String message) {
  if (kDebugMode) log(message);
}

/// Headers containing credentials, with secrets masked — safe to log even
/// in debug (screenshots/screen recordings/log aggregators can still leak
/// a full token otherwise).
Map<String, dynamic> _redactedHeaders(Map<String, dynamic> headers) {
  const sensitiveKeys = {'authorization', 'x-api-key', 'x-api-password'};
  return headers.map((key, value) {
    if (sensitiveKeys.contains(key.toLowerCase()) && value is String && value.isNotEmpty) {
      final visible = value.length > 10 ? value.substring(0, 10) : value;
      return MapEntry(key, '$visible...(redacted)');
    }
    return MapEntry(key, value);
  });
}

class NetworkClient {
  late Dio _dio;
  final ConnectivityService _connectivityService = Get.find();

  NetworkClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());

    // Certificate pinning: reject any connection to our API host whose
    // certificate's public key isn't in the pinned set, even if the OS
    // trust store considers it valid (defends against a rogue/compelled CA
    // or a MITM proxy with an installed trusted root). See cert_pinning.dart
    // for the pinned values and how to update them when the cert rotates.
    (_dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate =
        (cert, host, port) {
      if (cert == null) return false;
      return validatePinnedCertificate(cert, host, port);
    };
  }

  Future<Response> postFormData({
    required String endpoint,
    required FormData formData,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final builtHeaders = await _buildHeaders(headers);
      builtHeaders['Content-Type'] =
          'multipart/form-data; boundary=${formData.boundary}';
      final options = Options(headers: builtHeaders);
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: options,
      );
      _log("POST FormData Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("POST FormData Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Response> post({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    bool isLoginRequest = false,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(
        headers: await _buildHeaders(headers, isLoginRequest: isLoginRequest),
      );
      final response = await _dio.post(endpoint, data: body, options: options);
      _log("POST Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("POST Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Response> patch({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(headers: await _buildHeaders(headers));
      final response = await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );
      _log("PATCH Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("PATCH Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(headers: await _buildHeaders(headers));
      final response = await _dio.get(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );
      _log("GET Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("GET Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Response> put({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(headers: await _buildHeaders(headers));
      final response = await _dio.put(endpoint, data: body, options: options);
      _log("PUT Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("PUT Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  /// Use for endpoints that return raw binary data (e.g. exported files)
  /// instead of JSON.
  Future<Response<List<int>>> postBytes({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(
        headers: await _buildHeaders(headers),
        responseType: ResponseType.bytes,
      );
      final response = await _dio.post<List<int>>(
        endpoint,
        data: body,
        options: options,
      );
      _log("POST Bytes Response [$endpoint]: ${response.statusCode}");
      return response;
    } catch (e) {
      _log("POST Bytes Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Response> delete({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    bool showErrorSnackbar = true,
  }) async {
    try {
      if (!_connectivityService.isConnected) throw NoInternetException();
      final options = Options(headers: await _buildHeaders(headers));
      final response = await _dio.delete(
        endpoint,
        data: body,
        options: options,
      );
      _log("DELETE Response [$endpoint]: $response");
      return response;
    } catch (e) {
      _log("DELETE Error [$endpoint]: $e");
      throw ExceptionHandler.handleError(e, showSnackbar: showErrorSnackbar);
    }
  }

  Future<Map<String, dynamic>> _buildHeaders(
    Map<String, dynamic>? customHeaders, {
    bool isLoginRequest = false,
  }) async {
    final headers = <String, dynamic>{
      'x-api-key': AppConfig.xApiKey,
      'x-api-password': AppConfig.xApiPassword,
    };

    if (!isLoginRequest) {
      final token = await SecureStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    _log("Built headers: ${_redactedHeaders(headers)}");
    return headers;
  }
}
