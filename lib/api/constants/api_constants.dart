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
  static const String executiveTrackingByDays = "${baseUrl}marketing/admin/executives";

  // Meeting Management
  static const String startMeeting = "meeting/start";
  static const String endMeeting = "meeting/end";
  static const String getMeetings = "meeting/list";
  static const String getMeetingDetail = "meeting/detail";

  // Dashboard
  static const String executiveDashboard = "dashboard/executive";
  static const String adminDashboard = "dashboard/admin";
  static const String superAdminDashboard = "dashboard/super-admin";


 //  Admin and SuperAdmin Common Apis
  static const String executiveAttendance = "${baseUrl}marketing/admin/executives/attendance/day";
  static const String executiveAttendanceDateWise = "${baseUrl}marketing/admin/executives";





  //      Catalogues Apis

  static const String getProductType = "${baseUrl}marketing/admin/catalogue/options/product-types";
  static const String getUtilities = "${baseUrl}marketing/admin/catalogue/options/utilities";
  static const String getColors = "${baseUrl}marketing/admin/catalogue/options/colours";
  static const String getFinishes = "${baseUrl}marketing/admin/catalogue/options/finishes";
  static const String getTextures = "${baseUrl}marketing/admin/catalogue/options/textures";
  static const String getNaturalColors = "${baseUrl}marketing/admin/catalogue/options/natural-colours";
  static const String getOrigins = "${baseUrl}marketing/admin/catalogue/options/origins";
  static const String getStateCountries = "${baseUrl}marketing/admin/catalogue/options/state-countries";
  static const String getProcessingNatures = "${baseUrl}marketing/admin/catalogue/options/processing-natures";
  static const String getNaturalMaterials = "${baseUrl}marketing/admin/catalogue/options/material-naturalities";
  static const String getHandicraftsTypes = "${baseUrl}marketing/admin/catalogue/options/handicraft-types";
  static const String getCatalogueProductList = "${baseUrl}marketing/catalogue/products";
  static const String getCatalogueProductDetails = "${baseUrl}marketing/catalogue/products";
  static const String getPriceRange = "${baseUrl}marketing/admin/catalogue/options/price-ranges";
  static const String getMinesOption = "${baseUrl}marketing/admin/catalogue/mines/options";


  static const String postColors = "${baseUrl}marketing/admin/catalogue/options/colours";
  static const String postFinishes = "${baseUrl}marketing/admin/catalogue/options/finishes";
  static const String postTextures = "${baseUrl}marketing/admin/catalogue/options/textures";
  static const String postNaturalColors = "${baseUrl}marketing/admin/catalogue/options/natural-colours";
  static const String postOrigins = "${baseUrl}marketing/admin/catalogue/options/origins";
  static const String postStateCountries = "${baseUrl}marketing/admin/catalogue/options/state-countries";
  static const String postProcessingNatures = "${baseUrl}marketing/admin/catalogue/options/processing-natures";
  static const String postNaturalMaterials = "${baseUrl}marketing/admin/catalogue/options/material-naturalities";
  static const String postHandicraftsTypes = "${baseUrl}marketing/admin/catalogue/options/handicraft-types";
  static const String postProductEntry= "${baseUrl}marketing/admin/catalogue/products";
  static const String postImageEntry= "${baseUrl}marketing/admin/catalogue/products";
  static const String putCatalogueOptionsEntry= "${baseUrl}marketing/admin/catalogue/products";
  static const String postMinesEntry= "${baseUrl}marketing/admin/catalogue/mines";
  static const String postSearch= "${baseUrl}marketing/catalogue/products/search";

 // Clients Apis

  static const String postClients = "${baseUrl}marketing/clients";
  static const String getClientsDetails = "${baseUrl}marketing/clients";
  static const String getClientsList = "${baseUrl}marketing/clients";



  // Common Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> headerWithToken() {
    final token = SessionManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

