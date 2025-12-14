// import 'package:json_annotation/json_annotation.dart';
// import 'package:equatable/equatable.dart';
//
// part 'api_models.g.dart';
//
// // Base Response
// @JsonSerializable()
// class BaseResponse extends Equatable {
//   final bool success;
//   final String message;
//   final int? statusCode;
//
//   const BaseResponse({
//     required this.success,
//     required this.message,
//     this.statusCode,
//   });
//
//   factory BaseResponse.fromJson(Map<String, dynamic> json) => _$BaseResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$BaseResponseToJson(this);
//
//   @override
//   List<Object?> get props => [success, message, statusCode];
// }
//
// // User Model
// @JsonSerializable()
// class User extends Equatable {
//   final String id;
//   final String username;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String role;
//   final String status;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//
//   const User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.role,
//     required this.status,
//     required this.createdAt,
//     this.updatedAt,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
//   Map<String, dynamic> toJson() => _$UserToJson(this);
//
//   @override
//   List<Object?> get props => [id, username, email, firstName, lastName, role, status, createdAt, updatedAt];
// }
//
// // Authentication Models
// @JsonSerializable()
// class LoginRequest extends Equatable {
//   final String username;
//   final String password;
//
//   const LoginRequest({
//     required this.username,
//     required this.password,
//   });
//
//   factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
//   Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
//
//   @override
//   List<Object?> get props => [username, password];
// }
//
// @JsonSerializable()
// class LoginResponse extends BaseResponse {
//   final User? user;
//   final String? token;
//
//   const LoginResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.user,
//     this.token,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, user, token];
// }
//
// @JsonSerializable()
// class RegisterRequest extends Equatable {
//   final String username;
//   final String password;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String role;
//
//   const RegisterRequest({
//     required this.username,
//     required this.password,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.role,
//   });
//
//   factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
//   Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
//
//   @override
//   List<Object?> get props => [username, password, email, firstName, lastName, role];
// }
//
// @JsonSerializable()
// class RegisterResponse extends BaseResponse {
//   final User? user;
//
//   const RegisterResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.user,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, user];
// }
//
// @JsonSerializable()
// class UserProfileResponse extends BaseResponse {
//   final User? user;
//
//   const UserProfileResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.user,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, user];
// }
//
// // Registration Management Models
// @JsonSerializable()
// class PendingRegistration extends Equatable {
//   final String id;
//   final String username;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String role;
//   final DateTime createdAt;
//
//   const PendingRegistration({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.role,
//     required this.createdAt,
//   });
//
//   factory PendingRegistration.fromJson(Map<String, dynamic> json) => _$PendingRegistrationFromJson(json);
//   Map<String, dynamic> toJson() => _$PendingRegistrationToJson(this);
//
//   @override
//   List<Object?> get props => [id, username, email, firstName, lastName, role, createdAt];
// }
//
// @JsonSerializable()
// class PendingRegistrationsResponse extends BaseResponse {
//   final List<PendingRegistration>? registrations;
//
//   const PendingRegistrationsResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.registrations,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory PendingRegistrationsResponse.fromJson(Map<String, dynamic> json) => _$PendingRegistrationsResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$PendingRegistrationsResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, registrations];
// }
//
// // Punch In/Out Models
// @JsonSerializable()
// class PunchRequest extends Equatable {
//   final String type; // 'punch_in' or 'punch_out'
//   final double? latitude;
//   final double? longitude;
//   final String? location;
//
//   const PunchRequest({
//     required this.type,
//     this.latitude,
//     this.longitude,
//     this.location,
//   });
//
//   factory PunchRequest.fromJson(Map<String, dynamic> json) => _$PunchRequestFromJson(json);
//   Map<String, dynamic> toJson() => _$PunchRequestToJson(this);
//
//   @override
//   List<Object?> get props => [type, latitude, longitude, location];
// }
//
// @JsonSerializable()
// class PunchResponse extends BaseResponse {
//   final DateTime? timestamp;
//   final String? type;
//   final String? location;
//
//   const PunchResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.timestamp,
//     this.type,
//     this.location,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory PunchResponse.fromJson(Map<String, dynamic> json) => _$PunchResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$PunchResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, timestamp, type, location];
// }
//
// // Attendance Models
// @JsonSerializable()
// class AttendanceRecord extends Equatable {
//   final String id;
//   final DateTime date;
//   final DateTime? punchInTime;
//   final DateTime? punchOutTime;
//   final String? punchInLocation;
//   final String? punchOutLocation;
//   final int? workingHours;
//
//   const AttendanceRecord({
//     required this.id,
//     required this.date,
//     this.punchInTime,
//     this.punchOutTime,
//     this.punchInLocation,
//     this.punchOutLocation,
//     this.workingHours,
//   });
//
//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);
//   Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);
//
//   @override
//   List<Object?> get props => [id, date, punchInTime, punchOutTime, punchInLocation, punchOutLocation, workingHours];
// }
//
// @JsonSerializable()
// class AttendanceHistoryResponse extends BaseResponse {
//   final List<AttendanceRecord>? attendance;
//
//   const AttendanceHistoryResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.attendance,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) => _$AttendanceHistoryResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$AttendanceHistoryResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, attendance];
// }
//
// // Meeting Models
// @JsonSerializable()
// class StartMeetingRequest extends Equatable {
//   final String title;
//   final String? description;
//   final List<String>? attendees;
//   final double? latitude;
//   final double? longitude;
//   final String? location;
//
//   const StartMeetingRequest({
//     required this.title,
//     this.description,
//     this.attendees,
//     this.latitude,
//     this.longitude,
//     this.location,
//   });
//
//   factory StartMeetingRequest.fromJson(Map<String, dynamic> json) => _$StartMeetingRequestFromJson(json);
//   Map<String, dynamic> toJson() => _$StartMeetingRequestToJson(this);
//
//   @override
//   List<Object?> get props => [title, description, attendees, latitude, longitude, location];
// }
//
// @JsonSerializable()
// class Meeting extends Equatable {
//   final String id;
//   final String title;
//   final String? description;
//   final String status;
//   final DateTime startTime;
//   final DateTime? endTime;
//   final String? location;
//   final List<String>? attendees;
//   final String organizer;
//
//   const Meeting({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.status,
//     required this.startTime,
//     this.endTime,
//     this.location,
//     this.attendees,
//     required this.organizer,
//   });
//
//   factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
//   Map<String, dynamic> toJson() => _$MeetingToJson(this);
//
//   @override
//   List<Object?> get props => [id, title, description, status, startTime, endTime, location, attendees, organizer];
// }
//
// @JsonSerializable()
// class MeetingResponse extends BaseResponse {
//   final Meeting? meeting;
//
//   const MeetingResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.meeting,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory MeetingResponse.fromJson(Map<String, dynamic> json) => _$MeetingResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$MeetingResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, meeting];
// }
//
// @JsonSerializable()
// class MeetingsListResponse extends BaseResponse {
//   final List<Meeting>? meetings;
//
//   const MeetingsListResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.meetings,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory MeetingsListResponse.fromJson(Map<String, dynamic> json) => _$MeetingsListResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$MeetingsListResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, meetings];
// }
//
// @JsonSerializable()
// class MeetingDetailResponse extends BaseResponse {
//   final Meeting? meeting;
//
//   const MeetingDetailResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.meeting,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory MeetingDetailResponse.fromJson(Map<String, dynamic> json) => _$MeetingDetailResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$MeetingDetailResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, meeting];
// }
//
// // Dashboard Models
// @JsonSerializable()
// class DashboardStats extends Equatable {
//   final int totalEmployees;
//   final int activeEmployees;
//   final int totalMeetings;
//   final int activeMeetings;
//
//   const DashboardStats({
//     required this.totalEmployees,
//     required this.activeEmployees,
//     required this.totalMeetings,
//     required this.activeMeetings,
//   });
//
//   factory DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);
//   Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
//
//   @override
//   List<Object?> get props => [totalEmployees, activeEmployees, totalMeetings, activeMeetings];
// }
//
// @JsonSerializable()
// class ExecutiveDashboardResponse extends BaseResponse {
//   final DashboardStats? stats;
//   final List<Meeting>? recentMeetings;
//   final AttendanceRecord? todayAttendance;
//
//   const ExecutiveDashboardResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.stats,
//     this.recentMeetings,
//     this.todayAttendance,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory ExecutiveDashboardResponse.fromJson(Map<String, dynamic> json) => _$ExecutiveDashboardResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$ExecutiveDashboardResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, stats, recentMeetings, todayAttendance];
// }
//
// @JsonSerializable()
// class AdminDashboardResponse extends BaseResponse {
//   final DashboardStats? stats;
//   final List<User>? recentEmployees;
//   final List<Meeting>? recentMeetings;
//
//   const AdminDashboardResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.stats,
//     this.recentEmployees,
//     this.recentMeetings,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) => _$AdminDashboardResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$AdminDashboardResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, stats, recentEmployees, recentMeetings];
// }
//
// @JsonSerializable()
// class SuperAdminDashboardResponse extends BaseResponse {
//   final DashboardStats? stats;
//   final List<PendingRegistration>? pendingRegistrations;
//   final List<User>? recentUsers;
//
//   const SuperAdminDashboardResponse({
//     required bool success,
//     required String message,
//     int? statusCode,
//     this.stats,
//     this.pendingRegistrations,
//     this.recentUsers,
//   }) : super(success: success, message: message, statusCode: statusCode);
//
//   factory SuperAdminDashboardResponse.fromJson(Map<String, dynamic> json) => _$SuperAdminDashboardResponseFromJson(json);
//   Map<String, dynamic> toJson() => _$SuperAdminDashboardResponseToJson(this);
//
//   @override
//   List<Object?> get props => [...super.props, stats, pendingRegistrations, recentUsers];
// }
