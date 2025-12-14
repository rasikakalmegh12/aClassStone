// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dashboard_event.dart';
// import 'dashboard_state.dart';
// import '../../api/integration/api_integration.dart';
//
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
//       // Based on current state, reload the appropriate dashboard
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
