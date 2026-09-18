import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';

class ProductItem {
  final String id;
  final String name;
  final String? skuCode;
  final String? oldSkuCode;
  final String? imageUrl;
  final double? productPrice;
  final int? productId;
  final int? variantId;

  ProductItem({
    required this.id,
    required this.name,
    this.skuCode,
    this.oldSkuCode,
    this.imageUrl,
    this.productPrice,
    this.productId,
    this.variantId,
  });

  String get displayName => name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku_code': skuCode,
        'old_sku_code': oldSkuCode,
        'image_url': imageUrl,
        'product_price': productPrice,
        'product_id': productId,
        'variant_id': variantId,
      };

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        id: JsonUtils.asString(json['id']),
        name: JsonUtils.asString(json['name']),
        skuCode: JsonUtils.asStringOrNull(json['sku_code']),
        oldSkuCode: JsonUtils.asStringOrNull(json['old_sku_code']),
        imageUrl: UrlUtils.resolveImageUrl(
          JsonUtils.asStringOrNull(json['image_url'] ?? json['image']),
        ),
        productPrice: JsonUtils.asDoubleOrNull(json['product_price']),
        productId: JsonUtils.asIntOrNull(json['product_id']),
        variantId: JsonUtils.asIntOrNull(json['variant_id']),
      );
}
