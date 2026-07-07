import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';
import 'app_exceptions.dart';
import 'dart:io';

class ExceptionHandler {
  static AppException handleError(dynamic error, {bool showSnackbar = true}) {
    AppException exception;

    if (error is AppException) {
      if (showSnackbar) {
        _showErrorSnackbar(error);
      }
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          exception = TimeoutException('Request Timeout. Please try again.');
          break;

        case DioExceptionType.badResponse:
          exception = _handleStatusCode(
            error.response?.statusCode,
            error.response?.data,
          );
          break;

        case DioExceptionType.cancel:
          exception = FetchDataException('Request was cancelled');
          break;

        case DioExceptionType.connectionError:
          exception = NoInternetException('No internet connection');
          break;

        default:
          exception = FetchDataException('Unexpected error occurred');
      }
    } else if (error is SocketException) {
      exception = NoInternetException('No internet connection');
    } else if (error is TimeoutException) {
      exception = TimeoutException('Request timeout');
    } else {
      exception = FetchDataException('Something went wrong');
    }

    if (showSnackbar) {
      _showErrorSnackbar(exception);
    }

    return exception;
  }

  static AppException _handleStatusCode(int? statusCode, dynamic responseData) {
    String message = _extractMessage(responseData);

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return BadRequestException(message);
      case 500:
      case 502:
      case 503:
        return InternalServerException(message);
      default:
        return FetchDataException(message);
    }
  }

  static String _extractMessage(dynamic responseData) {
    if (responseData is Map) {
      return responseData['message'] ??
          responseData['error'] ??
          responseData['msg'] ??
          'An error occurred';
    }
    return 'An error occurred';
  }

  static void _showErrorSnackbar(AppException exception) {
    if (exception is BadRequestException) {
      customSnackBar(
        "Error",
        exception.message,
        snackBarType: SnackBarType.error,
      );
    } else if (exception is UnauthorizedException) {
      customSnackBar(
        "Unauthorized",
        exception.message,
        snackBarType: SnackBarType.error,
      );
    } else if (exception.statusCode == 404) {
      Get.toNamed(Routes.error404Route);
    } else if (exception is NoInternetException) {
      customSnackBar(
        "No Internet",
        exception.message,
        snackBarType: SnackBarType.error,
      );
    } else if (exception is InternalServerException) {
      customSnackBar(
        "Server Error",
        exception.message,
        snackBarType: SnackBarType.error,
      );
    } else {
      customSnackBar(
        "Error",
        exception.message,
        snackBarType: SnackBarType.error,
      );
    }
  }
}
