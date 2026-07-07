import 'package:modfirstpos/core/network/app_config_apikey.dart';

class ApiConstants {
  static final String baseUrl = AppConfig.apiKey;  
  static final String loginEndpoint = '${baseUrl}auth/login';
  static final String sendOtpEndpoint = '${baseUrl}auth/send-otp';
  static final String verifyOtpEndpoint = '${baseUrl}auth/verify-otp';
  static final String forgotPasswordEndpoint = '${baseUrl}auth/forgot-password';
  static final String getProfileEndpoint = '${baseUrl}auth/profile';
}
