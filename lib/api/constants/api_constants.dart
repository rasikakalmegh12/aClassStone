import 'package:apclassstone/core/session/session_manager.dart';

class ApiConstants {

  static const String baseUrl = "http://64.227.134.138:5105/api/v1/";

  // Authentication
  static const String loginSendOtp = "login/sendotp";
  static const String loginVerifyOtp = "login/verifyotp";
  static const String loginWithPassword = "${baseUrl}auth/login";
  static const String logout = "${baseUrl}auth/logout";
  static const String refreshToken = "${baseUrl}auth/refresh";

  // User Management
  static const String register = "${baseUrl}auth/register";
  static const String getUserProfile = "${baseUrl}profile";
  static const String updateProfile = "${baseUrl}profile";
  static const String changePassword = "auth/change-password";

  // Registration Management
  static const String allUsers = "${baseUrl}admin/users/all";
  static const String pendingRegistrations = "${baseUrl}admin/users/pending";
  static const String approveRegistration = "${baseUrl}admin/users/approve";
  static const String rejectRegistration = "${baseUrl}admin/users/reject";

  // Attendance
  static const String punchIn = "${baseUrl}marketing/executive/punch-in";
  static const String punchOut = "${baseUrl}marketing/executive/punch-out";
  static const String activeSession = "${baseUrl}marketing/executive/active-session";
  static const String locationPing = "${baseUrl}marketing/executive/location-ping";

  // Meeting Management
  static const String startMeeting = "meeting/start";
  static const String endMeeting = "meeting/end";
  static const String getMeetings = "meeting/list";
  static const String getMeetingDetail = "meeting/detail";

  // Dashboard
  static const String executiveDashboard = "dashboard/executive";
  static const String adminDashboard = "dashboard/admin";
  static const String superAdminDashboard = "dashboard/super-admin";

  // Common Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  //  Headers with Token
  static final Map<String, String> headerWithToken = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${SessionManager.getAccessTokenSync()}',
  };
}

