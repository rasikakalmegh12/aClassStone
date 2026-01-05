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

abstract class ExecutiveAttendanceEvent {}
class FetchExecutiveAttendance extends ExecutiveAttendanceEvent {
  final String  date;

  FetchExecutiveAttendance({required this.date});
}


abstract class ExecutiveTrackingEvent {}
class FetchExecutiveTracking extends ExecutiveTrackingEvent {
  final String userId;
  final String  date;
  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchExecutiveTracking({required this.date, required this.userId, this.showLoader = false});
}


abstract class AttendanceTrackingMonthlyEvent {}
class FetchAttendanceTrackingMonthly extends AttendanceTrackingMonthlyEvent {
  final String userId;
  final String  fromDate;
  final String  toDate;
  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchAttendanceTrackingMonthly({required this.userId, this.showLoader = false, required this.fromDate, required this.toDate});
}