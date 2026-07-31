import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';


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
    final password = await SecureStorageService.getOrCreateDbEncryptionKey();
    try {
      return await openDatabase(
        dbPath,
        password: password,
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _createSchema,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // Devices that installed the app before encryption was added have a
      // plain (unencrypted) database file — opening it with a password
      // fails. Fall back to a one-time migration instead of losing data.
      log('AppDatabase: encrypted open failed ($e), trying legacy-plain migration...');
      try {
        return await _migrateLegacyPlainDatabase(dbPath, password);
      } catch (e2) {
        // Neither the current key nor a plaintext read works — the file is
        // genuinely unrecoverable (e.g. the device's Keystore lost/rotated
        // the encryption key independently of app data, so the on-disk file
        // is real ciphertext for a key we no longer have). This is a local
        // cache/offline-queue database, not the system of record, so the
        // safe recovery is to drop it and start fresh rather than leave the
        // app permanently unable to start.
        log('AppDatabase: legacy-plain migration also failed ($e2), recreating database.');
        return _recreateDatabase(dbPath, password);
      }
    }
  }

  static Future<Database> _recreateDatabase(String dbPath, String password) async {
    for (final suffix in ['', '-wal', '-shm', '.encrypting']) {
      final file = File('$dbPath$suffix');
      if (await file.exists()) await file.delete();
    }
    return openDatabase(
      dbPath,
      password: password,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _onUpgrade,
    );
  }

  /// Opens the existing unencrypted database file, exports it into a new
  /// encrypted file via SQLCipher's documented `ATTACH` + `sqlcipher_export()`
  /// procedure (PRAGMA rekey is unreliable on a genuinely-plaintext file —
  /// SQLCipher itself points at this as the correct alternative), then
  /// swaps the encrypted copy into place. Preserves all existing data
  /// (including any not-yet-synced offline sales) instead of wiping it.
  static Future<Database> _migrateLegacyPlainDatabase(
    String dbPath,
    String password,
  ) async {
    final plainDb = await openDatabase(
      dbPath,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _onUpgrade,
    );

    final tempPath = '$dbPath.encrypting';
    final tempFile = File(tempPath);
    if (await tempFile.exists()) await tempFile.delete();

    await plainDb.execute("ATTACH DATABASE '$tempPath' AS encrypted KEY '$password'");
    // `execute()` maps to Android's execSQL, which rejects any statement
    // that returns a result set (including sqlcipher_export, which is a
    // SELECT) — must go through rawQuery instead.
    await plainDb.rawQuery("SELECT sqlcipher_export('encrypted')");
    await plainDb.execute('DETACH DATABASE encrypted');
    await plainDb.close();

    await File(dbPath).delete();
    await tempFile.rename(dbPath);
    log('AppDatabase: migrated legacy unencrypted database to SQLCipher.');

    return openDatabase(
      dbPath,
      password: password,
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
      CREATE TABLE IF NOT EXISTS api_cache (
        cache_key TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_config (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_customers (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        data TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS suspended_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_sales (
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
