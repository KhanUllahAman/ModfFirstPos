import 'package:modfirstpos/core/models/pagination_model.dart';
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
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      colorId: json['color_id'] as int?,
      sizeId: json['size_id'] as int?,
      sku: json['sku'] as String?,
      price: json['price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      status: json['status'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  double get priceValue => double.tryParse(price ?? '') ?? 0;
  double? get salePriceValue =>
      salePrice != null && salePrice!.isNotEmpty ? double.tryParse(salePrice!) : null;
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
      id: json['id'] as int?,
      imageUrl: json['image_url'] as String?,
      isPrimary: json['is_primary'] as bool?,
      sortOrder: json['sort_order'] as int?,
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
      id: json['id'] as int?,
      heading: json['heading'] as String?,
      description: json['description'] as String?,
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
    return ProductModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      sku: json['sku'] as String?,
      basePrice: json['base_price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      shortDesc: json['short_desc'] as String?,
      description: json['description'] as String?,
      printMethods: (json['print_methods'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isCustomizable: json['is_customizable'] as bool?,
      isActive: json['is_active'] as bool?,
      status: json['status'] as String?,
      categoryId: json['category_id'] as int?,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductVariantModel.fromJson(e))
          .toList(),
      descriptions: (json['descriptions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductDescriptionModel.fromJson(e))
          .toList(),
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductImageModel.fromJson(e))
          .toList(),
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  double get basePriceValue => double.tryParse(basePrice ?? '') ?? 0;
  double? get salePriceValue =>
      salePrice != null && salePrice!.isNotEmpty ? double.tryParse(salePrice!) : null;
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
    final rawPayload = json['payload'];
    final list = rawPayload is List
        ? rawPayload
            .whereType<Map<String, dynamic>>()
            .map((e) => ProductModel.fromJson(e))
            .toList()
        : <ProductModel>[];

    return ProductListResponse(
      isSuccess: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      payload: list,
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}