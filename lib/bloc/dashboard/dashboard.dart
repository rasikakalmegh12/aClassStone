// ...existing commented code...

// Export active dashboard bloc and events/states
export 'dashboard_bloc.dart';
export 'dashboard_event.dart';
export 'dashboard_state.dart';
//
// // ==================== DASHBOARD EVENTS ====================
// abstract class DashboardEvent {}
//
// class LoadExecutiveDashboardEvent extends DashboardEvent {}
//
// class LoadAdminDashboardEvent extends DashboardEvent {}
//
// class LoadSuperAdminDashboardEvent extends DashboardEvent {}
//
// class RefreshDashboardEvent extends DashboardEvent {}
//
// // ==================== DASHBOARD STATES ====================
// abstract class DashboardState {}
//
// class DashboardInitial extends DashboardState {}
//
// class DashboardLoading extends DashboardState {}
//
// class ExecutiveDashboardLoaded extends DashboardState {
//   final DashboardStats? stats;
//   final List<Meeting>? recentMeetings;
//   final AttendanceRecord? todayAttendance;
//
//   ExecutiveDashboardLoaded({
//     this.stats,
//     this.recentMeetings,
//     this.todayAttendance,
//   });
// }
//
// class AdminDashboardLoaded extends DashboardState {
//   final DashboardStats? stats;
//   final List<User>? recentEmployees;
//   final List<Meeting>? recentMeetings;
//
//   AdminDashboardLoaded({
//     this.stats,
//     this.recentEmployees,
//     this.recentMeetings,
//   });
// }
//
// class SuperAdminDashboardLoaded extends DashboardState {
//   final DashboardStats? stats;
//   final List<PendingRegistration>? pendingRegistrations;
//   final List<User>? recentUsers;
//
//   SuperAdminDashboardLoaded({
//     this.stats,
//     this.pendingRegistrations,
//     this.recentUsers,
//   });
// }
//
// class DashboardError extends DashboardState {
//   final String error;
//
//   DashboardError(this.error);
// }
//
// // ==================== DASHBOARD BLOC ====================
// class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
//   DashboardBloc() : super(DashboardInitial()) {
//     on<LoadExecutiveDashboardEvent>((event, emit) async {
//       emit(DashboardLoading());
//       try {
//         final response = await ApiIntegration.getExecutiveDashboard();
//
//         if (response.success) {
//           emit(ExecutiveDashboardLoaded(
//             stats: response.stats,
//             recentMeetings: response.recentMeetings,
//             todayAttendance: response.todayAttendance,
//           ));
//         } else {
//           emit(DashboardError(response.message));
//         }
//       } catch (e) {
//         emit(DashboardError('Failed to load executive dashboard: ${e.toString()}'));
//       }
//     });
//
//     on<LoadAdminDashboardEvent>((event, emit) async {
//       emit(DashboardLoading());
//       try {
//         final response = await ApiIntegration.getAdminDashboard();
//
//         if (response.success) {
//           emit(AdminDashboardLoaded(
//             stats: response.stats,
//             recentEmployees: response.recentEmployees,
//             recentMeetings: response.recentMeetings,
//           ));
//         } else {
//           emit(DashboardError(response.message));
//         }
//       } catch (e) {
//         emit(DashboardError('Failed to load admin dashboard: ${e.toString()}'));
//       }
//     });
//
//     on<LoadSuperAdminDashboardEvent>((event, emit) async {
//       emit(DashboardLoading());
//       try {
//         final response = await ApiIntegration.getSuperAdminDashboard();
//
//         if (response.success) {
//           emit(SuperAdminDashboardLoaded(
//             stats: response.stats,
//             pendingRegistrations: response.pendingRegistrations,
//             recentUsers: response.recentUsers,
//           ));
//         } else {
//           emit(DashboardError(response.message));
//         }
//       } catch (e) {
//         emit(DashboardError('Failed to load super admin dashboard: ${e.toString()}'));
//       }
//     });
//
//     on<RefreshDashboardEvent>((event, emit) {
//       if (state is ExecutiveDashboardLoaded) {
//         add(LoadExecutiveDashboardEvent());
//       } else if (state is AdminDashboardLoaded) {
//         add(LoadAdminDashboardEvent());
//       } else if (state is SuperAdminDashboardLoaded) {
//         add(LoadSuperAdminDashboardEvent());
//       }
//     });
//   }
// }
//
