import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';

/// A complete POS session parked by the cashier, restorable exactly as it was.
class SuspendedOrderModel {
  final int? id;
  final CustomerModel? customer;
  final List<CartItemModel> items;
  final String discountInput;
  final double taxAmount;
  final String notes;
  final double total;
  final String createdAt;

  SuspendedOrderModel({
    this.id,
    this.customer,
    required this.items,
    this.discountInput = '',
    this.taxAmount = 0,
    this.notes = '',
    required this.total,
    required this.createdAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'customer': customer?.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'discount_input': discountInput,
        'tax_amount': taxAmount,
        'notes': notes,
        'total': total,
        'created_at': createdAt,
      };

  factory SuspendedOrderModel.fromJson(Map<String, dynamic> json, {int? id}) {
    final customerMap = JsonUtils.asMapOrNull(json['customer']);
    return SuspendedOrderModel(
      id: id,
      customer:
          customerMap != null ? CustomerModel.fromJson(customerMap) : null,
      items: JsonUtils.asModelList(json['items'], CartItemModel.fromJson),
      discountInput: JsonUtils.asString(json['discount_input']),
      taxAmount: JsonUtils.asDouble(json['tax_amount']),
      notes: JsonUtils.asString(json['notes']),
      total: JsonUtils.asDouble(json['total']),
      createdAt: JsonUtils.asString(json['created_at']),
    );
  }
}
