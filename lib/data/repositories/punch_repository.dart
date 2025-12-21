import 'package:apclassstone/api/integration/api_integration.dart';
import 'package:apclassstone/api/models/request/PunchInOutRequestBody.dart';
import 'package:apclassstone/data/local/database_helper.dart';
import 'package:apclassstone/data/models/punch_record.dart';

class PunchRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<PunchRecord> createLocalRecord({
    required String userId,
    required String type,
    PunchInOutRequestBody? body,
  }) async {
    final record = PunchRecord(
      userId: userId,
      type: type,
      lat: body?.lat,
      lng: body?.lng,
      accuracyM: body?.accuracyM,
      deviceId: body?.deviceId,
      deviceModel: body?.deviceModel,
      capturedAt: body?.capturedAt ?? DateTime.now().toUtc().toIso8601String(),
      status: 'queued',
    );

    final db = await _dbHelper.database;
    await db.insert('punch_records', record.toMap());
    return record;
  }

  Future<List<PunchRecord>> getLocalPunches({required String userId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'punch_records',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAtLocal DESC',
    );

    return maps.map((m) => PunchRecord.fromMap(m)).toList();
  }

  Future<List<PunchRecord>> getAllLocalPunches() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'punch_records',
      orderBy: 'createdAtLocal DESC',
    );

    return maps.map((m) => PunchRecord.fromMap(m)).toList();
  }

  Future<void> markSynced(String localId, {String? remoteId}) async {
    final db = await _dbHelper.database;
    await db.update(
      'punch_records',
      {'status': 'success', 'remoteId': remoteId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markFailed(String localId, String error) async {
    final db = await _dbHelper.database;
    await db.update(
      'punch_records',
      {'status': 'failed', 'errorMessage': error},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<PunchRecord> punchIn(String userId, PunchInOutRequestBody body) async {
    // create local record first
    final record = await createLocalRecord(userId: userId, type: 'in', body: body);

    try {
      final res = await ApiIntegration.punchIn(body);
      if (res.status == true) {
        // res.data might be a map containing id; handle safely
        final remoteId = res.data is Map && res.data?.sessionId != null ? res.data?.sessionId.toString() : null;
        await markSynced(record.id, remoteId: remoteId);
      } else {
        await markFailed(record.id, res.message ?? 'Unknown error');
      }
    } catch (e) {
      // network or other error - keep queued (mark failed for visibility)
      await markFailed(record.id, e.toString());
    }

    return record;
  }

  Future<PunchRecord> punchOut(String userId, PunchInOutRequestBody body) async {
    final record = await createLocalRecord(userId: userId, type: 'out', body: body);

    try {
      final res = await ApiIntegration.punchOut(body);
      if (res.status == true) {
        final remoteId = res.data is Map && res.data?.sessionId != null ? res.data?.sessionId.toString() : null;
        await markSynced(record.id, remoteId: remoteId);
      } else {
        await markFailed(record.id, res.message ?? 'Unknown error');
      }
    } catch (e) {
      await markFailed(record.id, e.toString());
    }

    return record;
  }

  /// Store a periodic location ping (type = 'ping') into local punch_records table.
  /// This does not attempt to call the punch API; it only records the location locally
  /// so it can be displayed in SuperAdmin dashboard and synced later if desired.
  Future<PunchRecord> saveLocationPing(String userId, PunchInOutRequestBody body) async {
    final record = PunchRecord(
      userId: userId,
      type: 'ping',
      lat: body.lat,
      lng: body.lng,
      accuracyM: body.accuracyM,
      deviceId: body.deviceId,
      deviceModel: body.deviceModel,
      capturedAt: body.capturedAt ?? DateTime.now().toUtc().toIso8601String(),
      status: 'queued',
    );

    final db = await _dbHelper.database;
    await db.insert('punch_records', record.toMap());
    return record;
  }
}
