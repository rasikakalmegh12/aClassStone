import 'dart:convert';

import 'package:apclassstone/api/models/response/GetProfileResponseBody.dart';
import 'package:apclassstone/api/models/response/LoginResponseBody.dart';
import 'package:apclassstone/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/session/session_manager.dart';
import '../constants/api_constants.dart';
import '../models/request/RegistrationRequestBody.dart';
import '../models/response/PendingRegistrationResponseBody.dart';
import '../models/response/RegistrationResponseBody.dart';

/// Consolidated API Integration class - all API calls are managed here
class ApiIntegration {
  /// Default timeout duration for API calls
  static const Duration _timeout = Duration(seconds: 30);

  // ===================== AUTH APIs =====================

  /// Register a new user
  ///
  /// Returns: RegistrationResponseBody with user data on success
  /// Expected response:
  /// {
  ///   "status": true,
  ///   "message": "Registration successful",
  ///   "statusCode": 201,
  ///   "data": {
  ///     "id": "user_id",
  ///     "email": "user@email.com",
  ///     "phone": "phone_number"
  ///   }
  /// }
  static Future<RegistrationResponseBody> register(RegistrationRequestBody requestBody,) async {
    try {
      final url = Uri.parse(ApiConstants.register);

      print('📤 Sending registration request to: $url');
      print('Request body: ${requestBody.toJson()}');

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody.toJson()),
      ).timeout(_timeout);

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = RegistrationResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ Registration successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = RegistrationResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ Registration failed with status ${response.statusCode}');
        }
        return RegistrationResponseBody(
          status: false,
          message: 'Registration failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      print('❌ $errorMsg');
      return RegistrationResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return RegistrationResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



  /// Login user with username and password
  ///
  /// Returns: LoginResponseBody with user data on success
  /// Expected response:
  /// {
  /// "status": true,
  /// "message": "Login successful",
  /// "statusCode": 200,
  /// "data": {
  /// "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6Ijg1NzVjNjE3LTc2NGUtNDFhNi1hYTNlLTQ0ZjNmMWUwM2RhZSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWUiOiJTdXBlciBBZG1pbmlzdHJhdG9yIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoic3VwZXJhZG1pbkBhY2xzLmxvY2FsIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiU1VQRVJBRE1JTiIsImFwcCI6Ik1BUktFVElORyIsImV4cCI6MTc2NTcyMTY5MywiaXNzIjoiQUNsYXNzU3RvbmUiLCJhdWQiOiJBQ2xhc3NTdG9uZUF1ZGllbmNlIn0.NQYZtb6xJ5pcNth3b_oyhq9h-FPuzAlLlBWGpjnz6Ug",
  /// "refreshToken": "cDyB7dbFp1+KkbiVg7enfUOUPS4T+Xv3h2PcAtir67p/f0nOWR1ftWu9Jiaci7AWMEr1GbryeL109GUseU5bDw==",
  /// "accessTokenExpiresAt": "2025-12-14T14:14:53.9756542Z",
  /// "refreshTokenExpiresAt": "2025-12-21T13:14:53.9756553Z"
  /// }
  /// }
  static Future<LoginResponseBody> login(String username, String password) async {
    try {
      final url = Uri.parse(ApiConstants.loginWithPassword); // Assuming `loginUrl` is the correct property

      if (kDebugMode) {
        print('📤 Sending registration request to: $url');
      }

        final requestBody ={
          "email": username,
          "password": password,
          "appCode": AppConstants.appCode
        };



      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      if (kDebugMode) {
        print('📥 Request body login : ${jsonEncode(requestBody)}');
        print('Response body login: ${response.body}');
      }


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = LoginResponseBody.fromJson(jsonResponse);
        print('✅ Login successful: ${result.message}');
        return result;
      } else {
        final result = LoginResponseBody.fromJson(jsonDecode(response.body));
        print('❌ Login failed with status ${result.statusCode}');
        return LoginResponseBody(
          status: false,
          message: 'Login failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



  static Future<GetProfileResponseBody> getProfile() async {
    try {
      final url = Uri.parse(ApiConstants.getUserProfile);

      if (kDebugMode) {
        print('📤 Sending Profile request to: $url');
      }


      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SessionManager.getAccessTokenSync()}',
        }

      ).timeout(_timeout);

      if (kDebugMode) {
        print('📥 Response getUserProfile status: ${response.statusCode}');
        print('Response getUserProfile body: ${response.body}');
      }


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetProfileResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ Profile successful: ${result.message}');
        }
        return result;
      } else {
        if (kDebugMode) {
          print('❌ Profile failed with status ${response.statusCode}');
        }
        return GetProfileResponseBody(
          status: false,
          message: 'Profile failed. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return GetProfileResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return GetProfileResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<PendingRegistrationResponseBody> getPendingUsers() async {
    try {
      final url = Uri.parse(ApiConstants.pendingRegistrations);

      if (kDebugMode) {
        print('📤 Sending Pending User request to: $url');
        print('📤 Sending Pending User header: ${ApiConstants.headerWithToken}');
      }


      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SessionManager.getAccessTokenSync()}',
        },

      ).timeout(_timeout);

      if (kDebugMode) {
        print('📥 Response pending status: ${response.statusCode}');
        print('Response pending body: ${response.body}');
      }


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = PendingRegistrationResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ Pending User successful: ${result.message}');
        }
        return result;
      } else {
        if (kDebugMode) {
          print('❌ Pending User failed with status ${response.statusCode}');
        }
        return PendingRegistrationResponseBody(
          status: false,
          message: 'Pending User failed. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return PendingRegistrationResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return PendingRegistrationResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


//
//   /// Logout user
//   static Future<BaseResponse> logout() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//       await SessionManager.clearSession();
//
//       return const BaseResponse(
//         success: true,
//         message: 'Logout successful',
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'Logout failed: ${e.toString()}',
//       );
//     }
//   }
//
//   // ===================== REGISTRATION APIs =====================

//
//   /// Approve a pending registration
//   static Future<BaseResponse> approveRegistration(String registrationId) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return const BaseResponse(
//         success: true,
//         message: 'Registration approved successfully',
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'Failed to approve registration: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Reject a pending registration
//   static Future<BaseResponse> rejectRegistration(String registrationId) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return const BaseResponse(
//         success: true,
//         message: 'Registration rejected successfully',
//       );
//     } catch (e) {
//       return BaseResponse(
//         success: false,
//         message: 'Failed to reject registration: ${e.toString()}',
//       );
//     }
//   }
//
//   // ===================== ATTENDANCE APIs =====================
//
//   /// Record punch in with location
//   static Future<PunchResponse> punchIn({
//     double? latitude,
//     double? longitude,
//     String? location,
//   }) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return PunchResponse(
//         success: true,
//         message: 'Punched in successfully',
//         timestamp: DateTime.now(),
//         type: 'punch_in',
//         location: location ?? 'Office',
//       );
//     } catch (e) {
//       return PunchResponse(
//         success: false,
//         message: 'Failed to punch in: ${e.toString()}',
//         timestamp: DateTime.now(),
//         type: 'punch_in',
//       );
//     }
//   }
//
//   /// Record punch out with location
//   static Future<PunchResponse> punchOut({
//     double? latitude,
//     double? longitude,
//     String? location,
//   }) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return PunchResponse(
//         success: true,
//         message: 'Punched out successfully',
//         timestamp: DateTime.now(),
//         type: 'punch_out',
//         location: location ?? 'Office',
//       );
//     } catch (e) {
//       return PunchResponse(
//         success: false,
//         message: 'Failed to punch out: ${e.toString()}',
//         timestamp: DateTime.now(),
//         type: 'punch_out',
//       );
//     }
//   }
//
//   /// Get attendance history
//   static Future<AttendanceHistoryResponse> getAttendanceHistory() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return const AttendanceHistoryResponse(
//         success: true,
//         message: 'Attendance history loaded',
//         attendance: [],
//       );
//     } catch (e) {
//       return AttendanceHistoryResponse(
//         success: false,
//         message: 'Failed to load attendance history: ${e.toString()}',
//         attendance: [],
//       );
//     }
//   }
//
//   // ===================== MEETING APIs =====================
//
//   /// Start a new meeting
//   static Future<MeetingResponse> startMeeting({
//     required String title,
//     String? description,
//     List<String>? attendees,
//     double? latitude,
//     double? longitude,
//     String? location,
//   }) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       final meeting = Meeting(
//         id: 'meeting_${DateTime.now().millisecondsSinceEpoch}',
//         title: title,
//         description: description,
//         status: 'active',
//         startTime: DateTime.now(),
//         organizer: 'current_user',
//         location: location ?? 'Office',
//         attendees: attendees,
//       );
//
//       return MeetingResponse(
//         success: true,
//         message: 'Meeting started successfully',
//         meeting: meeting,
//       );
//     } catch (e) {
//       return MeetingResponse(
//         success: false,
//         message: 'Failed to start meeting: ${e.toString()}',
//       );
//     }
//   }
//
//   /// End an active meeting
//   static Future<MeetingResponse> endMeeting(String meetingId) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       final meeting = Meeting(
//         id: meetingId,
//         title: 'Sample Meeting',
//         status: 'completed',
//         startTime: DateTime.now().subtract(const Duration(hours: 1)),
//         endTime: DateTime.now(),
//         organizer: 'current_user',
//       );
//
//       return MeetingResponse(
//         success: true,
//         message: 'Meeting ended successfully',
//         meeting: meeting,
//       );
//     } catch (e) {
//       return MeetingResponse(
//         success: false,
//         message: 'Failed to end meeting: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Get list of all meetings
//   static Future<MeetingsListResponse> getMeetings() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return const MeetingsListResponse(
//         success: true,
//         message: 'Meetings loaded successfully',
//         meetings: [],
//       );
//     } catch (e) {
//       return MeetingsListResponse(
//         success: false,
//         message: 'Failed to load meetings: ${e.toString()}',
//         meetings: [],
//       );
//     }
//   }
//
//   /// Get details of a specific meeting
//   static Future<MeetingDetailResponse> getMeetingDetail(String meetingId) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       return const MeetingDetailResponse(
//         success: false,
//         message: 'Meeting not found',
//       );
//     } catch (e) {
//       return MeetingDetailResponse(
//         success: false,
//         message: 'Failed to load meeting detail: ${e.toString()}',
//       );
//     }
//   }
//
//   // ===================== DASHBOARD APIs =====================
//
//   /// Get executive dashboard data
//   static Future<ExecutiveDashboardResponse> getExecutiveDashboard() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       final stats = const DashboardStats(
//         totalEmployees: 50,
//         activeEmployees: 45,
//         totalMeetings: 12,
//         activeMeetings: 3,
//       );
//
//       final recentMeetings = [
//         Meeting(
//           id: 'meeting_1',
//           title: 'Weekly Team Standup',
//           status: 'active',
//           startTime: DateTime.now(),
//           organizer: 'executive_1',
//           location: 'Conference Room A',
//         ),
//         Meeting(
//           id: 'meeting_2',
//           title: 'Project Review',
//           status: 'completed',
//           startTime: DateTime.now().subtract(const Duration(hours: 2)),
//           endTime: DateTime.now().subtract(const Duration(hours: 1)),
//           organizer: 'executive_1',
//         ),
//       ];
//
//       final todayAttendance = AttendanceRecord(
//         id: 'attendance_1',
//         date: DateTime.now(),
//         punchInTime: DateTime.now().subtract(const Duration(hours: 8)),
//         punchInLocation: 'Office',
//         workingHours: 8,
//       );
//
//       return ExecutiveDashboardResponse(
//         success: true,
//         message: 'Executive dashboard data fetched successfully',
//         stats: stats,
//         recentMeetings: recentMeetings,
//         todayAttendance: todayAttendance,
//       );
//     } catch (e) {
//       return ExecutiveDashboardResponse(
//         success: false,
//         message: 'Failed to load executive dashboard: ${e.toString()}',
//       );
//     }
//   }
//
//   /// Get admin dashboard data
//   static Future<AdminDashboardResponse> getAdminDashboard() async {
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//
//       final stats = DashboardStats(
//         totalEmployees: 50,
//         activeEmployees: 45,
//         totalMeetings: 25,
//         activeMeetings: 5,
//       );
//
//       final recentEmployees = [
//         User(
//           id: 'emp_1',
//           username: 'john.doe@company.com',
//           email: 'john.doe@company.com',
//           firstName: 'John',

}
