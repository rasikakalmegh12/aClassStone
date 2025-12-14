// import '../../api/models/api_models.dart';
//
// // Dashboard States
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
