// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'api_models.dart';
//
// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************
//
// BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//     );
//
// Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//     };
//
// User _$UserFromJson(Map<String, dynamic> json) => User(
//       id: json['id'] as String,
//       username: json['username'] as String,
//       email: json['email'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       role: json['role'] as String,
//       status: json['status'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: json['updatedAt'] == null
//           ? null
//           : DateTime.parse(json['updatedAt'] as String),
//     );
//
// Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
//       'id': instance.id,
//       'username': instance.username,
//       'email': instance.email,
//       'firstName': instance.firstName,
//       'lastName': instance.lastName,
//       'role': instance.role,
//       'status': instance.status,
//       'createdAt': instance.createdAt.toIso8601String(),
//       'updatedAt': instance.updatedAt?.toIso8601String(),
//     };
//
// LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
//       username: json['username'] as String,
//       password: json['password'] as String,
//     );
//
// Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
//     <String, dynamic>{
//       'username': instance.username,
//       'password': instance.password,
//     };
//
// LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
//     LoginResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       user: json['user'] == null
//           ? null
//           : User.fromJson(json['user'] as Map<String, dynamic>),
//       token: json['token'] as String?,
//     );
//
// Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'user': instance.user,
//       'token': instance.token,
//     };
//
// RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
//     RegisterRequest(
//       username: json['username'] as String,
//       password: json['password'] as String,
//       email: json['email'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       role: json['role'] as String,
//     );
//
// Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
//     <String, dynamic>{
//       'username': instance.username,
//       'password': instance.password,
//       'email': instance.email,
//       'firstName': instance.firstName,
//       'lastName': instance.lastName,
//       'role': instance.role,
//     };
//
// RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
//     RegisterResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       user: json['user'] == null
//           ? null
//           : User.fromJson(json['user'] as Map<String, dynamic>),
//     );
//
// Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'user': instance.user,
//     };
//
// UserProfileResponse _$UserProfileResponseFromJson(Map<String, dynamic> json) =>
//     UserProfileResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       user: json['user'] == null
//           ? null
//           : User.fromJson(json['user'] as Map<String, dynamic>),
//     );
//
// Map<String, dynamic> _$UserProfileResponseToJson(
//         UserProfileResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'user': instance.user,
//     };
//
// PendingRegistration _$PendingRegistrationFromJson(Map<String, dynamic> json) =>
//     PendingRegistration(
//       id: json['id'] as String,
//       username: json['username'] as String,
//       email: json['email'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       role: json['role'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//
// Map<String, dynamic> _$PendingRegistrationToJson(
//         PendingRegistration instance) =>
//     <String, dynamic>{
//       'id': instance.id,
//       'username': instance.username,
//       'email': instance.email,
//       'firstName': instance.firstName,
//       'lastName': instance.lastName,
//       'role': instance.role,
//       'createdAt': instance.createdAt.toIso8601String(),
//     };
//
// PendingRegistrationsResponse _$PendingRegistrationsResponseFromJson(
//         Map<String, dynamic> json) =>
//     PendingRegistrationsResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       registrations: (json['registrations'] as List<dynamic>?)
//           ?.map((e) => PendingRegistration.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//
// Map<String, dynamic> _$PendingRegistrationsResponseToJson(
//         PendingRegistrationsResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'registrations': instance.registrations,
//     };
//
// PunchRequest _$PunchRequestFromJson(Map<String, dynamic> json) => PunchRequest(
//       type: json['type'] as String,
//       latitude: (json['latitude'] as num?)?.toDouble(),
//       longitude: (json['longitude'] as num?)?.toDouble(),
//       location: json['location'] as String?,
//     );
//
// Map<String, dynamic> _$PunchRequestToJson(PunchRequest instance) =>
//     <String, dynamic>{
//       'type': instance.type,
//       'latitude': instance.latitude,
//       'longitude': instance.longitude,
//       'location': instance.location,
//     };
//
// PunchResponse _$PunchResponseFromJson(Map<String, dynamic> json) =>
//     PunchResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       timestamp: json['timestamp'] == null
//           ? null
//           : DateTime.parse(json['timestamp'] as String),
//       type: json['type'] as String?,
//       location: json['location'] as String?,
//     );
//
// Map<String, dynamic> _$PunchResponseToJson(PunchResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'timestamp': instance.timestamp?.toIso8601String(),
//       'type': instance.type,
//       'location': instance.location,
//     };
//
// AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
//     AttendanceRecord(
//       id: json['id'] as String,
//       date: DateTime.parse(json['date'] as String),
//       punchInTime: json['punchInTime'] == null
//           ? null
//           : DateTime.parse(json['punchInTime'] as String),
//       punchOutTime: json['punchOutTime'] == null
//           ? null
//           : DateTime.parse(json['punchOutTime'] as String),
//       punchInLocation: json['punchInLocation'] as String?,
//       punchOutLocation: json['punchOutLocation'] as String?,
//       workingHours: (json['workingHours'] as num?)?.toInt(),
//     );
//
// Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
//     <String, dynamic>{
//       'id': instance.id,
//       'date': instance.date.toIso8601String(),
//       'punchInTime': instance.punchInTime?.toIso8601String(),
//       'punchOutTime': instance.punchOutTime?.toIso8601String(),
//       'punchInLocation': instance.punchInLocation,
//       'punchOutLocation': instance.punchOutLocation,
//       'workingHours': instance.workingHours,
//     };
//
// AttendanceHistoryResponse _$AttendanceHistoryResponseFromJson(
//         Map<String, dynamic> json) =>
//     AttendanceHistoryResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       attendance: (json['attendance'] as List<dynamic>?)
//           ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//
// Map<String, dynamic> _$AttendanceHistoryResponseToJson(
//         AttendanceHistoryResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'attendance': instance.attendance,
//     };
//
// StartMeetingRequest _$StartMeetingRequestFromJson(Map<String, dynamic> json) =>
//     StartMeetingRequest(
//       title: json['title'] as String,
//       description: json['description'] as String?,
//       attendees: (json['attendees'] as List<dynamic>?)
//           ?.map((e) => e as String)
//           .toList(),
//       latitude: (json['latitude'] as num?)?.toDouble(),
//       longitude: (json['longitude'] as num?)?.toDouble(),
//       location: json['location'] as String?,
//     );
//
// Map<String, dynamic> _$StartMeetingRequestToJson(
//         StartMeetingRequest instance) =>
//     <String, dynamic>{
//       'title': instance.title,
//       'description': instance.description,
//       'attendees': instance.attendees,
//       'latitude': instance.latitude,
//       'longitude': instance.longitude,
//       'location': instance.location,
//     };
//
// Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       description: json['description'] as String?,
//       status: json['status'] as String,
//       startTime: DateTime.parse(json['startTime'] as String),
//       endTime: json['endTime'] == null
//           ? null
//           : DateTime.parse(json['endTime'] as String),
//       location: json['location'] as String?,
//       attendees: (json['attendees'] as List<dynamic>?)
//           ?.map((e) => e as String)
//           .toList(),
//       organizer: json['organizer'] as String,
//     );
//
// Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
//       'id': instance.id,
//       'title': instance.title,
//       'description': instance.description,
//       'status': instance.status,
//       'startTime': instance.startTime.toIso8601String(),
//       'endTime': instance.endTime?.toIso8601String(),
//       'location': instance.location,
//       'attendees': instance.attendees,
//       'organizer': instance.organizer,
//     };
//
// MeetingResponse _$MeetingResponseFromJson(Map<String, dynamic> json) =>
//     MeetingResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       meeting: json['meeting'] == null
//           ? null
//           : Meeting.fromJson(json['meeting'] as Map<String, dynamic>),
//     );
//
// Map<String, dynamic> _$MeetingResponseToJson(MeetingResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'meeting': instance.meeting,
//     };
//
// MeetingsListResponse _$MeetingsListResponseFromJson(
//         Map<String, dynamic> json) =>
//     MeetingsListResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       meetings: (json['meetings'] as List<dynamic>?)
//           ?.map((e) => Meeting.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//
// Map<String, dynamic> _$MeetingsListResponseToJson(
//         MeetingsListResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'meetings': instance.meetings,
//     };
//
// MeetingDetailResponse _$MeetingDetailResponseFromJson(
//         Map<String, dynamic> json) =>
//     MeetingDetailResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       meeting: json['meeting'] == null
//           ? null
//           : Meeting.fromJson(json['meeting'] as Map<String, dynamic>),
//     );
//
// Map<String, dynamic> _$MeetingDetailResponseToJson(
//         MeetingDetailResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'meeting': instance.meeting,
//     };
//
// DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
//     DashboardStats(
//       totalEmployees: (json['totalEmployees'] as num).toInt(),
//       activeEmployees: (json['activeEmployees'] as num).toInt(),
//       totalMeetings: (json['totalMeetings'] as num).toInt(),
//       activeMeetings: (json['activeMeetings'] as num).toInt(),
//     );
//
// Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
//     <String, dynamic>{
//       'totalEmployees': instance.totalEmployees,
//       'activeEmployees': instance.activeEmployees,
//       'totalMeetings': instance.totalMeetings,
//       'activeMeetings': instance.activeMeetings,
//     };
//
// ExecutiveDashboardResponse _$ExecutiveDashboardResponseFromJson(
//         Map<String, dynamic> json) =>
//     ExecutiveDashboardResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       stats: json['stats'] == null
//           ? null
//           : DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
//       recentMeetings: (json['recentMeetings'] as List<dynamic>?)
//           ?.map((e) => Meeting.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       todayAttendance: json['todayAttendance'] == null
//           ? null
//           : AttendanceRecord.fromJson(
//               json['todayAttendance'] as Map<String, dynamic>),
//     );
//
// Map<String, dynamic> _$ExecutiveDashboardResponseToJson(
//         ExecutiveDashboardResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'stats': instance.stats,
//       'recentMeetings': instance.recentMeetings,
//       'todayAttendance': instance.todayAttendance,
//     };
//
// AdminDashboardResponse _$AdminDashboardResponseFromJson(
//         Map<String, dynamic> json) =>
//     AdminDashboardResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       stats: json['stats'] == null
//           ? null
//           : DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
//       recentEmployees: (json['recentEmployees'] as List<dynamic>?)
//           ?.map((e) => User.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       recentMeetings: (json['recentMeetings'] as List<dynamic>?)
//           ?.map((e) => Meeting.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//
// Map<String, dynamic> _$AdminDashboardResponseToJson(
//         AdminDashboardResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'stats': instance.stats,
//       'recentEmployees': instance.recentEmployees,
//       'recentMeetings': instance.recentMeetings,
//     };
//
// SuperAdminDashboardResponse _$SuperAdminDashboardResponseFromJson(
//         Map<String, dynamic> json) =>
//     SuperAdminDashboardResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       statusCode: (json['statusCode'] as num?)?.toInt(),
//       stats: json['stats'] == null
//           ? null
//           : DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
//       pendingRegistrations: (json['pendingRegistrations'] as List<dynamic>?)
//           ?.map((e) => PendingRegistration.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       recentUsers: (json['recentUsers'] as List<dynamic>?)
//           ?.map((e) => User.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//
// Map<String, dynamic> _$SuperAdminDashboardResponseToJson(
//         SuperAdminDashboardResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'message': instance.message,
//       'statusCode': instance.statusCode,
//       'stats': instance.stats,
//       'pendingRegistrations': instance.pendingRegistrations,
//       'recentUsers': instance.recentUsers,
//     };
