import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/setting/model/pos_device_model.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

class BootstrapStoreModel {
  final int? id;
  final String? siteName;
  final String? siteTagline;
  final String? logoUrl;
  final String? logoWhiteUrl;
  final String? logoBlackUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? currency;
  final String? currencySymbol;
  final String? taxPercentage;
  final String? defaultShippingFee;
  final String? freeShippingThreshold;
  final String? minOrderAmount;

  BootstrapStoreModel({
    this.id,
    this.siteName,
    this.siteTagline,
    this.logoUrl,
    this.logoWhiteUrl,
    this.logoBlackUrl,
    this.primaryColor,
    this.secondaryColor,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.currency,
    this.currencySymbol,
    this.taxPercentage,
    this.defaultShippingFee,
    this.freeShippingThreshold,
    this.minOrderAmount,
  });

  factory BootstrapStoreModel.fromJson(Map<String, dynamic> json) {
    return BootstrapStoreModel(
      id: JsonUtils.asIntOrNull(json['id']),
      siteName: JsonUtils.asStringOrNull(json['site_name']),
      siteTagline: JsonUtils.asStringOrNull(json['site_tagline']),
      logoUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['logo_url']),
      ),
      logoWhiteUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['logo_white_url']),
      ),
      logoBlackUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['logo_black_url']),
      ),
      primaryColor: JsonUtils.asStringOrNull(json['primary_color']),
      secondaryColor: JsonUtils.asStringOrNull(json['secondary_color']),
      contactEmail: JsonUtils.asStringOrNull(json['contact_email']),
      contactPhone: JsonUtils.asStringOrNull(json['contact_phone']),
      address: JsonUtils.asStringOrNull(json['address']),
      currency: JsonUtils.asStringOrNull(json['currency']),
      currencySymbol: JsonUtils.asStringOrNull(json['currency_symbol']),
      taxPercentage: JsonUtils.asStringOrNull(json['tax_percentage']),
      defaultShippingFee: JsonUtils.asStringOrNull(json['default_shipping_fee']),
      freeShippingThreshold:
          JsonUtils.asStringOrNull(json['free_shipping_threshold']),
      minOrderAmount: JsonUtils.asStringOrNull(json['min_order_amount']),
    );
  }
}

class BootstrapCashierModel {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? role;
  final String? image;
  final int? branchId;

  BootstrapCashierModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.image,
    this.branchId,
  });

  factory BootstrapCashierModel.fromJson(Map<String, dynamic> json) {
    return BootstrapCashierModel(
      id: JsonUtils.asIntOrNull(json['id']),
      fullName: JsonUtils.asStringOrNull(json['full_name']),
      email: JsonUtils.asStringOrNull(json['email']),
      phone: JsonUtils.asStringOrNull(json['phone']),
      role: JsonUtils.asStringOrNull(json['role']),
      image: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image'] ?? json['image_url']),
      ),
      branchId: JsonUtils.asIntOrNull(json['branch_id']),
    );
  }
}

class BootstrapCouponModel {
  final int? id;
  final String? code;
  final String? type;
  final String? value;
  final String? minOrderAmount;
  final int? usageLimit;
  final int? perUserLimit;
  final int? usedCount;
  final String? startDate;
  final String? endDate;
  final String? status;

  BootstrapCouponModel({
    this.id,
    this.code,
    this.type,
    this.value,
    this.minOrderAmount,
    this.usageLimit,
    this.perUserLimit,
    this.usedCount,
    this.startDate,
    this.endDate,
    this.status,
  });

  factory BootstrapCouponModel.fromJson(Map<String, dynamic> json) {
    return BootstrapCouponModel(
      id: JsonUtils.asIntOrNull(json['id']),
      code: JsonUtils.asStringOrNull(json['code']),
      type: JsonUtils.asStringOrNull(json['type']),
      value: JsonUtils.asStringOrNull(json['value']),
      minOrderAmount: JsonUtils.asStringOrNull(json['min_order_amount']),
      usageLimit: JsonUtils.asIntOrNull(json['usage_limit']),
      perUserLimit: JsonUtils.asIntOrNull(json['per_user_limit']),
      usedCount: JsonUtils.asIntOrNull(json['used_count']),
      startDate: JsonUtils.asStringOrNull(json['start_date']),
      endDate: JsonUtils.asStringOrNull(json['end_date']),
      status: JsonUtils.asStringOrNull(json['status']),
    );
  }
}

class BootstrapPayload {
  final String? syncedAt;
  final BootstrapStoreModel store;
  final BranchModel? branch;
  final BootstrapCashierModel cashier;
  final ShiftModel? openShift;
  final CustomerModel? walkInCustomer;
  final List<String> paymentMethods;
  final List<PosDeviceModel> devices;
  final List<CategoryModel> categories;
  final List<VariantColorModel> colors;
  final List<VariantSizeModel> sizes;
  final List<BootstrapCouponModel> coupons;
  final List<PickupLocationModel> pickupLocations;
  final List<ProductModel> products;

  BootstrapPayload({
    this.syncedAt,
    required this.store,
    this.branch,
    required this.cashier,
    this.openShift,
    this.walkInCustomer,
    this.paymentMethods = const [],
    this.devices = const [],
    this.categories = const [],
    this.colors = const [],
    this.sizes = const [],
    this.coupons = const [],
    this.pickupLocations = const [],
    this.products = const [],
  });

  factory BootstrapPayload.fromJson(Map<String, dynamic> json) {
    return BootstrapPayload(
      syncedAt: JsonUtils.asStringOrNull(json['synced_at']),
      store: BootstrapStoreModel.fromJson(JsonUtils.asMap(json['store'])),
      branch: JsonUtils.asMapOrNull(json['branch']) != null
          ? BranchModel.fromJson(JsonUtils.asMap(json['branch']))
          : null,
      cashier:
          BootstrapCashierModel.fromJson(JsonUtils.asMap(json['cashier'])),
      openShift: JsonUtils.asMapOrNull(json['open_shift']) != null
          ? ShiftModel.fromJson(JsonUtils.asMap(json['open_shift']))
          : null,
      walkInCustomer: JsonUtils.asMapOrNull(json['walk_in_customer']) != null
          ? CustomerModel.fromJson(JsonUtils.asMap(json['walk_in_customer']))
          : null,
      paymentMethods: JsonUtils.asStringList(json['payment_methods']),
      devices: JsonUtils.asModelList(json['devices'], PosDeviceModel.fromJson),
      categories:
          JsonUtils.asModelList(json['categories'], CategoryModel.fromJson),
      colors: JsonUtils.asModelList(json['colors'], VariantColorModel.fromJson),
      sizes: JsonUtils.asModelList(json['sizes'], VariantSizeModel.fromJson),
      coupons:
          JsonUtils.asModelList(json['coupons'], BootstrapCouponModel.fromJson),
      pickupLocations: JsonUtils.asModelList(
          json['pickup_locations'], PickupLocationModel.fromJson),
      products: JsonUtils.asModelList(json['products'], ProductModel.fromJson),
    );
  }
}

class BootstrapResponse {
  final bool isSuccess;
  final String message;
  final BootstrapPayload? payload;

  BootstrapResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory BootstrapResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return BootstrapResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? BootstrapPayload.fromJson(payload) : null,
    );
  }
}
