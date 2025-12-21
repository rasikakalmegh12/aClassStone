import 'package:uuid/uuid.dart';

class PunchRecord {
  String id;
  String userId;
  String type; // 'in' or 'out'
  double? lat;
  double? lng;
  int? accuracyM;
  String? deviceId;
  String? deviceModel;
  String capturedAt; // ISO string
  String status; // 'queued', 'in_progress', 'success', 'failed'
  String? remoteId;
  String? errorMessage;
  String createdAtLocal; // ISO string

  PunchRecord({
    String? id,
    required this.userId,
    required this.type,
    this.lat,
    this.lng,
    this.accuracyM,
    this.deviceId,
    this.deviceModel,
    required this.capturedAt,
    this.status = 'queued',
    this.remoteId,
    this.errorMessage,
    String? createdAtLocal,
  })  : id = id ?? Uuid().v4(),
        createdAtLocal = createdAtLocal ?? DateTime.now().toUtc().toIso8601String();

  PunchRecord.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        type = map['type'],
        lat = map['lat'],
        lng = map['lng'],
        accuracyM = map['accuracyM'],
        deviceId = map['deviceId'],
        deviceModel = map['deviceModel'],
        capturedAt = map['capturedAt'],
        status = map['status'],
        remoteId = map['remoteId'],
        errorMessage = map['errorMessage'],
        createdAtLocal = map['createdAtLocal'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'lat': lat,
      'lng': lng,
      'accuracyM': accuracyM,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'capturedAt': capturedAt,
      'status': status,
      'remoteId': remoteId,
      'errorMessage': errorMessage,
      'createdAtLocal': createdAtLocal,
    };
  }
}

