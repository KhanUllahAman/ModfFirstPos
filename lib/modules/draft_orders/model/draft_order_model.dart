import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';

class DraftOrderListResponse {
  final bool success;
  final int status;
  final String message;
  final List<DraftOrderModel> payload;
  final DraftOrderPaginationModel? pagination;

  DraftOrderListResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.payload,
    this.pagination,
  });

  factory DraftOrderListResponse.fromJson(Map<String, dynamic> json) {
    final payloadList = JsonUtils.asModelList(
      json['payload'],
      DraftOrderModel.fromJson,
    );

    return DraftOrderListResponse(
      success: JsonUtils.asBool(json['success'], fallback: false),
      status: JsonUtils.asInt(json['status'], fallback: 200),
      message: JsonUtils.asString(json['message']),
      payload: payloadList,
      pagination: json['pagination'] != null
          ? DraftOrderPaginationModel.fromJson(JsonUtils.asMap(json['pagination']))
          : null,
    );
  }
}

class DraftOrderPaginationModel {
  final int page;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  DraftOrderPaginationModel({
    required this.page,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory DraftOrderPaginationModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderPaginationModel(
      page: JsonUtils.asInt(json['page'], fallback: 1),
      total: JsonUtils.asInt(json['total'], fallback: 0),
      hasNext: JsonUtils.asBool(json['hasNext'], fallback: false),
      hasPrev: JsonUtils.asBool(json['hasPrev'], fallback: false),
    );
  }
}

class DraftOrderModel {
  final int id;
  final String draftNumber;
  final int? websiteSettingId;
  final int? branchId;
  final int? userId;
  final String? email;
  final String? phone;
  final String? fullName;
  final String status;
  final String deliveryType;
  final String channel;
  final int? shippingAddressId;
  final int? billingAddressId;
  final int? pickupLocationId;
  final String? couponCode;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String? manualDiscountType;
  final double? manualDiscountValue;
  final String? manualDiscountReason;
  final String? notes;
  final int? convertedOrderId;
  final String? invoiceSentAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<DraftOrderItemModel> items;
  final DraftOrderUserModel? user;
  final DraftOrderAddressModel? shippingAddr;
  final DraftOrderAddressModel? billingAddr;
  final DraftOrderPickupLocModel? pickupLoc;
  final DraftOrderBranchModel? branch;
  final DraftOrderConvertedOrderModel? convertedOrder;

  DraftOrderModel({
    required this.id,
    required this.draftNumber,
    this.websiteSettingId,
    this.branchId,
    this.userId,
    this.email,
    this.phone,
    this.fullName,
    required this.status,
    required this.deliveryType,
    required this.channel,
    this.shippingAddressId,
    this.billingAddressId,
    this.pickupLocationId,
    this.couponCode,
    this.subtotal = 0.0,
    this.shippingFee = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.manualDiscountType,
    this.manualDiscountValue,
    this.manualDiscountReason,
    this.notes,
    this.convertedOrderId,
    this.invoiceSentAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.user,
    this.shippingAddr,
    this.billingAddr,
    this.pickupLoc,
    this.branch,
    this.convertedOrder,
  });

  factory DraftOrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = JsonUtils.asModelList(
      json['items'],
      DraftOrderItemModel.fromJson,
    );

