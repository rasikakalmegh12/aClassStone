import 'package:apclassstone/api/models/request/PunchInOutRequestBody.dart';

abstract class AttendanceEvent {}

class PunchInRequested extends AttendanceEvent {
  final String userId;
  final PunchInOutRequestBody body;

  PunchInRequested({required this.userId, required this.body});
}

class PunchOutRequested extends AttendanceEvent {
  final String userId;
  final PunchInOutRequestBody body;

  PunchOutRequested({required this.userId, required this.body});
}

class LoadLocalPunches extends AttendanceEvent {
  final String userId;
  LoadLocalPunches({required this.userId});
}


abstract class LocationPingEvent {}
class FetchLocationPing extends LocationPingEvent {
  final PunchInOutRequestBody body;

  FetchLocationPing({required this.body});
}