// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../api/integration/api_integration.dart';
// import '../../api/models/api_models.dart';
//
// // ==================== ATTENDANCE EVENTS ====================
// abstract class AttendanceEvent {}
//
// class PunchInEvent extends AttendanceEvent {
//   final double? latitude;
//   final double? longitude;
//   final String? location;
//
//   PunchInEvent({
//     this.latitude,
//     this.longitude,
//     this.location,
//   });
// }
//
// class PunchOutEvent extends AttendanceEvent {
//   final double? latitude;
//   final double? longitude;
//   final String? location;
//
//   PunchOutEvent({
//     this.latitude,
//     this.longitude,
//     this.location,
//   });
// }
//
// class LoadAttendanceHistoryEvent extends AttendanceEvent {}
//
// class RefreshAttendanceEvent extends AttendanceEvent {}
//
// // ==================== ATTENDANCE STATES ====================
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
//
// // ==================== ATTENDANCE BLOC ====================
// class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
//   AttendanceBloc() : super(AttendanceInitial()) {
//     on<PunchInEvent>((event, emit) async {
//       emit(AttendanceLoading());
//       try {
//         final response = await ApiIntegration.punchIn(
//           latitude: event.latitude,
//           longitude: event.longitude,
//           location: event.location,
//         );
//
//         if (response.success && response.timestamp != null) {
//           emit(PunchInSuccess(
//             message: response.message,
//             timestamp: response.timestamp!,
//             location: response.location,
//           ));
//         } else {
//           emit(AttendanceError(response.message));
//         }
//       } catch (e) {
//         emit(AttendanceError('Failed to punch in: ${e.toString()}'));
//       }
//     });
//
//     on<PunchOutEvent>((event, emit) async {
//       emit(AttendanceLoading());
//       try {
//         final response = await ApiIntegration.punchOut(
//           latitude: event.latitude,
//           longitude: event.longitude,
//           location: event.location,
//         );
//
//         if (response.success && response.timestamp != null) {
//           emit(PunchOutSuccess(
//             message: response.message,
//             timestamp: response.timestamp!,
//             location: response.location,
//           ));
//         } else {
//           emit(AttendanceError(response.message));
//         }
//       } catch (e) {
//         emit(AttendanceError('Failed to punch out: ${e.toString()}'));
//       }
//     });
//
//     on<LoadAttendanceHistoryEvent>((event, emit) async {
//       emit(AttendanceLoading());
//       try {
//         final response = await ApiIntegration.getAttendanceHistory();
//
//         if (response.success) {
//           emit(AttendanceHistoryLoaded(
//             attendanceRecords: response.executive_history ?? []
//           ));
//         } else {
//           emit(AttendanceError(response.message));
//         }
//       } catch (e) {
//         emit(AttendanceError('Failed to load executive_history history: ${e.toString()}'));
//       }
//     });
//
//     on<RefreshAttendanceEvent>((event, emit) {
//       add(LoadAttendanceHistoryEvent());
//     });
//   }
// }
//
