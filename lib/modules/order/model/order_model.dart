import 'package:modfirstpos/core/models/pagination_model.dart';

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
      id: json['id'] as int?,
      orderNumber: json['order_number'] as String?,
      userId: json['user_id'] as int?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      deliveryType: json['delivery_type'] as String?,
      shippingStatus: json['shipping_status'] as String?,
      channel: json['channel'] as String?,
      shippingAddressId: json['shipping_address_id'] as int?,
      billingAddressId: json['billing_address_id'] as int?,
      couponId: json['coupon_id'] as int?,
      pickupLocationId: json['pickup_location_id'] as int?,
      subtotal: json['subtotal']?.toString(),
      shippingFee: json['shipping_fee']?.toString(),
      discountAmount: json['discount_amount']?.toString(),
      taxAmount: json['tax_amount']?.toString(),
      paidAmount: json['paid_amount']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      discountSource: json['discount_source'] as String?,
      onlineAmount: json['online_amount']?.toString(),
      cashAmount: json['cash_amount']?.toString(),
      notes: json['notes'] as String?,
      serviceCode: json['service_code'] as String?,
      orderDate: json['order_date'] as String?,
      estimatedDeliveryDate: json['estimated_delivery_date'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      isActive: json['is_active'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      shipments: json['shipments'] as List<dynamic>? ?? [],
      pickupLoc: json['pickupLoc'] as Map<String, dynamic>?,
      paymentLogs: (json['paymentLogs'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderPaymentLogModel.fromJson(e))
          .toList(),
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
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      productId: json['product_id'] as int?,
      variantId: json['variant_id'] as int?,
      quantity: json['quantity'] as int?,
      unitPrice: json['unit_price']?.toString(),
      printMethod: json['print_method'] as String?,
      customText: json['custom_text'] as String?,
      productName: json['product_name'] as String?,
      variantName: json['variant_name'] as String?,
      product: json['product'] is Map<String, dynamic>
          ? OrderProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      designs: json['designs'] as List<dynamic>? ?? [],
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
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      sku: json['sku'] as String?,
      basePrice: json['base_price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      discountPercent: json['discount_percent'] as int?,
      discountAmount: json['discount_amount']?.toString(),
      costPrice: json['cost_price']?.toString(),
      description: json['description'] as String?,
      shortDesc: json['short_desc'] as String?,
      printMethods: (json['print_methods'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isCustomizable: json['is_customizable'] as bool?,
      isFeatured: json['is_featured'] as bool?,
      views: json['views'] as int?,
      isPickupAllowed: json['is_pickup_allowed'] as bool?,
      isDeliveryAllowed: json['is_delivery_allowed'] as bool?,
      metaTitle: json['meta_title'] as String?,
      metaDesc: json['meta_desc'] as String?,
      metaKeywords: json['meta_keywords'] as String?,
      canonicalUrl: json['canonical_url'] as String?,
      categoryId: json['category_id'] as int?,
      vendorId: json['vendor_id'] as int?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      weight: json['weight']?.toString(),
      length: json['length']?.toString(),
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      status: json['status'] as String?,
      isActive: json['is_active'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
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
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      amount: json['amount']?.toString(),
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      status: json['status'] as String?,
      gatewayResponse: json['gateway_response'] as String?,
      createdAt: json['created_at'] as String?,
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
    final rawPayload = json['payload'];
    final list = rawPayload is List
        ? rawPayload
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList()
        : <OrderModel>[];

    return OrderListResponse(
      isSuccess: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      payload: list,
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}
