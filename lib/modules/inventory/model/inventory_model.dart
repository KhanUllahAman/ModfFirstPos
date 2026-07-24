import 'package:modfirstpos/core/utils/json_utils.dart';

/// Reasons accepted by the increase/decrease inventory endpoints.
enum InventoryReason {
  stockIn('STOCK_IN', 'Stock In'),
  stockOut('STOCK_OUT', 'Stock Out'),
  manualAdjustment('MANUAL_ADJUSTMENT', 'Manual Adjustment'),
  orderPlaced('ORDER_PLACED', 'Order Placed'),
  orderCancelled('ORDER_CANCELLED', 'Order Cancelled'),
  returned('RETURNED', 'Returned'),
  damaged('DAMAGED', 'Damaged');

  const InventoryReason(this.value, this.label);
  final String value;
  final String label;
}

class InventoryRecordModel {
  final int id;
  final int? productId;
  final int? variantId;
  final int quantity;
  final bool isActive;

  InventoryRecordModel({
    required this.id,
    this.productId,
    this.variantId,
    required this.quantity,
    this.isActive = true,
  });

  factory InventoryRecordModel.fromJson(Map<String, dynamic> json) {
    return InventoryRecordModel(
      id: JsonUtils.asInt(json['id']),
      productId: JsonUtils.asIntOrNull(json['product_id']),
      variantId: JsonUtils.asIntOrNull(json['variant_id']),
      quantity: JsonUtils.asInt(json['quantity']),
      isActive: JsonUtils.asBool(json['is_active'], fallback: true),
    );
  }
}

class InventoryResponse {
  final bool isSuccess;
  final String message;
  final InventoryRecordModel? payload;

  InventoryResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    final payload = JsonUtils.asMapOrNull(json['payload']);
    return InventoryResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payload != null ? InventoryRecordModel.fromJson(payload) : null,
    );
  }
}
