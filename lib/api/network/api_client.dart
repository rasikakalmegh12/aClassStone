// import 'package:dio/dio.dart';
// import 'package:retrofit/retrofit.dart';
// import '../models/api_models.dart';
//
// part 'api_client.g.dart';
//
// @RestApi()
// abstract class ApiClient {
//   factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
//
//   // Auth endpoints
//   @POST('/auth/login')
//   Future<LoginResponse> login(@Body() LoginRequest request);
//
//   @POST('/auth/register')
//   Future<RegisterResponse> register(@Body() RegisterRequest request);
//
//   @POST('/auth/logout')
//   Future<BaseResponse> logout();
//
//   @GET('/auth/profile')
//   Future<UserProfileResponse> getUserProfile();
//
//   // Registration management endpoints
//   @GET('/admin/registrations/pending')
//   Future<PendingRegistrationsResponse> getPendingRegistrations();
//
//   @PUT('/admin/registrations/{id}/approve')
//   Future<BaseResponse> approveRegistration(@Path('id') String registrationId);
//
//   @PUT('/admin/registrations/{id}/reject')
//   Future<BaseResponse> rejectRegistration(@Path('id') String registrationId);
//
//   // Attendance endpoints
//   @POST('/executive/punch-in')
//   Future<PunchResponse> punchIn(@Body() PunchRequest request);
//
//   @POST('/executive/punch-out')
//   Future<PunchResponse> punchOut(@Body() PunchRequest request);
//
//   @GET('/executive/attendance-history')
//   Future<AttendanceHistoryResponse> getAttendanceHistory();
//
//   // Meeting endpoints
//   @POST('/meetings/start')
//   Future<MeetingResponse> startMeeting(@Body() StartMeetingRequest request);
//
//   @PUT('/meetings/{id}/end')
//   Future<MeetingResponse> endMeeting(@Path('id') String meetingId);
//
//   @GET('/meetings')
//   Future<MeetingsListResponse> getMeetings();
//
//   @GET('/meetings/{id}')
//   Future<MeetingDetailResponse> getMeetingDetail(@Path('id') String meetingId);
//
//   // Dashboard endpoints
//   @GET('/dashboard/executive')
//   Future<ExecutiveDashboardResponse> getExecutiveDashboard();
//
//   @GET('/dashboard/admin')
//   Future<AdminDashboardResponse> getAdminDashboard();
//
//   @GET('/dashboard/super-admin')
//   Future<SuperAdminDashboardResponse> getSuperAdminDashboard();
// }
