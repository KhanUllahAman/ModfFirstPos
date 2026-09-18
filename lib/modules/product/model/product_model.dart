import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';

class VariantColorModel {
  final int? id;
  final String? name;
  final String? hexCode;

  VariantColorModel({this.id, this.name, this.hexCode});

  factory VariantColorModel.fromJson(Map<String, dynamic> json) {
    return VariantColorModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      hexCode: JsonUtils.asStringOrNull(json['hex_code']),
    );
  }

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (id != null) return 'Color #$id';
    return '';
  }
}

class VariantSizeModel {
  final int? id;
  final String? name;
  final String? displayName;

  VariantSizeModel({this.id, this.name, this.displayName});

  factory VariantSizeModel.fromJson(Map<String, dynamic> json) {
    return VariantSizeModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      displayName: JsonUtils.asStringOrNull(json['display_name']),
    );
  }

  String get label {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (displayName != null && displayName!.trim().isNotEmpty) return displayName!.trim();
    if (id != null) return 'Size #$id';
    return '';
  }
}

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
  final String? imageUrl;
  final VariantColorModel? color;
  final VariantSizeModel? size;
  final int? stockQuantity;

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
    this.imageUrl,
    this.color,
    this.size,
    this.stockQuantity,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final colorMap = JsonUtils.asMapOrNull(json['color']);
    final sizeMap = JsonUtils.asMapOrNull(json['size']);
    final inventoryMap = JsonUtils.asMapOrNull(json['inventory']);
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
      imageUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image_url'] ?? json['image']),
      ),
      color: colorMap != null ? VariantColorModel.fromJson(colorMap) : null,
      size: sizeMap != null ? VariantSizeModel.fromJson(sizeMap) : null,
      stockQuantity: inventoryMap != null
          ? JsonUtils.asIntOrNull(inventoryMap['quantity'])
          : null,
    );
  }

  double get priceValue => JsonUtils.asDouble(price);
  double? get salePriceValue => JsonUtils.asDoubleOrNull(salePrice);
  double get effectivePrice => salePriceValue ?? priceValue;

  /// Unknown stock (null) is treated as in stock.
  bool get inStock => stockQuantity == null || stockQuantity! > 0;

  /// True when the API provided color/size dimensions for this variant.
  bool get hasDimensions => color != null || size != null;

  /// Human-readable label for this variant combining color and size dimensions,
  /// falling back to SKU, or 'Variant #id'. Never produces '(null)'.
  String get displayName {
    final parts = <String>[];
    final colorName = color?.displayName;
    if (colorName != null && colorName.trim().isNotEmpty) {
      parts.add(colorName.trim());
    }
    final sizeName = size?.label;
    if (sizeName != null && sizeName.trim().isNotEmpty) {
      parts.add(sizeName.trim());
    }
    if (parts.isNotEmpty) {
      return parts.join(' / ');
    }
    if (sku != null && sku!.trim().isNotEmpty && sku!.trim() != '--') {
      return sku!.trim();
    }
    if (id != null) {
      return 'Variant #$id';
    }
    return '';
  }
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
        JsonUtils.asStringOrNull(
          json['image_url'] ?? json['image'] ?? json['url'],
        ),
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
  final bool? isCustom;
  final bool? isActive;
  final String? status;
  final int? categoryId;
  final List<ProductVariantModel> variants;
  final List<ProductDescriptionModel> descriptions;
  final List<ProductImageModel> images;
  final CategoryModel? category;

  /// Product-level stock (variant-less products only) — present on the
  /// pos/bootstrap payload, not the paginated products/list endpoint.
  final int? stock;

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
    this.isCustom,
    this.isActive,
    this.status,
    this.categoryId,
    this.variants = const [],
    this.descriptions = const [],
    this.images = const [],
    this.category,
    this.stock,
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
      isCustom: JsonUtils.asBoolOrNull(json['is_custom']),
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
      images: () {
        final parsedImages = JsonUtils.asModelList(
          json['images'],
          ProductImageModel.fromJson,
        );
        final directImageUrl = UrlUtils.resolveImageUrl(
          JsonUtils.asStringOrNull(
            json['image_url'] ?? json['image'] ?? json['featured_image'],
          ),
        );
        if (parsedImages.isEmpty &&
            directImageUrl != null &&
            directImageUrl.isNotEmpty) {
          parsedImages.add(
            ProductImageModel(imageUrl: directImageUrl, isPrimary: true),
          );
        }
        return parsedImages;
      }(),
      category: categoryMap != null ? CategoryModel.fromJson(categoryMap) : null,
      stock: JsonUtils.asIntOrNull(json['stock']),
    );
  }

  double get basePriceValue => JsonUtils.asDouble(basePrice);
  double? get salePriceValue => JsonUtils.asDoubleOrNull(salePrice);
  double get effectivePrice => salePriceValue ?? basePriceValue;

  String get displayName => name ?? 'Unnamed Product';

  bool get hasVariants => variants.isNotEmpty;

  /// True when variants carry size/color dimensions (rich selector UI).
  bool get hasVariantDimensions =>
      variants.any((v) => v.hasDimensions);

  /// Unique sizes across variants, in order of first appearance.
  List<VariantSizeModel> get availableSizes {
    final seen = <int>{};
    final sizes = <VariantSizeModel>[];
    for (final v in variants) {
      final s = v.size;
      if (s?.id != null && seen.add(s!.id!)) sizes.add(s);
    }
    return sizes;
  }

  /// Unique colors across variants, in order of first appearance.
  List<VariantColorModel> get availableColors {
    final seen = <int>{};
    final colors = <VariantColorModel>[];
    for (final v in variants) {
      final c = v.color;
      if (c?.id != null && seen.add(c!.id!)) colors.add(c);
    }
    return colors;
  }

  /// The variant matching a size/color pair (either may be null).
  ProductVariantModel? findVariant({int? sizeId, int? colorId}) {
    for (final v in variants) {
      final sizeOk = sizeId == null || v.sizeId == sizeId;
      final colorOk = colorId == null || v.colorId == colorId;
      if (sizeOk && colorOk) return v;
    }
    return null;
  }

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.firstWhere(
      (img) => img.isPrimary == true,
      orElse: () => images.first,
    );
    return primary.imageUrl;
  }

  /// All unique resolved image URLs for the product, prioritizing primary image.
  List<String> get allImageUrls {
    final urls = <String>[];
    final primary = primaryImageUrl;
    if (primary != null && primary.isNotEmpty) {
      urls.add(primary);
    }
    for (final img in images) {
      final u = img.imageUrl;
      if (u != null && u.isNotEmpty && !urls.contains(u)) {
        urls.add(u);
      }
    }
    return urls;
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
