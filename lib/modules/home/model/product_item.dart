class ProductItem {
  final String id;
  final String name;
  final String? skuCode;
  final String? oldSkuCode;
  final String? imageUrl;
  final double? productPrice;

  ProductItem({
    required this.id,
    required this.name,
    this.skuCode,
    this.oldSkuCode,
    this.imageUrl,
    this.productPrice,
  });

  String get displayName => name;
}