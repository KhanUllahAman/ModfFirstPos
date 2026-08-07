import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

class DiscountTierModel {
  final int id;
  final String? name;
  final String? discountType;
  final String? discountValue;
  final bool isActive;

  DiscountTierModel({
    required this.id,
    this.name,
    this.discountType,
    this.discountValue,
    this.isActive = true,
  });

  factory DiscountTierModel.fromJson(Map<String, dynamic> json) {
    return DiscountTierModel(
      id: JsonUtils.asInt(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      discountType: JsonUtils.asStringOrNull(json['discount_type']),
      discountValue: json['discount_value']?.toString(),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
    );
  }

  double get discountValueNumber => JsonUtils.asDouble(discountValue);

  String get label {
    if (discountType == 'percentage') {
      return '${name ?? 'Discount Tier'} (${discountValue ?? '0'}%)';
    }
    if (discountType == 'fixed_amount') {
      return '${name ?? 'Discount Tier'} (\$${discountValue ?? '0'})';
    }
    return name ?? 'Discount Tier';
  }
}

class DiscountTierListResponse {
  final bool isSuccess;
  final String message;
  final List<DiscountTierModel> payload;
  final PaginationModel pagination;

  DiscountTierListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory DiscountTierListResponse.fromJson(Map<String, dynamic> json) {
    return DiscountTierListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], DiscountTierModel.fromJson),
      pagination: PaginationModel.fromJson(JsonUtils.asMap(json['pagination'])),
    );
  }
}

class DiscountTierCreateResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final DiscountTierModel? payload;

  DiscountTierCreateResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.payload,
  });

  factory DiscountTierCreateResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return DiscountTierCreateResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      status: JsonUtils.asInt(json['status']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? DiscountTierModel.fromJson(payload) : null,
    );
  }
}
