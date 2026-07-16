import 'dart:convert';
import 'dart:developer';

import 'package:modfirstpos/core/database/app_database.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';

/// Offline-first storage for customers created on this device.
///
/// Local customers get a negative id (`-local_id`) so they can never collide
/// with server ids; once pushed to the backend the row is marked synced and
/// linked to its server id.
class CustomerLocalRepository {
  CustomerLocalRepository._();

  static Future<CustomerModel> addCustomer({
    required String fullName,
    required String phone,
    String? email,
    String? address,
  }) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().toIso8601String();

    final localId = await db.insert('local_customers', {
      'server_id': null,
      'data': '{}',
      'is_synced': 0,
      'created_at': now,
      'updated_at': now,
    });

    final customer = CustomerModel(
      id: -localId,
      fullName: fullName,
      phone: phone,
      email: (email == null || email.trim().isEmpty) ? null : email.trim(),
      address:
          (address == null || address.trim().isEmpty) ? null : address.trim(),
      role: 'customer',
      createdAt: now,
      isLocalOnly: true,
    );

    await db.update(
      'local_customers',
      {'data': jsonEncode(customer.toJson())},
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    return customer;
  }

  static Future<List<CustomerModel>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('local_customers', orderBy: 'local_id DESC');
    final customers = <CustomerModel>[];
    for (final row in rows) {
      try {
        final data = jsonDecode(row['data'] as String);
        if (data is Map<String, dynamic>) {
          customers.add(CustomerModel.fromJson(data));
        }
      } catch (e) {
        log('CustomerLocalRepository getAll parse error: $e');
      }
    }
    return customers;
  }

  static Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await AppDatabase.instance;
    return db.query(
      'local_customers',
      where: 'is_synced = 0',
      orderBy: 'local_id ASC',
    );
  }

  static Future<void> markSynced(int localId, {int? serverId}) async {
    final db = await AppDatabase.instance;
    await db.update(
      'local_customers',
      {
        'is_synced': 1,
        'server_id': serverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