    return DraftOrderModel(
      id: JsonUtils.asInt(json['id']),
      draftNumber: JsonUtils.asString(json['draft_number'], fallback: '--'),
      websiteSettingId: JsonUtils.asIntOrNull(json['website_setting_id']),
      branchId: JsonUtils.asIntOrNull(json['branch_id']),
      userId: JsonUtils.asIntOrNull(json['user_id']),
      email: JsonUtils.asStringOrNull(json['email']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      status: JsonUtils.asString(json['status'], fallback: 'open'),
      deliveryType: JsonUtils.asString(json['delivery_type'], fallback: 'home_delivery'),
      channel: JsonUtils.asString(json['channel'], fallback: 'point_of_sale'),
      shippingAddressId: JsonUtils.asIntOrNull(json['shipping_address_id']),
      billingAddressId: JsonUtils.asIntOrNull(json['billing_address_id']),
      pickupLocationId: JsonUtils.asIntOrNull(json['pickup_location_id']),
      couponCode: JsonUtils.asStringOrNull(json['coupon_code']),
      subtotal: JsonUtils.asDouble(json['subtotal']),
      shippingFee: JsonUtils.asDouble(json['shipping_fee']),
      discountAmount: JsonUtils.asDouble(json['discount_amount']),
      taxAmount: JsonUtils.asDouble(json['tax_amount']),
      totalAmount: JsonUtils.asDouble(json['total_amount']),
      manualDiscountType: JsonUtils.asStringOrNull(json['manual_discount_type']),
      manualDiscountValue: JsonUtils.asDoubleOrNull(json['manual_discount_value']),
      manualDiscountReason: JsonUtils.asStringOrNull(json['manual_discount_reason']),
      notes: JsonUtils.asStringOrNull(json['notes']),
      convertedOrderId: JsonUtils.asIntOrNull(json['converted_order_id']),
      invoiceSentAt: JsonUtils.asStringOrNull(json['invoice_sent_at']),
      completedAt: JsonUtils.asStringOrNull(json['completed_at']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      items: itemsList,
      user: json['user'] != null
          ? DraftOrderUserModel.fromJson(JsonUtils.asMap(json['user']))
          : null,
      shippingAddr: json['shippingAddr'] != null
          ? DraftOrderAddressModel.fromJson(JsonUtils.asMap(json['shippingAddr']))
          : null,
      billingAddr: json['billingAddr'] != null
          ? DraftOrderAddressModel.fromJson(JsonUtils.asMap(json['billingAddr']))
          : null,
      pickupLoc: json['pickupLoc'] != null
          ? DraftOrderPickupLocModel.fromJson(JsonUtils.asMap(json['pickupLoc']))
          : null,
      branch: json['branch'] != null
          ? DraftOrderBranchModel.fromJson(JsonUtils.asMap(json['branch']))
          : null,
      convertedOrder: json['convertedOrder'] != null
          ? DraftOrderConvertedOrderModel.fromJson(JsonUtils.asMap(json['convertedOrder']))
          : null,
    );
  }

  String get displayCustomerName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (user != null && user!.fullName != null && user!.fullName!.trim().isNotEmpty) {
      return user!.fullName!.trim();
    }
    if (shippingAddr != null && shippingAddr!.fullName != null && shippingAddr!.fullName!.trim().isNotEmpty) {
      return shippingAddr!.fullName!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim();
    }
    return 'Walk-in Customer';
  }

  String get displayPhone {
    if (phone != null && phone!.trim().isNotEmpty) {
      return phone!.trim();
    }
    if (user != null && user!.phone != null && user!.phone!.trim().isNotEmpty) {
      return user!.phone!.trim();
    }
    if (shippingAddr != null && shippingAddr!.phone != null && shippingAddr!.phone!.trim().isNotEmpty) {
      return shippingAddr!.phone!.trim();
    }
    return '--';
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInvoiceSent => status.toLowerCase() == 'invoice_sent';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class DraftOrderItemModel {
  final int id;
  final int draftOrderId;
  final int? productId;
  final int? variantId;
  final int quantity;
  final double unitPrice;
  final String? printMethod;
  final String? customText;
  final double? width;
  final double? height;
  final bool isTaxApplied;
  final bool isCustomPrice;
  final dynamic designUploadIds;
  final String? itemImageUrl;
  final ProductModel? product;
  final ProductVariantModel? variant;

  DraftOrderItemModel({
    required this.id,
    required this.draftOrderId,
    this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    this.printMethod,
    this.customText,
    this.width,
    this.height,
    this.isTaxApplied = false,
    this.isCustomPrice = false,
    this.designUploadIds,
    this.itemImageUrl,
    this.product,
    this.variant,
  });

  factory DraftOrderItemModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderItemModel(
      id: JsonUtils.asInt(json['id']),
      draftOrderId: JsonUtils.asInt(json['draft_order_id']),
      productId: JsonUtils.asIntOrNull(json['product_id']),
      variantId: JsonUtils.asIntOrNull(json['variant_id']),
      quantity: JsonUtils.asInt(json['quantity'], fallback: 1),
      unitPrice: JsonUtils.asDouble(json['unit_price']),
      printMethod: JsonUtils.asStringOrNull(json['print_method']),
      customText: JsonUtils.asStringOrNull(json['custom_text']),
      width: JsonUtils.asDoubleOrNull(json['width']),
      height: JsonUtils.asDoubleOrNull(json['height']),
      isTaxApplied: JsonUtils.asBool(json['is_tax_applied'], fallback: false),
      isCustomPrice: JsonUtils.asBool(json['is_custom_price'], fallback: false),
      designUploadIds: json['design_upload_ids'],
      itemImageUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image_url'] ?? json['image'] ?? json['thumbnail']),
      ),
      product: json['product'] != null
          ? ProductModel.fromJson(JsonUtils.asMap(json['product']))
          : null,
      variant: json['variant'] != null
          ? ProductVariantModel.fromJson(JsonUtils.asMap(json['variant']))
          : null,
    );
  }

