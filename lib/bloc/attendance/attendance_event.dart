

import '../../api/models/request/PunchInOutRequestBody.dart';

abstract class PunchInEvent {}
class FetchPunchIn extends PunchInEvent {
  final PunchInOutRequestBody body;
  final String id;
  FetchPunchIn({required this.body,required this.id});
}


abstract class PunchOutEvent {}
class FetchPunchOut extends PunchOutEvent {
  final PunchInOutRequestBody body;
  final String id;
  FetchPunchOut({required this.body,required this.id});
}


abstract class LocationPingEvent {}
class FetchLocationPing extends LocationPingEvent {
  final PunchInOutRequestBody body;
  final String id;
  FetchLocationPing({required this.body,required this.id});
}