import 'dart:developer';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Application-wide SQLite database (offline-first source of truth).
///
/// Bulk/business data (cached API responses, customers, suspended orders,
/// pending sales, invoice counters, configuration) lives here. Flutter Secure
/// Storage is reserved for secrets only (tokens, credentials).
class AppDatabase {
  AppDatabase._();

  static const int _version = 1;
  static const String _dbName = 'modfirstpos.db';

  static Database? _database;

  static Future<Database> get instance async {
    _database ??= await _open();
    return _database!;
  }

  static Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    // Raw API response cache, keyed by logical cache key.
    await db.execute('''
      CREATE TABLE api_cache (
        cache_key TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Non-secret key/value configuration (website settings, invoice counter).
    await db.execute('''
      CREATE TABLE app_config (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Customers created on this device while offline (or awaiting push).
    await db.execute('''
      CREATE TABLE local_customers (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        data TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Complete order sessions parked by the cashier.
    await db.execute('''
      CREATE TABLE suspended_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Completed sales awaiting upload to the backend.
    await db.execute('''
      CREATE TABLE pending_sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL,
        data TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        sync_attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    log('AppDatabase: schema v$version created');
  }

  /// Closes the database (tests / teardown).
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
