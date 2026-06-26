import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      log('MESSAGE: ${err.message}');
      log('DATA: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}