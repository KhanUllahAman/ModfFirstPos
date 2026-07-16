import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';

class ProductVariantModel {
  final int? id;
  final int? productId;
  final int? colorId;
  final int? sizeId;
  final String? sku;
  final String? price;
  final String? salePrice;
  final String? status;
  final bool? isActive;

  ProductVariantModel({
    this.id,
    this.productId,
    this.colorId,
    this.sizeId,
    this.sku,
    this.price,
    this.salePrice,
    this.status,
    this.isActive,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: JsonUtils.asIntOrNull(json['id']),
      productId: JsonUtils.asIntOrNull(json['product_id']),
      colorId: JsonUtils.asIntOrNull(json['color_id']),
      sizeId: JsonUtils.asIntOrNull(json['size_id']),
      sku: JsonUtils.asStringOrNull(json['sku']),
      price: JsonUtils.asStringOrNull(json['price']),
      salePrice: JsonUtils.asStringOrNull(json['sale_price']),
      status: JsonUtils.asStringOrNull(json['status']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
    );
  }

  double get priceValue => JsonUtils.asDouble(price);
  double? get salePriceValue => JsonUtils.asDoubleOrNull(salePrice);
  double get effectivePrice => salePriceValue ?? priceValue;
}

class ProductImageModel {
  final int? id;
  final String? imageUrl;
  final bool? isPrimary;
  final int? sortOrder;

  ProductImageModel({this.id, this.imageUrl, this.isPrimary, this.sortOrder});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: JsonUtils.asIntOrNull(json['id']),
      imageUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image_url']),
      ),
      isPrimary: JsonUtils.asBoolOrNull(json['is_primary']),
      sortOrder: JsonUtils.asIntOrNull(json['sort_order']),
    );
  }
}

class ProductDescriptionModel {
  final int? id;
  final String? heading;
  final String? description;

  ProductDescriptionModel({this.id, this.heading, this.description});

  factory ProductDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ProductDescriptionModel(
      id: JsonUtils.asIntOrNull(json['id']),
      heading: JsonUtils.asStringOrNull(json['heading']),
      description: JsonUtils.asStringOrNull(json['description']),
    );
  }
}

class ProductModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? sku;
  final String? basePrice;
  final String? salePrice;
  final String? shortDesc;
  final String? description;
  final List<String> printMethods;
  final bool? isCustomizable;
  final bool? isActive;
  final String? status;
  final int? categoryId;
  final List<ProductVariantModel> variants;
  final List<ProductDescriptionModel> descriptions;
  final List<ProductImageModel> images;
  final CategoryModel? category;

  ProductModel({
    this.id,
    this.name,
    this.slug,
    this.sku,
    this.basePrice,
    this.salePrice,
    this.shortDesc,
    this.description,
    this.printMethods = const [],
    this.isCustomizable,
    this.isActive,
    this.status,
    this.categoryId,
    this.variants = const [],
    this.descriptions = const [],
    this.images = const [],
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryMap = JsonUtils.asMapOrNull(json['category']);
    return ProductModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      slug: JsonUtils.asStringOrNull(json['slug']),
      sku: JsonUtils.asStringOrNull(json['sku']),
      basePrice: JsonUtils.asStringOrNull(json['base_price']),
      salePrice: JsonUtils.asStringOrNull(json['sale_price']),
      shortDesc: JsonUtils.asStringOrNull(json['short_desc']),
      description: JsonUtils.asStringOrNull(json['description']),
      printMethods: JsonUtils.asStringList(json['print_methods']),
      isCustomizable: JsonUtils.asBoolOrNull(json['is_customizable']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      status: JsonUtils.asStringOrNull(json['status']),
      categoryId: JsonUtils.asIntOrNull(json['category_id']),
      variants: JsonUtils.asModelList(
        json['variants'],
        ProductVariantModel.fromJson,
      ),
      descriptions: JsonUtils.asModelList(
        json['descriptions'],
        ProductDescriptionModel.fromJson,
      ),
      images: JsonUtils.asModelList(
        json['images'],
        ProductImageModel.fromJson,
      ),
      category: categoryMap != null ? CategoryModel.fromJson(categoryMap) : null,
    );
  }

  double get basePriceValue => JsonUtils.asDouble(basePrice);
  double? get salePriceValue => JsonUtils.asDoubleOrNull(salePrice);
  double get effectivePrice => salePriceValue ?? basePriceValue;

  String get displayName => name ?? 'Unnamed Product';

  bool get hasVariants => variants.isNotEmpty;

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.firstWhere(
      (img) => img.isPrimary == true,
      orElse: () => images.first,
    );
    return primary.imageUrl;
  }
}

class ProductListResponse {
  final bool isSuccess;
  final String message;
  final List<ProductModel> payload;
  final PaginationModel pagination;

  ProductListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], ProductModel.fromJson),
      pagination: PaginationModel.fromJson(
        JsonUtils.asMapOrNull(json['pagination']),
      ),
    );
  }
}
