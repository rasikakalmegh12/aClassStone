// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'attendance_event.dart';
// import 'attendance_state.dart';
// import '../../api/integration/api_integration.dart';
//
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
//             attendanceRecords: response.attendance ?? []
//           ));
//         } else {
//           emit(AttendanceError(response.message));
//         }
//       } catch (e) {
//         emit(AttendanceError('Failed to load attendance history: ${e.toString()}'));
//       }
//     });
//
//     on<RefreshAttendanceEvent>((event, emit) {
//       add(LoadAttendanceHistoryEvent());
//     });
//   }
// }
