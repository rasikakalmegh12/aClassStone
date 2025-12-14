// Attendance Events
abstract class AttendanceEvent {}

class PunchInEvent extends AttendanceEvent {
  final double? latitude;
  final double? longitude;
  final String? location;

  PunchInEvent({
    this.latitude,
    this.longitude,
    this.location,
  });
}

class PunchOutEvent extends AttendanceEvent {
  final double? latitude;
  final double? longitude;
  final String? location;

  PunchOutEvent({
    this.latitude,
    this.longitude,
    this.location,
  });
}

class LoadAttendanceHistoryEvent extends AttendanceEvent {}

class RefreshAttendanceEvent extends AttendanceEvent {}
