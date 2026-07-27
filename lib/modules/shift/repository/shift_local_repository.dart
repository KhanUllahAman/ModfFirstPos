import 'dart:convert';
import 'dart:developer';

import 'package:modfirstpos/core/database/app_database.dart';
import 'package:modfirstpos/core/utils/client_reference_generator.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

/// Offline-first shift storage. A shift's entire lifecycle (open -> close)
/// lives in the `pending_shifts` row identified by `client_reference`;
/// `is_synced`/`server_shift_id` are just sync-engine bookkeeping on top —
/// the row itself is always the source of truth for "is there a shift open
/// right now", synced or not.
class ShiftLocalRepository {
  ShiftLocalRepository._();

  static Future<Map<String, dynamic>> addOpen({
    required double openingFloat,
    String? openingNotes,
  }) async {
    final db = await AppDatabase.instance;
    final clientReference = await ClientReferenceGenerator.generate('shift');
    final now = DateTime.now();

    final data = {
      'client_reference': clientReference,
      'opened_at': now.toUtc().toIso8601String(),
      'opening_float': openingFloat,
      if (openingNotes != null && openingNotes.isNotEmpty)
        'opening_notes': openingNotes,
    };

    final localId = await db.insert('pending_shifts', {
      'client_reference': clientReference,
      'status': 'open',
      'data': jsonEncode(data),
      'is_synced': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return getById(localId);
  }

  /// Ensures a `pending_shifts` row exists for [shift] and returns it. A
  /// shift opened by this local-first flow always has one; a shift only
  /// known via the bootstrap `open_shift` fallback (e.g. already open
  /// before this device ever ran `openShift`) does not — this adopts it
  /// into local tracking on the spot so pause/resume/close always have a
  /// row to act on.
  static Future<Map<String, dynamic>> ensureLocalRow(ShiftModel shift) async {
    final db = await AppDatabase.instance;
    if (shift.id > 0) {
      final existing = await db.query(
        'pending_shifts',
        where: 'server_shift_id = ?',
        whereArgs: [shift.id],
        limit: 1,
      );
      if (existing.isNotEmpty) return existing.first;
    }

    final now = DateTime.now();
    final clientReference =
        await ClientReferenceGenerator.generate('shift-adopted');
    final data = {
      'client_reference': clientReference,
      'opened_at': shift.openedAt,
      'opening_float': shift.openingFloat,
      if (shift.openingNotes != null) 'opening_notes': shift.openingNotes,
    };
    final localId = await db.insert('pending_shifts', {
      'client_reference': clientReference,
      'status': 'open',
      'data': jsonEncode(data),
      'is_synced': shift.id > 0 ? 1 : 0,
      'server_shift_id': shift.id > 0 ? shift.id : null,
      'server_shift_code': shift.id > 0 ? shift.shiftCode : null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    return getById(localId);
  }

  /// Updates the shift's live business status (open/paused) without
  /// touching the `status` column, which only tracks the open/closed
  /// lifecycle used by [getCurrentOpenRow]'s query — a paused shift is
  /// still "the current shift".
  static Future<void> updateLiveStatus(int localId, String status) async {
    final db = await AppDatabase.instance;
    final row = await getById(localId);
    final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
    data['live_status'] = status;
    await db.update(
      'pending_shifts',
      {
        'data': jsonEncode(data),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  static Future<void> closeLocal({
    required int localId,
    required double countedCash,
    required double expectedCash,
    required double variance,
    String? closingNotes,
  }) async {
    final db = await AppDatabase.instance;
    final row = await getById(localId);
    final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
    final now = DateTime.now();

    data['closed_at'] = now.toUtc().toIso8601String();
    data['counted_cash'] = countedCash;
    data['expected_cash'] = expectedCash;
    data['variance'] = variance;
    if (closingNotes != null && closingNotes.isNotEmpty) {
      data['closing_notes'] = closingNotes;
    }

    await db.update(
      'pending_shifts',
      {
        'status': 'closed',
        'data': jsonEncode(data),
        'updated_at': now.toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  static Future<Map<String, dynamic>> getById(int localId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'pending_shifts',
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    return rows.first;
  }

  /// The shift currently "in progress" on this device — the latest row
  /// still in `open` status, synced or not.
  static Future<Map<String, dynamic>?> getCurrentOpenRow() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'pending_shifts',
      where: 'status = ?',
      whereArgs: ['open'],
      orderBy: 'local_id DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await AppDatabase.instance;
    return db.query(
      'pending_shifts',
      where: 'is_synced = 0',
      orderBy: 'local_id ASC',
    );
  }

  /// Sum of cash-payment offline orders taken while [shiftClientReference]
  /// was the active shift — used to compute expected cash on local close.
  static Future<double> cashCollectedForShift(String shiftClientReference) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'pending_orders',
      where: 'shift_client_reference = ?',
      whereArgs: [shiftClientReference],
    );
    double total = 0;
    for (final row in rows) {
      try {
        final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
        final sync = JsonUtils.asMap(data['sync']);
        final local = JsonUtils.asMap(data['local']);
        if (sync['payment_method'] == 'cash') {
          total += JsonUtils.asDouble(local['grand_total']);
        }
      } catch (e) {
        log('ShiftLocalRepository cashCollectedForShift parse error: $e');
      }
    }
    return total;
  }

  static Future<void> markSynced(
    int localId, {
    required int serverShiftId,
    required String serverShiftCode,
  }) async {
    final db = await AppDatabase.instance;
    await db.update(
      'pending_shifts',
      {
        'is_synced': 1,
        'server_shift_id': serverShiftId,
        'server_shift_code': serverShiftCode,
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
      'UPDATE pending_shifts SET sync_attempts = sync_attempts + 1, '
      'last_error = ?, updated_at = ? WHERE local_id = ?',
      [error, DateTime.now().toIso8601String(), localId],
    );
  }

  static ShiftModel rowToShiftModel(Map<String, dynamic> row) {
    final data = JsonUtils.asMap(jsonDecode(row['data'] as String));
    final localId = JsonUtils.asInt(row['local_id']);
    final serverShiftId = JsonUtils.asIntOrNull(row['server_shift_id']);
    final serverShiftCode = row['server_shift_code'] as String?;
    final clientReference = row['client_reference'] as String;
    final status = (data['live_status'] as String?) ?? (row['status'] as String);

    return ShiftModel.fromJson({
      'id': serverShiftId ?? -localId,
      'shift_code': serverShiftCode ?? 'PENDING-$clientReference',
      'status': status,
      'status_label': status[0].toUpperCase() + status.substring(1),
      'opening_float': data['opening_float'],
      'counted_cash': data['counted_cash'],
      'expected_cash': data['expected_cash'],
      'variance': data['variance'],
      'opened_at': data['opened_at'],
      'closed_at': data['closed_at'],
      'opening_notes': data['opening_notes'],
      'closing_notes': data['closing_notes'],
    });
  }
}
