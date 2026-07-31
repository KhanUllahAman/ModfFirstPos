import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modfirstpos/core/database/app_database.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// SQLite-backed key/value store for cached API responses and non-secret
/// configuration. Transparently migrates values previously kept in Flutter
/// Secure Storage (the old cache backend) on first read.
class KeyValueStore {
  KeyValueStore._();

  static const _legacyStorage = FlutterSecureStorage();

  // ---------------------------------------------------------------- config

  static Future<void> setString(String key, String value) async {
    final db = await AppDatabase.instance;
    await db.insert(
      'app_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getString(String key) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'app_config',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['value'] as String?;

    // One-time migration from the legacy secure-storage backend.
    try {
      final legacy = await _legacyStorage.read(key: key);
      if (legacy != null) {
        await setString(key, legacy);
        await _legacyStorage.delete(key: key);
        return legacy;
      }
    } catch (e) {
      log('KeyValueStore legacy read error for $key: $e');
    }
    return null;
  }

  static Future<void> remove(String key) async {
    final db = await AppDatabase.instance;
    await db.delete('app_config', where: 'key = ?', whereArgs: [key]);
  }

  // ------------------------------------------------------------- api cache

  static Future<void> setJsonCache(String key, Map<String, dynamic> json) async {
    try {
      final db = await AppDatabase.instance;
      await db.insert(
        'api_cache',
        {
          'cache_key': key,
          'payload': jsonEncode(json),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      log('KeyValueStore setJsonCache error for $key: $e');
    }
  }

  static Future<Map<String, dynamic>?> getJsonCache(String key) async {
    try {
      final db = await AppDatabase.instance;
      final rows = await db.query(
        'api_cache',
        columns: ['payload'],
        where: 'cache_key = ?',
        whereArgs: [key],
        limit: 1,
      );
      String? raw;
      if (rows.isNotEmpty) {
        raw = rows.first['payload'] as String?;
      } else {
        // One-time migration of caches previously written to secure storage.
        raw = await _legacyStorage.read(key: key);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            await setJsonCache(key, decoded);
          }
          await _legacyStorage.delete(key: key);
        }
      }
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      log('KeyValueStore getJsonCache error for $key: $e');
      return null;
    }
  }

  static Future<void> removeJsonCache(String key) async {
    try {
      final db = await AppDatabase.instance;
      await db.delete('api_cache', where: 'cache_key = ?', whereArgs: [key]);
    } catch (e) {
      log('KeyValueStore removeJsonCache error for $key: $e');
    }
  }

  static Future<void> removeJsonCacheByPrefix(String prefix) async {
    try {
      final db = await AppDatabase.instance;
      await db.delete(
        'api_cache',
        where: 'cache_key LIKE ?',
        whereArgs: ['$prefix%'],
      );
    } catch (e) {
      log('KeyValueStore removeJsonCacheByPrefix error for $prefix: $e');
    }
  }
}
