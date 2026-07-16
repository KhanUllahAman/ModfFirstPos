import 'dart:convert';
import 'dart:developer';

import 'package:modfirstpos/core/database/app_database.dart';
import 'package:modfirstpos/modules/home/model/suspended_order_model.dart';

/// SQLite persistence for suspended POS sessions (offline-first).
class SuspendedOrderRepository {
  SuspendedOrderRepository._();

  static Future<int> suspend(SuspendedOrderModel order) async {
    final db = await AppDatabase.instance;
    return db.insert('suspended_orders', {
      'data': jsonEncode(order.toJson()),
      'created_at': order.createdAt,
    });
  }

  static Future<List<SuspendedOrderModel>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('suspended_orders', orderBy: 'id DESC');
    final orders = <SuspendedOrderModel>[];
    for (final row in rows) {
      try {
        final data = jsonDecode(row['data'] as String);
        if (data is Map<String, dynamic>) {
          orders.add(SuspendedOrderModel.fromJson(data, id: row['id'] as int?));
        }
      } catch (e) {
        log('SuspendedOrderRepository getAll parse error: $e');
      }
    }
    return orders;
  }

  static Future<void> remove(int id) async {
    final db = await AppDatabase.instance;
    await db.delete('suspended_orders', where: 'id = ?', whereArgs: [id]);
  }
}
