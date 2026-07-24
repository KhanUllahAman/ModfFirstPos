import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
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
}
