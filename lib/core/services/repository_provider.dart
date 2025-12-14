import 'package:apclassstone/bloc/auth/auth_bloc.dart';

import '../../bloc/bloc.dart';

/// Service Provider for managing BLoCs
/// Provides singleton instances of all BLoCs used throughout the app
class AppBlocProvider {
  static late LoginBloc _authBloc;
  static late RegistrationBloc _registrationBloc;
  // static late AttendanceBloc _attendanceBloc;
  // static late MeetingBloc _meetingBloc;
  // static late DashboardBloc _dashboardBloc;
  // static late UserProfileBloc _userProfileBloc;

  /// Initialize all BLoCs
  static void initialize() {
    _authBloc = LoginBloc();
    _registrationBloc = RegistrationBloc();
    // _attendanceBloc = AttendanceBloc();
    // _meetingBloc = MeetingBloc();
    // _dashboardBloc = DashboardBloc();
    // _userProfileBloc = UserProfileBloc();
  }

  /// Get AuthBloc instance
  static LoginBloc get authBloc => _authBloc;

  /// Get RegistrationBloc instance
  static RegistrationBloc get registrationBloc => _registrationBloc;

  /// Get AttendanceBloc instance
  // static AttendanceBloc get attendanceBloc => _attendanceBloc;
  //
  // /// Get MeetingBloc instance
  // static MeetingBloc get meetingBloc => _meetingBloc;
  //
  // /// Get DashboardBloc instance
  // static DashboardBloc get dashboardBloc => _dashboardBloc;
  //
  // /// Get UserProfileBloc instance
  // static UserProfileBloc get userProfileBloc => _userProfileBloc;

  /// Dispose all BLoCs (call this when app closes)
  static void dispose() {
    _authBloc.close();
    _registrationBloc.close();
    // _attendanceBloc.close();
    // _meetingBloc.close();
    // _dashboardBloc.close();
    // _userProfileBloc.close();
  }
}


