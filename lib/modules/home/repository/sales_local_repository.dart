import 'dart:convert';
import 'dart:developer';

import 'package:modfirstpos/core/database/app_database.dart';
import 'package:modfirstpos/core/database/key_value_store.dart';

/// Offline-first persistence for completed sales.
///
/// Every sale is recorded locally first (with a locally generated invoice
/// number) and pushed to the backend by the sync service when connectivity
/// allows.
class SalesLocalRepository {
  SalesLocalRepository._();

  static const _invoiceCounterKey = 'invoice_counter';

  /// Generates the next sequential invoice number, e.g. `INV-20260716-0042`.
  /// Works fully offline.
  static Future<String> nextInvoiceNumber() async {
    final raw = await KeyValueStore.getString(_invoiceCounterKey);
    final next = (int.tryParse(raw ?? '') ?? 0) + 1;
    await KeyValueStore.setString(_invoiceCounterKey, next.toString());
    final now = DateTime.now();
    final date = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return 'INV-$date-${next.toString().padLeft(4, '0')}';
  }

  /// Records a completed sale locally. Returns the invoice number.
  static Future<String> recordSale(Map<String, dynamic> saleJson) async {
    final invoiceNumber = await nextInvoiceNumber();
    saleJson['invoice_number'] = invoiceNumber;
    final db = await AppDatabase.instance;
    await db.insert('pending_sales', {
      'invoice_number': invoiceNumber,
      'data': jsonEncode(saleJson),
      'is_synced': 0,
      'sync_attempts': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    return invoiceNumber;
  }

  static Future<List<Map<String, dynamic>>> getUnsynced({int limit = 20}) async {
    final db = await AppDatabase.instance;
    return db.query(
      'pending_sales',
      where: 'is_synced = 0',
      orderBy: 'id ASC',
      limit: limit,
    );
  }

  static Future<void> markSynced(int id) async {
    final db = await AppDatabase.instance;
    await db.update(
      'pending_sales',
      {'is_synced': 1, 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markFailed(int id, String error) async {
    try {
      final db = await AppDatabase.instance;
      await db.rawUpdate(
        'UPDATE pending_sales SET sync_attempts = sync_attempts + 1, '
        'last_error = ? WHERE id = ?',
        [error, id],
      );
    } catch (e) {
      log('SalesLocalRepository markFailed error: $e');
    }
  }
}
