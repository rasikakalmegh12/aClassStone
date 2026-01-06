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


import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/integration/api_integration.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class AllUsersBloc extends Bloc<AllUsersEvent, AllUsersState> {
  AllUsersBloc() : super(AllUsersInitial()) {
    // Handle user registration
    on<GetAllUsers>((event, emit) async {
      emit(AllUsersLoading());

      try {


        // Call API
        final response = await ApiIntegration.getAllUsers();

        // Check if registration was successful
        if (response.status == true) {
          emit(AllUsersLoaded(response));
        } else {
          emit(AllUsersError(
            message: response.message ?? 'Registration failed',
          ));
        }
      } catch (e) {
        emit(AllUsersError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}


class ActiveSessionBloc extends Bloc<ActiveSessionEvent, ActiveSessionState> {
  ActiveSessionBloc() : super(ActiveSessionInitial()) {
    // Handle user registration
    on<FetchActiveSession>((event, emit) async {
      emit(ActiveSessionLoading());

      try {


        // Call API
        final response = await ApiIntegration.getActiveSession();

        // Check if registration was successful
        if (response.statusCode==200) {
          emit(ActiveSessionLoaded(response));
        } else {
          emit(ActiveSessionError(

            message: response.message ?? 'Session failed',
          ));
        }
      } catch (e) {
        emit(ActiveSessionError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });

  }
}