import 'dart:convert';

import 'package:modfirstpos/core/database/app_database.dart';

/// Offline-first order queue for cash / bank_transfer / without_payment
/// sales — created entirely locally, pushed via `orders/pos/sync` once
/// online (mirrors `ShiftLocalRepository`'s pattern).
class PendingOrderRepository {
  PendingOrderRepository._();

  static Future<int> add({
    required String clientReference,
    String? shiftClientReference,
    required Map<String, dynamic> orderJson,
  }) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().toIso8601String();
    return db.insert('pending_orders', {
      'client_reference': clientReference,
      'shift_client_reference': shiftClientReference,
      'data': jsonEncode(orderJson),
      'is_synced': 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  static Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await AppDatabase.instance;
    return db.query(
      'pending_orders',
      where: 'is_synced = 0',
      orderBy: 'local_id ASC',
    );
  }

  /// All offline orders (synced or not) taken during [shiftClientReference]
  /// — used to build the local shift-closing receipt without a server call.
  static Future<List<Map<String, dynamic>>> getByShiftReference(
    String shiftClientReference,
  ) async {
    final db = await AppDatabase.instance;
    return db.query(
      'pending_orders',
      where: 'shift_client_reference = ?',
      whereArgs: [shiftClientReference],
      orderBy: 'local_id ASC',
    );
  }

  static Future<void> markSynced(int localId, {String? serverOrderCode}) async {
    final db = await AppDatabase.instance;
    await db.update(
      'pending_orders',
      {
        'is_synced': 1,
        'server_order_code': serverOrderCode,
        'last_error': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  static Future<void> markFailed(int localId, String error) async {
    final db = await AppDatabase.instance;
    await db.rawUpdate(
      'UPDATE pending_orders SET sync_attempts = sync_attempts + 1, '
      'last_error = ?, updated_at = ? WHERE local_id = ?',
      [error, DateTime.now().toIso8601String(), localId],
    );
  }
}
