import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

class OrderModel {
  final int? id;
  final String? orderNumber;
  final int? userId;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? status;
  final String? paymentStatus;
  final String? deliveryType;
  final String? shippingStatus;
  final String? channel;
  final int? shippingAddressId;
  final int? billingAddressId;
  final int? couponId;
  final int? pickupLocationId;
  final String? subtotal;
  final String? shippingFee;
  final String? discountAmount;
  final String? taxAmount;
  final String? paidAmount;
  final String? totalAmount;
  final String? discountSource;
  final String? onlineAmount;
  final String? cashAmount;
  final String? notes;
  final String? serviceCode;
  final String? orderDate;
  final String? estimatedDeliveryDate;
  final String? cancelledAt;
  final bool? isActive;
  final bool? isDeleted;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final List<OrderItemModel> items;
  final List<dynamic> shipments;
  final Map<String, dynamic>? pickupLoc;
  final List<OrderPaymentLogModel> paymentLogs;

  OrderModel({
    this.id,
    this.orderNumber,
    this.userId,
    this.email,
    this.phone,
    this.fullName,
    this.status,
    this.paymentStatus,
    this.deliveryType,
    this.shippingStatus,
    this.channel,
    this.shippingAddressId,
    this.billingAddressId,
    this.couponId,
    this.pickupLocationId,
    this.subtotal,
    this.shippingFee,
    this.discountAmount,
    this.taxAmount,
    this.paidAmount,
    this.totalAmount,
    this.discountSource,
    this.onlineAmount,
    this.cashAmount,
    this.notes,
    this.serviceCode,
    this.orderDate,
    this.estimatedDeliveryDate,
    this.cancelledAt,
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.items = const [],
    this.shipments = const [],
    this.pickupLoc,
    this.paymentLogs = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: JsonUtils.asIntOrNull(json['id']),
      orderNumber: JsonUtils.asStringOrNull(json['order_number']),
      userId: JsonUtils.asIntOrNull(json['user_id']),
      email: JsonUtils.asStringOrNull(json['email']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      status: JsonUtils.asStringOrNull(json['status']),
      paymentStatus: JsonUtils.asStringOrNull(json['payment_status']),
      deliveryType: JsonUtils.asStringOrNull(json['delivery_type']),
      shippingStatus: JsonUtils.asStringOrNull(json['shipping_status']),
      channel: JsonUtils.asStringOrNull(json['channel']),
      shippingAddressId: JsonUtils.asIntOrNull(json['shipping_address_id']),
      billingAddressId: JsonUtils.asIntOrNull(json['billing_address_id']),
      couponId: JsonUtils.asIntOrNull(json['coupon_id']),
      pickupLocationId: JsonUtils.asIntOrNull(json['pickup_location_id']),
      subtotal: json['subtotal']?.toString(),
      shippingFee: json['shipping_fee']?.toString(),
      discountAmount: json['discount_amount']?.toString(),
      taxAmount: json['tax_amount']?.toString(),
      paidAmount: json['paid_amount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      discountSource: JsonUtils.asStringOrNull(json['discount_source']),
      onlineAmount: json['online_amount']?.toString(),
      cashAmount: json['cash_amount']?.toString(),
      notes: JsonUtils.asStringOrNull(json['notes']),
      serviceCode: JsonUtils.asStringOrNull(json['service_code']),
      orderDate: JsonUtils.asStringOrNull(json['order_date']),
      estimatedDeliveryDate: JsonUtils.asStringOrNull(json['estimated_delivery_date']),
      cancelledAt: JsonUtils.asStringOrNull(json['cancelled_at']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isDeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      createdBy: JsonUtils.asIntOrNull(json['created_by']),
      updatedBy: JsonUtils.asIntOrNull(json['updated_by']),
      deletedBy: JsonUtils.asIntOrNull(json['deleted_by']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      deletedAt: JsonUtils.asStringOrNull(json['deleted_at']),
      items: JsonUtils.asModelList(json['items'], OrderItemModel.fromJson),
      shipments: json['shipments'] is List ? json['shipments'] as List : const [],
      pickupLoc: JsonUtils.asMapOrNull(json['pickupLoc']),
      paymentLogs: JsonUtils.asModelList(json['paymentLogs'], OrderPaymentLogModel.fromJson),
    );
  }
}

class OrderItemModel {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? variantId;
  final int? quantity;
  final String? unitPrice;
  final String? printMethod;
  final String? customText;
  final String? productName;
  final String? variantName;
  final OrderProductModel? product;
  final List<dynamic> designs;

  OrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    this.variantId,
    this.quantity,
    this.unitPrice,
    this.printMethod,
    this.customText,
    this.productName,
    this.variantName,
    this.product,
    this.designs = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: JsonUtils.asIntOrNull(json['id']),
      orderId: JsonUtils.asIntOrNull(json['order_id']),
      productId: JsonUtils.asIntOrNull(json['product_id']),
      variantId: JsonUtils.asIntOrNull(json['variant_id']),
      quantity: JsonUtils.asIntOrNull(json['quantity']),
      unitPrice: json['unit_price']?.toString(),
      printMethod: JsonUtils.asStringOrNull(json['print_method']),
      customText: JsonUtils.asStringOrNull(json['custom_text']),
      productName: JsonUtils.asStringOrNull(json['product_name']),
      variantName: JsonUtils.asStringOrNull(json['variant_name']),
      product: JsonUtils.asMapOrNull(json['product']) != null
          ? OrderProductModel.fromJson(JsonUtils.asMap(json['product']))
          : null,
      designs: json['designs'] is List ? json['designs'] as List : const [],
    );
  }

  double get totalPrice {
    final price = double.tryParse(unitPrice ?? '0') ?? 0.0;
    return price * (quantity ?? 0);
  }
}

class OrderProductModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? sku;
  final String? basePrice;
  final String? salePrice;
  final int? discountPercent;
  final String? discountAmount;
  final String? costPrice;
  final String? description;
  final String? shortDesc;
  final List<String> printMethods;
  final bool? isCustomizable;
  final bool? isFeatured;
  final int? views;
  final bool? isPickupAllowed;
  final bool? isDeliveryAllowed;
  final String? metaTitle;
  final String? metaDesc;
  final String? metaKeywords;
  final String? canonicalUrl;
  final int? categoryId;
  final int? vendorId;
  final List<String> tags;
  final String? weight;
  final String? length;
  final String? width;
  final String? height;
  final String? status;
  final bool? isActive;
  final bool? isDeleted;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  OrderProductModel({
    this.id,
    this.name,
    this.slug,
    this.sku,
    this.basePrice,
    this.salePrice,
    this.discountPercent,
    this.discountAmount,
    this.costPrice,
    this.description,
    this.shortDesc,
    this.printMethods = const [],
    this.isCustomizable,
    this.isFeatured,
    this.views,
    this.isPickupAllowed,
    this.isDeliveryAllowed,
    this.metaTitle,
    this.metaDesc,
    this.metaKeywords,
    this.canonicalUrl,
    this.categoryId,
    this.vendorId,
    this.tags = const [],
    this.weight,
    this.length,
    this.width,
    this.height,
    this.status,
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      slug: JsonUtils.asStringOrNull(json['slug']),
      sku: JsonUtils.asStringOrNull(json['sku']),
      basePrice: json['base_price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      discountPercent: JsonUtils.asIntOrNull(json['discount_percent']),
      discountAmount: json['discount_amount']?.toString(),
      costPrice: json['cost_price']?.toString(),
      description: JsonUtils.asStringOrNull(json['description']),
      shortDesc: JsonUtils.asStringOrNull(json['short_desc']),
      printMethods: JsonUtils.asStringList(json['print_methods']),
      isCustomizable: JsonUtils.asBoolOrNull(json['is_customizable']),
      isFeatured: JsonUtils.asBoolOrNull(json['is_featured']),
      views: JsonUtils.asIntOrNull(json['views']),
      isPickupAllowed: JsonUtils.asBoolOrNull(json['is_pickup_allowed']),
      isDeliveryAllowed: JsonUtils.asBoolOrNull(json['is_delivery_allowed']),
      metaTitle: JsonUtils.asStringOrNull(json['meta_title']),
      metaDesc: JsonUtils.asStringOrNull(json['meta_desc']),
      metaKeywords: JsonUtils.asStringOrNull(json['meta_keywords']),
      canonicalUrl: JsonUtils.asStringOrNull(json['canonical_url']),
      categoryId: JsonUtils.asIntOrNull(json['category_id']),
      vendorId: JsonUtils.asIntOrNull(json['vendor_id']),
      tags: JsonUtils.asStringList(json['tags']),
      weight: json['weight']?.toString(),
      length: json['length']?.toString(),
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      status: JsonUtils.asStringOrNull(json['status']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isDeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      createdBy: JsonUtils.asIntOrNull(json['created_by']),
      updatedBy: JsonUtils.asIntOrNull(json['updated_by']),
      deletedBy: JsonUtils.asIntOrNull(json['deleted_by']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      deletedAt: JsonUtils.asStringOrNull(json['deleted_at']),
    );
  }
}

class OrderPaymentLogModel {
  final int? id;
  final int? orderId;
  final String? amount;
  final String? paymentMethod;
  final String? transactionId;
  final String? status;
  final String? gatewayResponse;
  final String? createdAt;

  OrderPaymentLogModel({
    this.id,
    this.orderId,
    this.amount,
    this.paymentMethod,
    this.transactionId,
    this.status,
    this.gatewayResponse,
    this.createdAt,
  });

  factory OrderPaymentLogModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentLogModel(
      id: JsonUtils.asIntOrNull(json['id']),
      orderId: JsonUtils.asIntOrNull(json['order_id']),
      amount: json['amount']?.toString(),
      paymentMethod: JsonUtils.asStringOrNull(json['payment_method']),
      transactionId: JsonUtils.asStringOrNull(json['transaction_id']),
      status: JsonUtils.asStringOrNull(json['status']),
      gatewayResponse: JsonUtils.asStringOrNull(json['gateway_response']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
    );
  }
}

class OrderListResponse {
  final bool isSuccess;
  final String message;
  final List<OrderModel> payload;
  final PaginationModel pagination;

  OrderListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], OrderModel.fromJson),
      pagination: PaginationModel.fromJson(
        JsonUtils.asMapOrNull(json['pagination']),
      ),
    );
  }
}
