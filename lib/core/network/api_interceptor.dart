import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:modfirstpos/core/network/token_refresh_manager.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log('REQUEST[${options.method}] => PATH: ${options.path}');
      log('HEADERS: ${options.headers}');
      log('BODY: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      // log('DATA: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      log('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      log('MESSAGE: ${err.message}');
      log('DATA: ${err.response?.data}');
    }

    final statusCode = err.response?.statusCode;
    final isRefreshCall =
        err.requestOptions.path.contains('auth/refresh-token');
    final alreadyRetried = err.requestOptions.extra['retriedAfterRefresh'] == true;

    if ((statusCode == 401 || statusCode == 403) &&
        !isRefreshCall &&
        !alreadyRetried) {
      final newToken = await TokenRefreshManager.instance.refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        try {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          options.extra['retriedAfterRefresh'] = true;
          final retryResponse = await Dio().fetch(options);
          return handler.resolve(retryResponse);
        } catch (e) {
          log('ApiInterceptor retry-after-refresh failed: $e');
        }
      }
      // No refresh token available or the refresh call failed — fall
      // through and let the original 403 surface normally.
    }

    super.onError(err, handler);
  }
}
