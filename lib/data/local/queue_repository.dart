import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/queued_request.dart';
import 'database_helper.dart';

/// Repository for managing queued API requests
class QueueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add request to queue
  Future<void> addToQueue(QueuedRequest request) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.queuedRequestTable,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending requests
  Future<List<QueuedRequest>> getPendingRequests() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.queuedRequestTable,
      where: 'status IN (?, ?)',
      whereArgs: ['pending', 'retrying'],
      orderBy: 'createdAt ASC',
    );
    return result.map((map) => QueuedRequest.fromMap(map)).toList();
  }

  /// Get all queued requests
  Future<List<QueuedRequest>> getAllQueuedRequests() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.queuedRequestTable,
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => QueuedRequest.fromMap(map)).toList();
  }

  /// Get queued requests by user
  Future<List<QueuedRequest>> getQueuedRequestsByUser(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.queuedRequestTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => QueuedRequest.fromMap(map)).toList();
  }

  /// Get request by ID
  Future<QueuedRequest?> getRequestById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      DatabaseHelper.queuedRequestTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return QueuedRequest.fromMap(result.first);
  }

  /// Update request status
  Future<void> updateRequestStatus(String id, QueueRequestStatus status) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.queuedRequestTable,
      {
        'status': status.toString().split('.').last,
        'attemptedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update request with retry info
  Future<void> updateRequestRetry(String id, QueueRequestStatus status, String? errorMessage) async {
    final db = await _dbHelper.database;
    final request = await getRequestById(id);
    if (request == null) return;

    await db.update(
      DatabaseHelper.queuedRequestTable,
      {
        'status': status.toString().split('.').last,
        'retryCount': request.retryCount + 1,
        'errorMessage': errorMessage,
        'attemptedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete request from queue
  Future<void> deleteFromQueue(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.queuedRequestTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all processed requests
  Future<void> deleteProcessedRequests() async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.queuedRequestTable,
      where: 'status = ?',
      whereArgs: ['success'],
    );
  }

  /// Delete requests older than specified days
  Future<void> deleteOldRequests(int days) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    await db.delete(
      DatabaseHelper.queuedRequestTable,
      where: 'createdAt < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Get queue statistics
  Future<QueueStatistics> getQueueStatistics() async {
    final db = await _dbHelper.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.queuedRequestTable}',
    );
    final totalCount = Sqflite.firstIntValue(totalResult) ?? 0;

    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.queuedRequestTable} WHERE status IN (?, ?)',
      ['pending', 'retrying'],
    );
    final pendingCount = Sqflite.firstIntValue(pendingResult) ?? 0;

    final failedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.queuedRequestTable} WHERE status = ?',
      ['failed'],
    );
    final failedCount = Sqflite.firstIntValue(failedResult) ?? 0;

    final successResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.queuedRequestTable} WHERE status = ?',
      ['success'],
    );
    final successCount = Sqflite.firstIntValue(successResult) ?? 0;

    return QueueStatistics(
      totalCount: totalCount,
      pendingCount: pendingCount,
      failedCount: failedCount,
      successCount: successCount,
    );
  }

  /// Clear all queue
  Future<void> clearAllQueue() async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseHelper.queuedRequestTable);
  }
}

/// Statistics about the request queue
class QueueStatistics {
  final int totalCount;
  final int pendingCount;
  final int failedCount;
  final int successCount;

  QueueStatistics({
    required this.totalCount,
    required this.pendingCount,
    required this.failedCount,
    required this.successCount,
  });

  int get processingCount => totalCount - successCount - failedCount;
}

