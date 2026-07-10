import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:modfirstpos/core/connectivity/connectivity_service.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/api_interceptor.dart';
import 'package:modfirstpos/core/network/app_config_apikey.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import '../exceptions/app_exceptions.dart';
import '../exceptions/exception_handler.dart';

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
      log("POST FormData Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("POST FormData Error [$endpoint]: $e");
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
      log("POST Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("POST Error [$endpoint]: $e");
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
      log("PATCH Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("PATCH Error [$endpoint]: $e");
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
      log("GET Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("GET Error [$endpoint]: $e");
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
      log("PUT Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("PUT Error [$endpoint]: $e");
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
      log("DELETE Response [$endpoint]: $response");
      return response;
    } catch (e) {
      log("DELETE Error [$endpoint]: $e");
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

    log("Built headers: $headers");
    return headers;
  }
}
