import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}

class PunchQueued extends AttendanceState {
  final dynamic record;
  PunchQueued(this.record);
}

class PunchSuccess extends AttendanceState {
  final dynamic record;
  PunchSuccess(this.record);
}

class PunchFailure extends AttendanceState {
  final String error;
  PunchFailure(this.error);
}

class LocalPunchesLoaded extends AttendanceState {
  final List<dynamic> punches;
  LocalPunchesLoaded(this.punches);
}



abstract class LocationPingState {}
class LocationPingInitial extends LocationPingState {}
class LocationPingLoading extends LocationPingState {}
class LocationPingLoaded extends LocationPingState {
  final ApiCommonResponseBody response;
  LocationPingLoaded({required this.response});
}
class LocationPingError extends LocationPingState {
  final String message;
  LocationPingError({required this.message});
}