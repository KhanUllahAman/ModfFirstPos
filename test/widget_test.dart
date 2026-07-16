// Unit tests for the defensive JSON utilities and POS serialization models.

import 'package:flutter_test/flutter_test.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/home/model/suspended_order_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';

void main() {
  group('JsonUtils', () {
    test('parses ints from mixed backend types', () {
      expect(JsonUtils.asInt('1'), 1);
      expect(JsonUtils.asInt(1), 1);
      expect(JsonUtils.asInt(1.0), 1);
      expect(JsonUtils.asInt('1.0'), 1);
      expect(JsonUtils.asInt(null), 0);
      expect(JsonUtils.asIntOrNull('abc'), isNull);
    });

    test('parses doubles from mixed backend types', () {
      expect(JsonUtils.asDouble('12.5'), 12.5);
      expect(JsonUtils.asDouble(12), 12.0);
      expect(JsonUtils.asDouble(null), 0.0);
      expect(JsonUtils.asDoubleOrNull('x'), isNull);
    });

    test('parses bools from mixed backend types', () {
      expect(JsonUtils.asBool(true), isTrue);
      expect(JsonUtils.asBool('true'), isTrue);
      expect(JsonUtils.asBool('1'), isTrue);
      expect(JsonUtils.asBool(1), isTrue);
      expect(JsonUtils.asBool(0), isFalse);
      expect(JsonUtils.asBool(null), isFalse);
      expect(JsonUtils.asBoolOrNull('weird'), isNull);
    });

    test('asModelList skips malformed entries', () {
      final list = JsonUtils.asModelList(
        [
          {'id': 1},
          'not-a-map',
          null,
          {'id': '2'},
        ],
        (json) => JsonUtils.asInt(json['id']),
      );
      expect(list, [1, 2]);
    });
  });

  group('Model safety', () {
    test('ProductModel tolerates type drift', () {
      final product = ProductModel.fromJson({
        'id': '7',
        'name': 123,
        'base_price': 99,
        'sale_price': '49.5',
        'is_active': 'true',
        'variants': 'oops',
        'images': null,
      });
      expect(product.id, 7);
      expect(product.effectivePrice, 49.5);
      expect(product.isActive, isTrue);
      expect(product.variants, isEmpty);
    });

    test('CustomerModel round-trips through JSON', () {
      final customer = CustomerModel(
        id: -3,
        fullName: 'Walk In',
        phone: '0300123',
        address: 'Street 1',
        isLocalOnly: true,
      );
      final restored = CustomerModel.fromJson(customer.toJson());
      expect(restored.id, -3);
      expect(restored.fullName, 'Walk In');
      expect(restored.address, 'Street 1');
      expect(restored.isLocalOnly, isTrue);
    });
  });

  group('SuspendedOrderModel', () {
    test('restores an order exactly as it was', () {
      final order = SuspendedOrderModel(
        customer: CustomerModel(id: 1, fullName: 'Test'),
        items: [
          CartItemModel(
            product: CartProduct(
              name: 'Mug',
              skuCode: 'MUG-1',
              amount: 250,
              unitPrice: 250,
            ),
            quantity: 3,
          ),
        ],
        discountInput: '50',
        total: 700,
        createdAt: '2026-07-16T10:00:00',
      );

      final restored = SuspendedOrderModel.fromJson(order.toJson(), id: 9);
      expect(restored.id, 9);
      expect(restored.customer?.fullName, 'Test');
      expect(restored.items.single.product.skuCode, 'MUG-1');
      expect(restored.items.single.quantity, 3);
      expect(restored.discountInput, '50');
      expect(restored.total, 700);
      expect(restored.itemCount, 3);
    });
  });
}
