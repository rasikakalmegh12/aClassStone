import 'package:apclassstone/data/models/punch_record.dart';

abstract class LocationPingState {}
class LocationPingInitial extends LocationPingState {}
class LocationPingInProgress extends LocationPingState {}
class LocationPingSuccess extends LocationPingState {
  final PunchRecord record;
  LocationPingSuccess(this.record);
}
class LocationPingFailure extends LocationPingState {
  final String message;
  LocationPingFailure(this.message);
}

