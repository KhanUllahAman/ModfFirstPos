import 'package:modfirstpos/core/network/app_config_apikey.dart';

class ApiConstants {
  static final String baseUrl = AppConfig.apiKey;  
  static final String xApiKey = AppConfig.xApiKey;  
  static final String xApiPassword = AppConfig.xApiPassword;  
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
  static final String categoryListEndpoint = '${baseUrl}product-categories/list'; 
  static final String productListEndpoint = '${baseUrl}products/list';   
  static final String orderListEndpoint = '${baseUrl}orders/list';
  static final String userListEndpoint = '${baseUrl}users/list';
  static final String userCreateEndpoint = '${baseUrl}users/create';
  static final String orderCreateEndpoint = '${baseUrl}orders/create';
  static String websiteSettingsEndpoint(String storeName) => '${baseUrl}website-settings/frontend/$storeName';
}