  double get lineTotal => unitPrice * quantity;

  String? get imageUrl {
    if (variant?.imageUrl != null && variant!.imageUrl!.isNotEmpty) {
      return variant!.imageUrl;
    }
    if (itemImageUrl != null && itemImageUrl!.isNotEmpty) {
      return itemImageUrl;
    }
    if (product?.primaryImageUrl != null && product!.primaryImageUrl!.isNotEmpty) {
      return product!.primaryImageUrl;
    }
    if (product?.images != null && product!.images.isNotEmpty) {
      return product!.images.first.toString();
    }
    return null;
  }

  CartItemModel toCartItem() {
    final baseName = product?.name ?? customText ?? 'Item #$id';
    final variantLabel = variant?.displayName;
    final name = (variantLabel != null && variantLabel.isNotEmpty)
        ? '$baseName ($variantLabel)'
        : baseName;
    final sku = variant?.sku ?? product?.sku ?? 'CUSTOM';
    final resolvedImageUrl = imageUrl;

    return CartItemModel(
      product: CartProduct(
        name: name,
        skuCode: sku,
        imageUrl: resolvedImageUrl,
        amount: unitPrice,
        unitPrice: unitPrice,
        productId: productId ?? product?.id,
        variantId: variantId ?? variant?.id,
        customText: customText,
        isAppliedTax: isTaxApplied,
        customPrice: isCustomPrice ? unitPrice : null,
      ),
      quantity: quantity > 0 ? quantity : 1,
    );
  }
}

class DraftOrderUserModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? role;
  final String? accountType;
  final int? discountTierId;

  DraftOrderUserModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.accountType,
    this.discountTierId,
  });

  factory DraftOrderUserModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderUserModel(
      id: JsonUtils.asInt(json['id']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      email: JsonUtils.asStringOrNull(json['email']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      role: JsonUtils.asStringOrNull(json['role']),
      accountType: JsonUtils.asStringOrNull(json['account_type']),
      discountTierId: JsonUtils.asIntOrNull(json['discount_tier_id']),
    );
  }
}

class DraftOrderAddressModel {
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
  final String? type;

  DraftOrderAddressModel({
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
    this.type,
  });

  factory DraftOrderAddressModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderAddressModel(
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
      type: JsonUtils.asStringOrNull(json['type']),
    );
  }

  String get fullAddressFormatted {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      postalCode,
      country,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }
}

class DraftOrderPickupLocModel {
  final int id;
  final String? name;
  final String? address;
  final String? city;
  final String? phone;

  DraftOrderPickupLocModel({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.phone,
  });

  factory DraftOrderPickupLocModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderPickupLocModel(
      id: JsonUtils.asInt(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      address: JsonUtils.asStringOrNull(json['address']),
      city: JsonUtils.asStringOrNull(json['city']),
      phone: JsonUtils.asStringOrNull(json['phone']),
    );
  }
}

class DraftOrderBranchModel {
  final int id;
  final String? name;
  final String? code;
  final String? description;
  final String? phone;
  final String? email;

  DraftOrderBranchModel({
    required this.id,
    this.name,
    this.code,
    this.description,
    this.phone,
    this.email,
  });

  factory DraftOrderBranchModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderBranchModel(
      id: JsonUtils.asInt(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      code: JsonUtils.asStringOrNull(json['code']),
      description: JsonUtils.asStringOrNull(json['description']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      email: JsonUtils.asStringOrNull(json['email']),
    );
  }
}

class DraftOrderConvertedOrderModel {
  final int id;
  final String? orderNumber;
  final String? status;
  final String? paymentStatus;
  final String? channel;
  final double totalAmount;
  final double paidAmount;
  final String? orderDate;
  final String? createdAt;

  DraftOrderConvertedOrderModel({
    required this.id,
    this.orderNumber,
    this.status,
    this.paymentStatus,
    this.channel,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.orderDate,
    this.createdAt,
  });

  factory DraftOrderConvertedOrderModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderConvertedOrderModel(
      id: JsonUtils.asInt(json['id']),
      orderNumber: JsonUtils.asStringOrNull(json['order_number']),
      status: JsonUtils.asStringOrNull(json['status']),
      paymentStatus: JsonUtils.asStringOrNull(json['payment_status']),
      channel: JsonUtils.asStringOrNull(json['channel']),
      totalAmount: JsonUtils.asDouble(json['total_amount']),
      paidAmount: JsonUtils.asDouble(json['paid_amount']),
      orderDate: JsonUtils.asStringOrNull(json['order_date']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
    );
  }
}
