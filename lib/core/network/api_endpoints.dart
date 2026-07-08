import 'package:modfirstpos/core/network/app_config_apikey.dart';

class ApiConstants {
  static final String baseUrl = AppConfig.apiKey;  
  static final String loginEndpoint = '${baseUrl}auth/login';
  static final String sendOtpEndpoint = '${baseUrl}auth/send-otp';
  static final String verifyOtpEndpoint = '${baseUrl}auth/verify-otp';
  static final String forgotPasswordEndpoint = '${baseUrl}auth/forgot-password';
  static final String getProfileEndpoint = '${baseUrl}auth/profile';
  static final String uploadImageEndpoint = '${baseUrl}upload/image?folder=user';
  static final String changePasswordEndpoint = '${baseUrl}auth/change-password';
  static const String pinStatusEndpoint = '/users/pin/status';
  static const String pinSetEndpoint = '/users/pin/set';
  static const String pinVerifyEndpoint = '/users/pin/verify';
  static const String pinChangeEndpoint = '/users/pin/change';
  static const String pinDisableEndpoint = '/users/pin';
  static const String pinAutoLockEndpoint = '/users/pin/auto-lock';
}
