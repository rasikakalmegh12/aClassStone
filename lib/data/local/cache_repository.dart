import 'package:sqflite/sqflite.dart';

import '../models/cached_response.dart';
import 'database_helper.dart';

/// Repository for managing cached API responses
class CacheRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Save cached response
  Future<void> saveCachedResponse(CachedResponse response) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.cachedResponseTable,
      response.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached response by endpoint
  Future<CachedResponse?> getCachedResponse(String endpoint) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.cachedResponseTable,
      where: 'endpoint = ?',
      whereArgs: [endpoint],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final cached = CachedResponse.fromMap(result.first);
    // Return only if cache is still valid
    return cached.isValid() ? cached : null;
  }

  /// Get all cached responses
  Future<List<CachedResponse>> getAllCachedResponses() async {
    final db = await _dbHelper.database;
    final result = await db.query(DatabaseHelper.cachedResponseTable);
    return result
        .map((map) => CachedResponse.fromMap(map))
        .where((cached) => cached.isValid())
        .toList();
  }

  /// Delete cached response by endpoint
  Future<void> deleteCachedResponse(String endpoint) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.cachedResponseTable,
      where: 'endpoint = ?',
      whereArgs: [endpoint],
    );
  }

  /// Delete expired cache entries
  Future<void> deleteExpiredCache() async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.cachedResponseTable,
      where: 'expiresAt IS NOT NULL AND expiresAt < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseHelper.cachedResponseTable);
  }

  /// Update cache expiry time (useful for refreshing cache duration)
  Future<void> updateCacheExpiry(String endpoint, DateTime newExpiry) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.cachedResponseTable,
      {'expiresAt': newExpiry.toIso8601String()},
      where: 'endpoint = ?',
      whereArgs: [endpoint],
    );
  }
}

