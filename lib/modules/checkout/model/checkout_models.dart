import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

/// Saved customer address (shipping / billing).
class AddressModel {
  final int id;
  final int? userId;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool isDefault;
  final String? type;
  final bool isActive;

  AddressModel({
    required this.id,
    this.userId,
    this.fullName,
    this.phone,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isDefault = false,
    this.type,
    this.isActive = true,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: JsonUtils.asInt(json['id']),
      userId: JsonUtils.asIntOrNull(json['user_id']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
      addressLine1: JsonUtils.asStringOrNull(json['address_line1']),
      addressLine2: JsonUtils.asStringOrNull(json['address_line2']),
      city: JsonUtils.asStringOrNull(json['city']),
      state: JsonUtils.asStringOrNull(json['state']),
      postalCode: JsonUtils.asStringOrNull(json['postal_code']),
      country: JsonUtils.asStringOrNull(json['country']),
      isDefault: JsonUtils.asBool(json['is_default']),
      type: JsonUtils.asStringOrNull(json['type']),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
    );
  }

  String get summaryLine {
    final parts = [addressLine1, addressLine2, city, state, postalCode, country]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

class AddressListResponse {
  final bool isSuccess;
  final String message;
  final List<AddressModel> payload;
  final PaginationModel pagination;

  AddressListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory AddressListResponse.fromJson(Map<String, dynamic> json) {
    return AddressListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], AddressModel.fromJson),
      pagination: PaginationModel.fromJson(
        JsonUtils.asMapOrNull(json['pagination']),
      ),
    );
  }
}

/// New address typed by the cashier; sent inline in the create-order body.
class NewAddressInput {
  final String fullName;
  final String phone;
  final String? email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;

  NewAddressInput({
    required this.fullName,
    required this.phone,
    this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        'address_line1': addressLine1,
        if (addressLine2 != null && addressLine2!.isNotEmpty)
          'address_line2': addressLine2,
        'city': city,
        if (state != null && state!.isNotEmpty) 'state': state,
        if (postalCode != null && postalCode!.isNotEmpty)
          'postal_code': postalCode,
        if (country != null && country!.isNotEmpty) 'country': country,
      };

  String get summaryLine =>
      [addressLine1, city, state, postalCode, country]
          .where((p) => p != null && p.trim().isNotEmpty)
          .join(', ');
}

class PickupLocationModel {
  final int id;
  final String? name;
  final String? address;
  final String? city;
  final String? phone;
  final bool isActive;

  PickupLocationModel({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.phone,
    this.isActive = true,
  });

  factory PickupLocationModel.fromJson(Map<String, dynamic> json) {
    return PickupLocationModel(
      id: JsonUtils.asInt(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      address: JsonUtils.asStringOrNull(json['address']),
      city: JsonUtils.asStringOrNull(json['city']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
    );
  }

  String get displayName => name ?? 'Pickup Location #$id';
}

class PickupLocationListResponse {
  final bool isSuccess;
  final String message;
  final List<PickupLocationModel> payload;

  PickupLocationListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
  });

  factory PickupLocationListResponse.fromJson(Map<String, dynamic> json) {
    return PickupLocationListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(
        json['payload'],
        PickupLocationModel.fromJson,
      ),
    );
  }
}

/// Minimal view of the order returned by orders/create.
class CreatedOrder {
  final int id;
  final String? orderNumber;
  final double totalAmount;
  final double subtotal;
  final double taxAmount;
  final double shippingFee;
  final double discountAmount;

  CreatedOrder({
    required this.id,
    this.orderNumber,
    required this.totalAmount,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.shippingFee = 0,
    this.discountAmount = 0,
  });

  factory CreatedOrder.fromJson(Map<String, dynamic> json) {
    return CreatedOrder(
      id: JsonUtils.asInt(json['id']),
      orderNumber: JsonUtils.asStringOrNull(json['order_number']),
      totalAmount: JsonUtils.asDouble(json['total_amount']),
      subtotal: JsonUtils.asDouble(json['subtotal']),
      taxAmount: JsonUtils.asDouble(json['tax_amount']),
      shippingFee: JsonUtils.asDouble(json['shipping_fee']),
      discountAmount: JsonUtils.asDouble(json['discount_amount']),
    );
  }
}

class CreateOrderResponse {
  final bool isSuccess;
  final String message;
  final CreatedOrder? order;

  CreateOrderResponse({
    required this.isSuccess,
    required this.message,
    this.order,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return CreateOrderResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      order: payload != null ? CreatedOrder.fromJson(payload) : null,
    );
  }
}

class CheckoutSessionResponse {
  final bool isSuccess;
  final String message;
  final String? sessionUrl;
  final String? paymentReference;

  CheckoutSessionResponse({
    required this.isSuccess,
    required this.message,
    this.sessionUrl,
    this.paymentReference,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMap(json['payload']);
    return CheckoutSessionResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      sessionUrl: JsonUtils.asStringOrNull(payload['session_url']),
      paymentReference: JsonUtils.asStringOrNull(payload['payment_reference']),
    );
  }
}

class CouponValidationResponse {
  final bool isSuccess;
  final String message;
  final int? couponId;
  final String? code;
  final String? type;
  final double discount;
  final double finalAmount;

  CouponValidationResponse({
    required this.isSuccess,
    required this.message,
    this.couponId,
    this.code,
    this.type,
    this.discount = 0,
    this.finalAmount = 0,
  });

  factory CouponValidationResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMap(json['payload']);
    return CouponValidationResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      couponId: JsonUtils.asIntOrNull(payload['coupon_id']),
      code: JsonUtils.asStringOrNull(payload['code']),
      type: JsonUtils.asStringOrNull(payload['type']),
      discount: JsonUtils.asDouble(payload['discount']),
      finalAmount: JsonUtils.asDouble(payload['final_amount']),
    );
  }
}
