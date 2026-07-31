import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart' show Response;
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';

class CheckoutService {
  final NetworkClient _client = NetworkClient();

  Future<AddressListResponse> fetchAddresses({
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final body = {
        'page': page,
        'limit': limit,
        'filters': {'user_id': userId, 'is_active': true, 'is_deleted': false},
      };
      final response = await _client.post(
        endpoint: ApiConstants.addressListEndpoint,
        body: body,
        showErrorSnackbar: true,
      );
      log("Address Body $body");
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      return AddressListResponse.fromJson(data);
    } catch (e) {
      log("CheckoutService fetchAddresses error: $e");
      return AddressListResponse(
        isSuccess: false,
        message: e.toString(),
        payload: [],
        pagination: AddressListResponse.fromJson({}).pagination,
      );
    }
  }

  Future<CouponValidationResponse> validateCoupon({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final body = {'code': code.trim(), 'order_amount': orderAmount};

      final response = await _client.post(
        endpoint: ApiConstants.couponValidateEndpoint,
        body: body,
        showErrorSnackbar: false,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      return CouponValidationResponse.fromJson(data);
    } catch (e) {
      log("CheckoutService validateCoupon error: $e");
      return CouponValidationResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<CreateOrderResponse> createOrder({
    required int userId,
    required String email,
    required String phone,
    required String fullName,
    required String deliveryType,
    int? shippingAddressId,
    int? billingAddressId,
    NewAddressInput? shippingAddress,
    int? pickupLocationId,
    required List<Map<String, dynamic>> items,
    String? notes,
    Map<String, dynamic>? manualDiscount,
  }) async {
    try {
      final body = <String, dynamic>{
        'user_id': userId,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'delivery_type': deliveryType,
        'items': items,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (manualDiscount != null) 'manual_discount': manualDiscount,
      };
      if (shippingAddressId != null) {
        body['shipping_address_id'] = shippingAddressId;
        body['billing_address_id'] = billingAddressId ?? shippingAddressId;
      } else if (shippingAddress != null) {
        body['shipping_address'] = shippingAddress.toJson();
      }
      if (deliveryType == 'store_pickup' && pickupLocationId != null) {
        body['pickup_location_id'] = pickupLocationId;
      }

      final response = await _client.post(
        endpoint: ApiConstants.orderCreateEndpoint,
        body: body,
        showErrorSnackbar: true,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      return CreateOrderResponse.fromJson(data);
    } catch (e) {
      log("CheckoutService createOrder error: $e");
      return CreateOrderResponse(
        isSuccess: false,
        message: e.toString(),
        order: null,
      );
    }
  }

  Future<CheckoutSessionResponse> checkoutOrder({
    required int orderId,
    required String paymentMethod,
    double? onlineAmount,
    double? cashAmount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = <String, dynamic>{
        'order_id': orderId,
        'payment_method': paymentMethod,
        if (onlineAmount != null) 'online_amount': onlineAmount,
        if (cashAmount != null) 'cash_amount': cashAmount,
        'metadata': {'source': 'pos_cashier', ...?metadata},
      };

      final response = await _client.post(
        endpoint: ApiConstants.checkoutEndpoint,
        body: body,
        showErrorSnackbar: true,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      return CheckoutSessionResponse.fromJson(data);
    } catch (e) {
      log("CheckoutService checkoutOrder error: $e");
      return CheckoutSessionResponse(
        isSuccess: false,
        message: e.toString(),
        sessionUrl: null,
        paymentReference: null,
      );
    }
  }

  // --------------------------------------------------------------------
  // POS payments — one endpoint for cash / bank transfer / Stripe Terminal
  // (card-present) + splits. See docs/POS_PAYMENT_FLUTTER.md.
  // --------------------------------------------------------------------

  Map<String, dynamic> _asMap(Response response) {
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : jsonDecode(response.data?.toString() ?? '{}') as Map<String, dynamic>;
  }

  Future<PosPaymentResponse> payPos({
    required String orderCode,
    required String paymentType,
    double? cashAmount,
    double? bankAmount,
    String? bankReference,
    double? terminalAmount,
    int? readerId,
  }) async {
    try {
      final body = <String, dynamic>{
        'order_code': orderCode,
        'payment_type': paymentType,
        if (cashAmount != null) 'cash_amount': cashAmount,
        if (bankAmount != null) 'bank_amount': bankAmount,
        if (bankReference != null && bankReference.isNotEmpty)
          'bank_reference': bankReference,
        if (terminalAmount != null) 'terminal_amount': terminalAmount,
        if (readerId != null) 'reader_id': readerId,
      };

      final response = await _client.post(
        endpoint: ApiConstants.posPaymentPayEndpoint,
        body: body,
        showErrorSnackbar: true,
      );

      return PosPaymentResponse.fromJson(_asMap(response));
    } catch (e) {
      log("CheckoutService payPos error: $e");
      return PosPaymentResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<TerminalPaymentStatusResponse> pollTerminalPaymentStatus(
    String paymentReference,
  ) async {
    try {
      final response = await _client.get(
        endpoint: ApiConstants.terminalPaymentStatusEndpoint(paymentReference),
        showErrorSnackbar: false,
      );
      return TerminalPaymentStatusResponse.fromJson(_asMap(response));
    } catch (e) {
      log("CheckoutService pollTerminalPaymentStatus error: $e");
      return TerminalPaymentStatusResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<TerminalCaptureResponse> captureTerminalPayment(
    String paymentReference,
  ) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.terminalCaptureEndpoint,
        body: {'payment_reference': paymentReference},
        showErrorSnackbar: true,
      );
      return TerminalCaptureResponse.fromJson(_asMap(response));
    } catch (e) {
      log("CheckoutService captureTerminalPayment error: $e");
      return TerminalCaptureResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<bool> cancelTerminalAction(int readerId) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.terminalCancelActionEndpoint,
        body: {'reader_id': readerId},
        showErrorSnackbar: false,
      );
      return JsonUtils.asBool(_asMap(response)['success']);
    } catch (e) {
      log("CheckoutService cancelTerminalAction error: $e");
      return false;
    }
  }

  Future<String?> fetchTerminalConnectionToken() async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.terminalConnectionTokenEndpoint,
        body: const {},
        showErrorSnackbar: true,
      );
      final data = _asMap(response);
      final payload = JsonUtils.asMap(data['payload']);
      return JsonUtils.asStringOrNull(payload['secret']);
    } catch (e) {
      log("CheckoutService fetchTerminalConnectionToken error: $e");
      return null;
    }
  }
}
