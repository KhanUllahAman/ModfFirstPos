class CartItemModel {
  final CartProduct product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get total => product.unitPrice * quantity;
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
}