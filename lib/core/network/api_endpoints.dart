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
  static final String pinStatusEndpoint = '${baseUrl}users/pin/status';
  static final String pinSetEndpoint = '${baseUrl}users/pin/set';
  static final String pinVerifyEndpoint = '${baseUrl}users/pin/verify';
  static final String pinChangeEndpoint = '${baseUrl}users/pin/change';
  static final String pinDisableEndpoint = '${baseUrl}users/pin';
  static final String pinAutoLockEndpoint = '${baseUrl}users/pin/auto-lock';
  static final String websiteSettingsEndpoint = '${baseUrl}website-settings/list';
}
