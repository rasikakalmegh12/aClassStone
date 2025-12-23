


import 'package:apclassstone/api/models/response/PunchInOutResponseBody.dart';

import '../../api/models/response/ApiCommonResponseBody.dart';

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