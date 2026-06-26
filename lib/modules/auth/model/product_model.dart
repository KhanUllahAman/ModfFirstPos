import 'dart:developer';

class ProductResponseModel {
  final int status;
  final String message;
  final ProductPayload? payload;

  ProductResponseModel({
    required this.status,
    required this.message,
    this.payload,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    ProductPayload? payload;
    try {
      final payloadData = json['payload'];
      if (payloadData != null && payloadData is Map<String, dynamic>) {
        payload = ProductPayload.fromJson(payloadData);
      }
    } catch (e) {
      log("Error parsing product payload: $e");
    }

    final rawStatus = json['status'];
    final int parsedStatus = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '0') ?? 0;

    return ProductResponseModel(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }

  bool get isSuccess => status == 1;
}

class ProductPayload {
  final String? locCode;
  final String? locName;
  final List<ProductItem> detail;

  ProductPayload({
    this.locCode,
    this.locName,
    required this.detail,
  });

  factory ProductPayload.fromJson(Map<String, dynamic> json) {
    final List<ProductItem> detailList = [];
    final detailData = json['detail'];
    if (detailData != null && detailData is List) {
      for (var item in detailData) {
        if (item is Map<String, dynamic>) {
          try {
            detailList.add(ProductItem.fromJson(item));
          } catch (e) {
            log("Error parsing product item: $e");
          }
        }
      }
    }

    return ProductPayload(
      locCode: json['loc_code']?.toString(),
      locName: json['loc_name']?.toString(),
      detail: detailList,
    );
  }

  Map<String, dynamic> toJson() => {
        'loc_code': locCode,
        'loc_name': locName,
        'detail': detail.map((e) => e.toJson()).toList(),
      };
}

class ProductItem {
  final String? productCode;
  final String? productName;
  final double? productPrice;
  final String? oldSkuCode;
  final String? skuCode;
  final String? skuDesc;
  final String? oldProductCode;
  final int? qty;
  final String? lastUpdateTimestamp;
  final String? imageUrl;

  ProductItem({
    this.productCode,
    this.productName,
    this.productPrice,
    this.oldSkuCode,
    this.skuCode,
    this.skuDesc,
    this.oldProductCode,
    this.qty,
    this.lastUpdateTimestamp,
    this.imageUrl,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['product_price'];
    final double? parsedPrice = rawPrice is double
        ? rawPrice
        : double.tryParse(rawPrice?.toString() ?? '');

    final rawQty = json['qty'];
    final int? parsedQty = rawQty is int
        ? rawQty
        : int.tryParse(rawQty?.toString() ?? '');

    return ProductItem(
      productCode: json['product_code']?.toString(),
      productName: json['product_name']?.toString(),
      productPrice: parsedPrice,
      oldSkuCode: json['old_sku_code']?.toString(),
      skuCode: json['sku_code']?.toString(),
      skuDesc: json['sku_desc']?.toString(),
      oldProductCode: json['old_product_code']?.toString(),
      qty: parsedQty,
      lastUpdateTimestamp: json['last_update_timestamp']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_code': productCode,
        'product_name': productName,
        'product_price': productPrice,
        'old_sku_code': oldSkuCode,
        'sku_code': skuCode,
        'sku_desc': skuDesc,
        'old_product_code': oldProductCode,
        'qty': qty,
        'last_update_timestamp': lastUpdateTimestamp,
        'image_url': imageUrl,
      };

  String get displayName => productName ?? '--';
  String get displayPrice => productPrice != null
      ? productPrice!.toStringAsFixed(2)
      : '0.00';
  bool get inStock => (qty ?? 0) > 0;
}