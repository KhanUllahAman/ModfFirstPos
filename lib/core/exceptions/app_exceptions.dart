class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException({
    required this.message,
    this.prefix,
    this.statusCode,
  });

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(
          message: message ?? 'Error During Communication',
          prefix: 'Error During Communication: ',
        );
}

class BadRequestException extends AppException {
  BadRequestException([String? message])
      : super(
          message: message ?? 'Invalid Request',
          prefix: 'Invalid Request: ',
          statusCode: 400,
        );
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message])
      : super(
          message: message ?? 'Unauthorized',
          prefix: 'Unauthorized: ',
          statusCode: 401,
        );
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(
          message: message ?? 'Not Found',
          prefix: 'Not Found: ',
          statusCode: 404,
        );
}

class InternalServerException extends AppException {
  InternalServerException([String? message])
      : super(
          message: message ?? 'Internal Server Error',
          prefix: 'Internal Server Error: ',
          statusCode: 500,
        );
}

class NoInternetException extends AppException {
  NoInternetException([String? message])
      : super(
          message: message ?? 'No Internet Connection',
          prefix: 'No Internet: ',
        );
}

class TimeoutException extends AppException {
  TimeoutException([String? message])
      : super(
          message: message ?? 'Request Timeout',
          prefix: 'Timeout: ',
        );
}