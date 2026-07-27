import 'package:modfirstpos/core/network/app_config_apikey.dart';

class ApiConstants {
  static final String baseUrl = AppConfig.apiKey;  
  static final String xApiKey = AppConfig.xApiKey;  
  static final String xApiPassword = AppConfig.xApiPassword;  
  static final String loginEndpoint = '${baseUrl}auth/login';
  static final String sendOtpEndpoint = '${baseUrl}auth/send-otp';
  static final String verifyOtpEndpoint = '${baseUrl}auth/verify-otp';
  static final String refreshTokenEndpoint = '${baseUrl}auth/refresh-token';
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
  static final String userCreateEndpoint = '${baseUrl}users';
  static final String orderCreateEndpoint = '${baseUrl}orders';
  static final String addressListEndpoint = '${baseUrl}addresses/admin/list';
  static final String pickupLocationListEndpoint =
      '${baseUrl}pickup-locations/list';
  static final String storeSelectionListEndPoint =
      '${baseUrl}website-settings/public';
  static final String checkoutEndpoint = '${baseUrl}payments/checkout-session';
  static final String couponValidateEndpoint = '${baseUrl}coupons/validate';
  static String websiteSettingsEndpoint(String storeName) => '${baseUrl}website-settings/frontend/$storeName';
  static final String posDeviceMyBranchEndpoint = '${baseUrl}pos-device/my-branch';
  static String posDeviceUpdateEndpoint(int id) => '${baseUrl}pos-device/$id';
  static final String printReceiptEndpoint = '${baseUrl}orders/print-receipt';
  static final String posShiftOpenEndpoint = '${baseUrl}pos-shifts/open';
  static final String posShiftCurrentEndpoint = '${baseUrl}pos-shifts/current';
  static String posShiftStatusEndpoint(int id) => '${baseUrl}pos-shifts/$id/status';
  static String posShiftCloseEndpoint(int id) => '${baseUrl}pos-shifts/$id/close';
  static String posShiftPrintReceiptEndpoint(int id) =>
      '${baseUrl}pos-shifts/$id/print-receipt';
  static final String posBootstrapEndpoint = '${baseUrl}pos/bootstrap';
  static final String inventoryIncreaseEndpoint = '${baseUrl}inventory/increase';
  static final String inventoryDecreaseEndpoint = '${baseUrl}inventory/decrease';
  static final String inventoryAdjustEndpoint = '${baseUrl}inventory/adjust';
  static final String orderCommentCreateEndpoint = '${baseUrl}order-comments';
  static String orderCommentsByOrderEndpoint(int orderId) =>
      '${baseUrl}order-comments/order/$orderId';
  static final String orderCommentListEndpoint = '${baseUrl}order-comments/list';
  static final String reportsDurationExcelEndpoint = '${baseUrl}reports/duration/excel';
  static final String posShiftSyncEndpoint = '${baseUrl}pos-shifts/sync';
  static final String orderPosSyncEndpoint = '${baseUrl}orders/pos/sync';

  // -- POS payments (cash / bank transfer / Stripe Terminal card-present) --
  static final String posPaymentPayEndpoint = '${baseUrl}payments/pos/pay';
  static final String terminalConnectionTokenEndpoint =
      '${baseUrl}terminal/connection-token';
  static String terminalPaymentStatusEndpoint(String paymentReference) =>
      '${baseUrl}terminal/payment-status/$paymentReference';
  static final String terminalCaptureEndpoint = '${baseUrl}terminal/capture';
  static final String terminalCancelActionEndpoint =
      '${baseUrl}terminal/cancel-action';
}
