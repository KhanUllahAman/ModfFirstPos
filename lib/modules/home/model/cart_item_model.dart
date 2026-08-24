import 'package:modfirstpos/core/utils/json_utils.dart';

class CartItemModel {
  final CartProduct product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total => product.unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    product: CartProduct.fromJson(JsonUtils.asMap(json['product'])),
    quantity: JsonUtils.asInt(json['quantity'], fallback: 1),
  );
}

class CartProduct {
  final String name;
  final String skuCode;
  final String? imageUrl;
  final double amount;
  final double unitPrice;
  final int? productId;
  final int? variantId;

  /// Set only for cashier-created, non-catalogue sale lines.
  final String? customText;
  final bool? isAppliedTax;
  final double? customPrice;

  CartProduct({
    required this.name,
    required this.skuCode,
    this.imageUrl,
    required this.amount,
    required this.unitPrice,
    this.productId,
    this.variantId,
    this.customText,
    this.isAppliedTax,
    this.customPrice,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku_code': skuCode,
    'image_url': imageUrl,
    'amount': amount,
    'unit_price': unitPrice,
    'product_id': productId,
    'variant_id': variantId,
    if (customText != null) 'custom_text': customText,
    if (isAppliedTax != null) 'is_applied_tax': isAppliedTax,
    if (customPrice != null) 'cutome_price': customPrice,
  };

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
    name: JsonUtils.asString(json['name']),
    skuCode: JsonUtils.asString(json['sku_code'], fallback: '--'),
    imageUrl: JsonUtils.asStringOrNull(json['image_url']),
    amount: JsonUtils.asDouble(json['amount']),
    unitPrice: JsonUtils.asDouble(json['unit_price']),
    productId: JsonUtils.asIntOrNull(json['product_id']),
    variantId: JsonUtils.asIntOrNull(json['variant_id']),
    customText: JsonUtils.asStringOrNull(json['custom_text']),
    isAppliedTax: json['is_applied_tax'] is bool
        ? json['is_applied_tax'] as bool
        : null,
    customPrice: json['cutome_price'] == null
        ? null
        : JsonUtils.asDouble(json['cutome_price']),
  );
}
