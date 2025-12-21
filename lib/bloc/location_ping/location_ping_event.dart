import 'package:apclassstone/api/models/request/PunchInOutRequestBody.dart';

abstract class LocationPingEvent {}

class PingLocation extends LocationPingEvent {
  final String userId;
  final PunchInOutRequestBody body;

  PingLocation({required this.userId, required this.body});
}

