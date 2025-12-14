// import '../../api/models/api_models.dart';
//
// // Attendance States
// abstract class AttendanceState {}
//
// class AttendanceInitial extends AttendanceState {}
//
// class AttendanceLoading extends AttendanceState {}
//
// class PunchInSuccess extends AttendanceState {
//   final String message;
//   final DateTime timestamp;
//   final String? location;
//
//   PunchInSuccess({
//     required this.message,
//     required this.timestamp,
//     this.location,
//   });
// }
//
// class PunchOutSuccess extends AttendanceState {
//   final String message;
//   final DateTime timestamp;
//   final String? location;
//
//   PunchOutSuccess({
//     required this.message,
//     required this.timestamp,
//     this.location,
//   });
// }
//
// class AttendanceHistoryLoaded extends AttendanceState {
//   final List<AttendanceRecord> attendanceRecords;
//
//   AttendanceHistoryLoaded({required this.attendanceRecords});
// }
//
// class AttendanceError extends AttendanceState {
//   final String error;
//
//   AttendanceError(this.error);
// }
