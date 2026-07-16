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

  CartProduct({
    required this.name,
    required this.skuCode,
    this.imageUrl,
    required this.amount,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku_code': skuCode,
        'image_url': imageUrl,
        'amount': amount,
        'unit_price': unitPrice,
      };

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
        name: JsonUtils.asString(json['name']),
        skuCode: JsonUtils.asString(json['sku_code'], fallback: '--'),
        imageUrl: JsonUtils.asStringOrNull(json['image_url']),
        amount: JsonUtils.asDouble(json['amount']),
        unitPrice: JsonUtils.asDouble(json['unit_price']),
      );
}
