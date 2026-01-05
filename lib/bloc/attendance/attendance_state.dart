import 'package:apclassstone/api/models/response/ExecutiveAttendanceResponseBody.dart';
import 'package:apclassstone/api/models/response/PunchInOutResponseBody.dart';

import '../../api/models/response/ApiCommonResponseBody.dart';
import '../../api/models/response/ExecutiveAttendanceMonthlyResponseBody.dart';
import '../../api/models/response/ExecutiveTrackingByDaysResponse.dart';

abstract class PunchInState {}
class PunchInInitial extends PunchInState {}
class PunchInLoading extends PunchInState {}
class PunchInLoaded extends PunchInState {
  final PunchInOutResponseBody response;
  PunchInLoaded({required this.response});
}
class PunchInError extends PunchInState {
  final String message;
  PunchInError({required this.message});
}


abstract class PunchOutState {}
class PunchOutInitial extends PunchOutState {}
class PunchOutLoading extends PunchOutState {}
class PunchOutLoaded extends PunchOutState {
  final PunchInOutResponseBody response;
  PunchOutLoaded({required this.response});
}
class PunchOutError extends PunchOutState {
  final String message;
  PunchOutError({required this.message});
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

abstract class ExecutiveAttendanceState {}
class ExecutiveAttendanceInitial extends ExecutiveAttendanceState {}
class ExecutiveAttendanceLoading extends ExecutiveAttendanceState {}
class ExecutiveAttendanceLoaded extends ExecutiveAttendanceState {
  final ExecutiveAttendanceResponseBody response;
  ExecutiveAttendanceLoaded({required this.response});
}
class ExecutiveAttendanceError extends ExecutiveAttendanceState {
  final String message;
  ExecutiveAttendanceError({required this.message});
}


abstract class ExecutiveTrackingState {}
class ExecutiveTrackingInitial extends ExecutiveTrackingState {}
class ExecutiveTrackingLoading extends ExecutiveTrackingState {
  final bool showLoader; // new: UI should show loader only if true
  ExecutiveTrackingLoading({this.showLoader = false});
}
class ExecutiveTrackingLoaded extends ExecutiveTrackingState {
  final ExecutiveTrackingByDaysResponse response;
  ExecutiveTrackingLoaded({required this.response});
}
class ExecutiveTrackingError extends ExecutiveTrackingState {
  final String message;
  ExecutiveTrackingError({required this.message});
}


abstract class AttendanceTrackingMonthlyState {}
class EAttendanceTrackingMonthlyInitial extends AttendanceTrackingMonthlyState {}
class AttendanceTrackingMonthlyLoading extends AttendanceTrackingMonthlyState {
  final bool showLoader; // new: UI should show loader only if true
  AttendanceTrackingMonthlyLoading({this.showLoader = false});
}
class AttendanceTrackingMonthlyLoaded extends AttendanceTrackingMonthlyState {
  final ExecutiveAttendanceMonthlyResponseBody response;
  AttendanceTrackingMonthlyLoaded({required this.response});
}
class AttendanceTrackingMonthlyError extends AttendanceTrackingMonthlyState {
  final String message;
  AttendanceTrackingMonthlyError({required this.message});
}