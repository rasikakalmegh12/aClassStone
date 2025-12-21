import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for managing local cache and queue
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  // Table names
  static const String cachedResponseTable = 'cached_responses';
  static const String queuedRequestTable = 'queued_requests';
  static const String punchRecordsTable = 'punch_records';

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'apclassstone.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create cached responses table
    await db.execute('''
      CREATE TABLE $cachedResponseTable(
        id TEXT PRIMARY KEY,
        endpoint TEXT NOT NULL,
        responseData TEXT,
        statusCode INTEGER NOT NULL,
        cachedAt TEXT NOT NULL,
        expiresAt TEXT,
        requestMethod TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create queued requests table
    await db.execute('''
      CREATE TABLE $queuedRequestTable(
        id TEXT PRIMARY KEY,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        requestBody TEXT,
        headers TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        attemptedAt TEXT,
        retryCount INTEGER DEFAULT 0,
        maxRetries INTEGER DEFAULT 5,
        errorMessage TEXT,
        userId TEXT,
        metadata TEXT,
        createdAtLocal TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create punch_records table
    await db.execute('''
    CREATE TABLE $punchRecordsTable (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      type TEXT NOT NULL,
      lat INTEGER,
      lng INTEGER,
      accuracyM INTEGER,
      deviceId TEXT,
      deviceModel TEXT,
      capturedAt TEXT NOT NULL,
      status TEXT NOT NULL,
      remoteId TEXT,
      errorMessage TEXT,
      createdAtLocal TEXT NOT NULL
    );
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_queue_status ON $queuedRequestTable(status)');
    await db.execute('CREATE INDEX idx_queue_created ON $queuedRequestTable(createdAt)');
    await db.execute('CREATE INDEX idx_cache_endpoint ON $cachedResponseTable(endpoint)');
    await db.execute('CREATE INDEX idx_cache_expires ON $cachedResponseTable(expiresAt)');
    await db.execute('CREATE INDEX idx_punch_user ON $punchRecordsTable(userId)');
    await db.execute('CREATE INDEX idx_punch_status ON $punchRecordsTable(status)');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    // If upgrading from version 1 to 2, create punch_records table
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $punchRecordsTable (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        lat INTEGER,
        lng INTEGER,
        accuracyM INTEGER,
        deviceId TEXT,
        deviceModel TEXT,
        capturedAt TEXT NOT NULL,
        status TEXT NOT NULL,
        remoteId TEXT,
        errorMessage TEXT,
        createdAtLocal TEXT NOT NULL
      );
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_punch_user ON $punchRecordsTable(userId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_punch_status ON $punchRecordsTable(status)');
    }
  }

  /// Close database
  Future<void> close() async {
    _database?.close();
    _database = null;
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(cachedResponseTable);
    await db.delete(queuedRequestTable);
    await db.delete(punchRecordsTable);
  }

  /// Delete cached response data
  Future<void> clearCachedResponses() async {
    final db = await database;
    await db.delete(cachedResponseTable);
  }

  /// Delete old cache entries
  Future<void> clearExpiredCache() async {
    final db = await database;
    await db.delete(
      cachedResponseTable,
      where: 'expiresAt IS NOT NULL AND expiresAt < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }
}
