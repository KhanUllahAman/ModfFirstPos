import 'dart:developer';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';


class AppDatabase {
  AppDatabase._();

  static const int _version = 2;
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
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createOfflineSyncTables(db);
    }
    log('AppDatabase: upgraded v$oldVersion -> v$newVersion');
  }

  static Future<void> _createOfflineSyncTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_shifts (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_reference TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL,
        data TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_shift_id INTEGER,
        server_shift_code TEXT,
        sync_attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_orders (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_reference TEXT NOT NULL UNIQUE,
        shift_client_reference TEXT,
        data TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_order_code TEXT,
        sync_attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE api_cache (
        cache_key TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_config (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

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

    await db.execute('''
      CREATE TABLE suspended_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

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

    await _createOfflineSyncTables(db);

    log('AppDatabase: schema v$version created');
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
