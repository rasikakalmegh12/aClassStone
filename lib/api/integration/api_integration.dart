import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:apclassstone/api/models/request/ApproveRequestBody.dart';
import 'package:apclassstone/api/models/request/PostCatalogueCommonRequestBody.dart';
import 'package:apclassstone/api/models/request/PostClientAddContactRequestBody.dart';
import 'package:apclassstone/api/models/request/PostClientAddLocationRequestBody.dart';
import 'package:apclassstone/api/models/request/PostClientAddRequestBody.dart';
import 'package:apclassstone/api/models/request/PostMinesEntryRequestBody.dart';
import 'package:apclassstone/api/models/request/PostSearchRequestBody.dart';
import 'package:apclassstone/api/models/request/ProductEntryRequestBody.dart';
import 'package:apclassstone/api/models/request/PutCatalogueOptionEntryRequestBody.dart';
import 'package:apclassstone/api/models/response/ActiveSessionResponseBody.dart';
import 'package:apclassstone/api/models/response/AllUsersResponseBody.dart';
import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';
import 'package:apclassstone/api/models/response/ApproveResponseBody.dart';
import 'package:apclassstone/api/models/response/CatalogueImageEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/ExecutiveAttendanceMonthlyResponseBody.dart';
import 'package:apclassstone/api/models/response/ExecutiveAttendanceResponseBody.dart';
import 'package:apclassstone/api/models/response/ExecutiveTrackingByDaysResponse.dart';
import 'package:apclassstone/api/models/response/GetCatalogueProductResponseBody.dart';
import 'package:apclassstone/api/models/response/GetCatalogueProductDetailsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetClientIdDetailsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetClientListResponseBody.dart';
import 'package:apclassstone/api/models/response/GetFinishesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetHandicraftsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMaterialNatureResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMinesOptionResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMomIdDetailsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMomResponseBody.dart';
import 'package:apclassstone/api/models/response/GetNaturalColorResponseBody.dart';
import 'package:apclassstone/api/models/response/GetOriginsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetPriceRangeResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProcessingNaturesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProfileResponseBody.dart';
import 'package:apclassstone/api/models/response/GetStateCountriesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetTextureResponseBody.dart';
import 'package:apclassstone/api/models/response/LoginResponseBody.dart';
import 'package:apclassstone/api/models/response/PostCatalogueCommonResponseBody.dart';
import 'package:apclassstone/api/models/response/PostClientAddContactResponseBody.dart';
import 'package:apclassstone/api/models/response/PostClientAddLocationResponseBody.dart';
import 'package:apclassstone/api/models/response/PostMinesEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/PostMomEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/ProductEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/PunchInOutResponseBody.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import 'package:apclassstone/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/session/session_manager.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/repository_provider.dart';
import '../../data/models/cached_response.dart';
import '../constants/api_constants.dart';
import '../models/request/GetProfileRequestBody.dart';
import '../models/request/RegistrationRequestBody.dart';
import '../models/response/GetColorsResponseBody.dart';
import '../models/response/GetProductTypeResponseBody.dart';
import '../models/response/GetUtilitiesTypeResponseBody.dart';
import '../models/response/PendingRegistrationResponseBody.dart';
import '../models/response/PostClientAddResponseBody.dart';
import '../models/response/PostMomImageUploadResponseBody.dart';
import '../models/response/RegistrationResponseBody.dart';
import '../models/request/PunchInOutRequestBody.dart';
import '../network/api_client.dart';


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
      final errorMsg = 'Network error login: ${ErrorMessages.networkError}';
      print('❌ $errorMsg');
      return RegistrationResponseBody(
        status: false,
        message:errorMsg,
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
      final url = Uri.parse(ApiConstants.loginWithPassword);

      if (kDebugMode) {
        print('📤 Sending login request to: $url');
      }

      final requestBody = {
        "email": username,
        "password": password,
        "appCode": AppConstants.appCode
      };

      if (kDebugMode) {
        print('📥 Request body login : ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        url,
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      if (kDebugMode) {
        print('Response body login: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = LoginResponseBody.fromJson(jsonResponse);
        print('✅ Login successful: ${result.message}');
        return result;
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          final result = LoginResponseBody.fromJson(jsonResponse);
          print('❌ Login failed with status ${response.statusCode}');
          return LoginResponseBody(
            status: false,
            message: result.message ?? 'Login failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          print('❌ Failed to parse error response: $parseError');
          return LoginResponseBody(
            status: false,
            message: 'Server error: ${response.statusCode} - ${response.body}',
            statusCode: response.statusCode,
          );
        }
      }
    } on TimeoutException catch (e) {
      final errorMsg = 'Request timeout: The server took too long to respond. Please check your internet connection and try again.';
      if (kDebugMode) {
        print('❌ $errorMsg');
        print('Timeout details: ${e.toString()}');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: Unable to reach the server. Please check your internet connection. ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Unexpected error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<ApiCommonResponseBody> logout(String refreshToken) async {
    try {
      final url = Uri.parse(ApiConstants.logout);

      if (kDebugMode) {
        print('📤 Sending refreshToken request to: $url');
      }

      final requestBody = {
        "refreshToken": refreshToken,
      };

      if (kDebugMode) {
        print('📥 Request body refreshToken : ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        url,
        headers: ApiConstants.headerWithToken(),
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      if (kDebugMode) {
        print('Response body refreshToken: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ApiCommonResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ refreshToken successful: ${result.message}');
        }
        return result;
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          final result = ApiCommonResponseBody.fromJson(jsonResponse);
          if (kDebugMode) {
            print('❌ refreshToken failed with status ${response.statusCode}');
          }
          return ApiCommonResponseBody(
            status: false,
            message: result.message ?? 'refreshToken failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ Failed to parse error response: $parseError');
          }
          return ApiCommonResponseBody(
            status: false,
            message: 'Server error: ${response.statusCode} - ${response.body}',
            statusCode: response.statusCode,
          );
        }
      }
    } on TimeoutException catch (e) {
      const errorMsg = 'Request timeout: The server took too long to respond. Please check your internet connection and try again.';
      if (kDebugMode) {
        print('❌ $errorMsg');
        print('Timeout details: ${e.toString()}');
      }
      return ApiCommonResponseBody(
        status: false,
        message: errorMsg,
      );
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: Unable to reach the server. Please check your internet connection. ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return ApiCommonResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Unexpected error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return ApiCommonResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<LoginResponseBody> refreshToken(String refreshToken) async {
    try {
      final url = Uri.parse(ApiConstants.refreshToken);

      if (kDebugMode) {
        print('📤 Sending refreshToken request to: $url');
      }

      final requestBody = {
        "refreshToken": refreshToken,

      };

      if (kDebugMode) {
        print('📥 Request body refreshToken : ${jsonEncode(requestBody)}');
      }

      final response = await http.post(
        url,
        headers: ApiConstants.headerWithToken(),
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      if (kDebugMode) {
        print('Response body refreshToken: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = LoginResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ refreshToken successful: ${result.message}');
        }
        return result;
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          final result = LoginResponseBody.fromJson(jsonResponse);
          if (kDebugMode) {
            print('❌ refreshToken failed with status ${response.statusCode}');
          }
          return LoginResponseBody(
            status: false,
            message: result.message ?? 'refreshToken failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } catch (parseError) {
          if (kDebugMode) {
            print('❌ Failed to parse error response: $parseError');
          }
          return LoginResponseBody(
            status: false,
            message: 'Server error: ${response.statusCode} - ${response.body}',
            statusCode: response.statusCode,
          );
        }
      }
    } on TimeoutException catch (e) {
      const errorMsg = 'Request timeout: The server took too long to respond. Please check your internet connection and try again.';
      if (kDebugMode) {
        print('❌ $errorMsg');
        print('Timeout details: ${e.toString()}');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: Unable to reach the server. Please check your internet connection. ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Unexpected error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }
      return LoginResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  /// ------------------GET METHOD --------------------------

    static Future<ActiveSessionResponseBody> getActiveSession() async {
      try {
      final url = Uri.parse(ApiConstants.activeSession);

      print('📤 Sending activeSession request to: $url');

      print('headers activeSession: ${ApiConstants.headerWithToken()}');

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      print('📥 Response status activeSession: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body activeSession: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ActiveSessionResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ activeSession successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = ActiveSessionResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ activeSession  failed with status ${response.statusCode}');
        }
        return result;

        //   GetProductTypeResponseBody(
        //   status: false,
        //   message: 'Executive Tracking failed. Status: ${result.message}',
        //   statusCode: response.statusCode,
        // );
      }
      } on http.ClientException catch (e) {
        final errorMsg = 'Network error in active Session: ${e.toString()}';
        print('❌ $errorMsg');
        return ActiveSessionResponseBody(
          status: false,
          message: errorMsg,
        );
      } catch (e) {
        final errorMsg = 'Error: ${e.toString()}';
        print('❌ $errorMsg');
        return ActiveSessionResponseBody(
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

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),
        ).timeout(_timeout);
      });


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
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading pending registrations from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.pendingRegistrations);

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return PendingRegistrationResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached pending registrations: $e');
            return PendingRegistrationResponseBody(
              status: false,
              message: 'Failed to load cached registrations: ${e.toString()}',
            );
          }
        }

        // No cache available
        return PendingRegistrationResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse(ApiConstants.pendingRegistrations);

      if (kDebugMode) {
        print('📤 Sending Pending User request to: $url');
        print('📤 Sending Pending User header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${SessionManager.getAccessToken()}',
          },

        ).timeout(_timeout);
      });

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

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                ApiConstants.pendingRegistrations,
                result,
                200,
              ),
            );
            print('📦 Cached pending registrations response');
          }
        } catch (e) {
          print('Error caching pending registrations: $e');
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

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.pendingRegistrations);
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return PendingRegistrationResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
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

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.pendingRegistrations);
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return PendingRegistrationResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return PendingRegistrationResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<AllUsersResponseBody> getAllUsers() async {
    try {
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading all users from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.allUsers);

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return AllUsersResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached all users: $e');
            return AllUsersResponseBody(
              status: false,
              message: 'Failed to load cached users: ${e.toString()}',
            );
          }
        }

        // No cache available
        return AllUsersResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse(ApiConstants.allUsers);

      if (kDebugMode) {
        print('📤 Sending All User request to: $url');
        print('📤 Sending All User header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 Response all user status: ${response.statusCode}');
        print('Response all user body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = AllUsersResponseBody.fromJson(jsonResponse);

        if (kDebugMode) {
          print('✅ all  User successful: ${result.message}');
        }

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                ApiConstants.allUsers,
                result,
                200,
              ),
            );
            print('📦 Cached all users response');
          }
        } catch (e) {
          print('Error caching all users: $e');
        }

        return result;
      } else {
        if (kDebugMode) {
          print('❌ All User failed with status ${response.statusCode}');
        }
        final jsonResponse = jsonDecode(response.body);
        final result = AllUsersResponseBody.fromJson(jsonResponse);
        return AllUsersResponseBody(
          status: false,
          message: result.message,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.allUsers);
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return AllUsersResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
      }

      return AllUsersResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.allUsers);
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return AllUsersResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return AllUsersResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<ExecutiveAttendanceResponseBody> executiveAttendance(String date) async {
    try {
    final url = Uri.parse("${ApiConstants.executiveAttendance}?date=$date");

    print('📤 Sending executiveAttendance request to: $url');


    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body: ${response.body}');

    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveAttendanceResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ executiveAttendance successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveAttendanceResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ executiveAttendance failed with status ${response.statusCode}');
      }
      return ExecutiveAttendanceResponseBody(
        status: false,
        message: 'Executive Attendance failed. Status: ${result.message}',
        statusCode: response.statusCode,
      );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error Executive Attendance: ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveAttendanceResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveAttendanceResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<ExecutiveTrackingByDaysResponse> executiveTrackingByDays(String userId, String date) async {
    try {
    final url = Uri.parse("${ApiConstants.executiveTrackingByDays}/$userId/days/$date");

    print('📤 Sending executiveTrackingByDays request to: $url');

    print('headers executiveTrackingByDays: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status executiveTrackingByDays: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body executiveTrackingByDays: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveTrackingByDaysResponse.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ executiveTrackingByDays successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveTrackingByDaysResponse.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ executiveTrackingByDays  failed with status ${response.statusCode}');
      }
      return ExecutiveTrackingByDaysResponse(
        status: false,
        message: 'Executive Tracking failed. Status: ${result.message}',
        statusCode: response.statusCode,
      );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error executiveTrackingByDays: ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveTrackingByDaysResponse(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveTrackingByDaysResponse(
        status: false,
        message: errorMsg,
      );
    }
  }

  static Future<ExecutiveAttendanceMonthlyResponseBody> executiveAttendanceMonthly(String userId,String fromDate,String toDate) async {
    try {
      final url = Uri.parse("${ApiConstants.executiveAttendanceDateWise}/$userId/attendance?from=$fromDate&to=$toDate");

      print('📤 Sending executiveAttendanceMonthly request to: $url');


      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');

      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ExecutiveAttendanceMonthlyResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ executiveAttendanceMonthly successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = ExecutiveAttendanceMonthlyResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ executiveAttendanceMonthly failed with status ${response.statusCode}');
        }
        return ExecutiveAttendanceMonthlyResponseBody(
          status: false,
          message: 'Executive Attendance Monthly failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error Executive Attendance Monthly : ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveAttendanceMonthlyResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return ExecutiveAttendanceMonthlyResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetProductTypeResponseBody> getProductType() async {
    try {
    final url = Uri.parse(ApiConstants.getProductType);

    print('📤 Sending getProductType request to: $url');

    print('headers getProductType: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getProductType: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getProductType: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetProductTypeResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getProductType successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetProductTypeResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getProductType  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getProductType: ${e.toString()}';
      print('❌ $errorMsg');
      return GetProductTypeResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetProductTypeResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetUtilitiesTypeResponseBody> getUtilities() async {
    try {
    final url = Uri.parse(ApiConstants.getUtilities);

    print('📤 Sending getUtilities request to: $url');

    print('headers getUtilities: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getUtilities: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getUtilities: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetUtilitiesTypeResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getUtilities successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetUtilitiesTypeResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getUtilities  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getUtilities : ${e.toString()}';
      print('❌ $errorMsg');
      return GetUtilitiesTypeResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetUtilitiesTypeResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetColorsResponseBody> getColors() async {
    try {
    final url = Uri.parse(ApiConstants.getColors);

    print('📤 Sending getColors request to: $url');

    print('headers getColors: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getColors: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getColors: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetColorsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getColors successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetColorsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getColors  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getColors: ${e.toString()}';
      print('❌ $errorMsg');
      return GetColorsResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetColorsResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetFinishesResponseBody> getFinishes() async {
    try {
    final url = Uri.parse(ApiConstants.getFinishes);

    print('📤 Sending getFinishes request to: $url');

    print('headers getFinishes: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getFinishes: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getFinishes: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetFinishesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getFinishes successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetFinishesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getFinishes  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getFinishes: ${e.toString()}';
      print('❌ $errorMsg');
      return GetFinishesResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetFinishesResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetTextureResponseBody> getTextures() async {
    try {
    final url = Uri.parse(ApiConstants.getTextures);

    print('📤 Sending getTextures request to: $url');

    print('headers getTextures: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getTextures: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getTextures: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetTextureResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getTextures successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetTextureResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getTextures  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getTextures: ${e.toString()}';
      print('❌ $errorMsg');
      return GetTextureResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetTextureResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetNaturalColorResponseBody> getNaturalColours() async {
    try {
    final url = Uri.parse(ApiConstants.getNaturalColors);

    print('📤 Sending getNaturalColors request to: $url');

    print('headers getNaturalColors: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getNaturalColors: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getNaturalColors: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetNaturalColorResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getNaturalColors successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetNaturalColorResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getNaturalColors  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getNaturalColors: ${e.toString()}';
      print('❌ $errorMsg');
      return GetNaturalColorResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetNaturalColorResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetOriginsResponseBody> getOrigins() async {
    try {
    final url = Uri.parse(ApiConstants.getOrigins);

    print('📤 Sending getOrigins request to: $url');

    print('headers getOrigins: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getOrigins: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getOrigins: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetOriginsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getOrigins successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetOriginsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getOrigins  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getOrigins: ${e.toString()}';
      print('❌ $errorMsg');
      return GetOriginsResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetOriginsResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetStateCountriesResponseBody> getStateCountries() async {
    try {
    final url = Uri.parse(ApiConstants.getStateCountries);

    print('📤 Sending getStateCountries request to: $url');

    print('headers getStateCountries: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    if (kDebugMode) {
      print('📥 Response status getStateCountries: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response body getStateCountries: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetStateCountriesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getStateCountries successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetStateCountriesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getStateCountries  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getStateCountries: ${e.toString()}';
      print('❌ $errorMsg');
      return GetStateCountriesResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetStateCountriesResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetProcessingNaturesResponseBody> getProcessingNature() async {
    try {
    final url = Uri.parse(ApiConstants.getProcessingNatures);

    print('📤 Sending getProcessingNatures request to: $url');

    print('headers getProcessingNatures: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getProcessingNatures: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getProcessingNatures: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetProcessingNaturesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getProcessingNatures successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetProcessingNaturesResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getProcessingNatures  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getProcessingNatures: ${e.toString()}';
      print('❌ $errorMsg');
      return GetProcessingNaturesResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetProcessingNaturesResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetMaterialNatureResponseBody> getNaturalMaterial() async {
    try {
    final url = Uri.parse(ApiConstants.getNaturalMaterials);

    print('📤 Sending getNaturalMaterials request to: $url');

    print('headers getNaturalMaterials: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getNaturalMaterials: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getNaturalMaterials: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetMaterialNatureResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getNaturalMaterials successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetMaterialNatureResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getNaturalMaterials  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getNaturalMaterials: ${e.toString()}';
      print('❌ $errorMsg');
      return GetMaterialNatureResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetMaterialNatureResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<GetHandicraftsResponseBody> getHandicraftsTypes() async {
    try {
    final url = Uri.parse(ApiConstants.getHandicraftsTypes);

    print('📤 Sending getHandicraftsTypes request to: $url');

    print('headers getHandicraftsTypes: ${ApiConstants.headerWithToken()}');

    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status getHandicraftsTypes: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body getHandicraftsTypes: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = GetHandicraftsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ getHandicraftsTypes successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = GetHandicraftsResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ getHandicraftsTypes  failed with status ${response.statusCode}');
      }
      return result;

      //   GetProductTypeResponseBody(
      //   status: false,
      //   message: 'Executive Tracking failed. Status: ${result.message}',
      //   statusCode: response.statusCode,
      // );
    }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error getHandicraftsTypes: ${e.toString()}';
      print('❌ $errorMsg');
      return GetHandicraftsResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetHandicraftsResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  /// Get Catalogue Product List - Fetch paginated product list
  ///
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Number of items per page (default: 20)
  ///
  /// Returns [GetCatalogueProductResponseBody] with product list and pagination info
  static Future<GetCatalogueProductResponseBody> getCatalogueProductList({int page = 1, int pageSize = 20, String? search}) async {
    try {
      final url = Uri.parse('${ApiConstants.getCatalogueProductList}?page=$page&pageSize=$pageSize${search!=null?"&search=$search":""}');
      if (kDebugMode) print('📤 Sending getCatalogueProductList request to: $url');

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 getCatalogueProductList status: ${response.statusCode}');
        print('📥 getCatalogueProductList body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Failed to fetch products',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ getCatalogueProductList error: $e');
      return GetCatalogueProductResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  /// Get Catalogue Product Details by ID
  ///
  /// Returns [GetCatalogueProductDetailsResponseBody] with detailed product information
  static Future<GetCatalogueProductDetailsResponseBody> getCatalogueProductDetails({required String productId,}) async
  {
    try {
      final url = Uri.parse('${ApiConstants.getCatalogueProductDetails}/$productId');
      if (kDebugMode) print('📤 Sending getCatalogueProductDetails request to: $url');

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 getCatalogueProductDetails status: ${response.statusCode}');
        print('📥 getCatalogueProductDetails body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductDetailsResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductDetailsResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Failed to fetch product details',
          statusCode: response.statusCode,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ getCatalogueProductDetails error: $e');
      return GetCatalogueProductDetailsResponseBody(
        status: false,
        message: e.toString(),
        statusCode: 500,
        data: null,
      );
    }
  }


  static Future<GetPriceRangeResponseBody> getPriceRange() async
  {
    try {
      final url = Uri.parse(ApiConstants.getPriceRange);
      if (kDebugMode) print('📤 Sending getPriceRange request to: $url');

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 getPriceRange status: ${response.statusCode}');
        print('📥 getPriceRange body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return GetPriceRangeResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return GetPriceRangeResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Failed to fetch product details',
          statusCode: response.statusCode,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ getPriceRange error: $e');
      return GetPriceRangeResponseBody(
        status: false,
        message: e.toString(),
        statusCode: 500,
        data: null,
      );
    }
  }



  static Future<GetMinesOptionResponseBody> getMinesOption() async
  {
    try {
      final url = Uri.parse(ApiConstants.getMinesOption);
      if (kDebugMode) print('📤 Sending getMinesOption request to: $url');

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 getMinesOption status: ${response.statusCode}');
        print('📥 getMinesOption body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return GetMinesOptionResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return GetMinesOptionResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Failed to fetch product details',
          statusCode: response.statusCode,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ getMinesOption error: $e');
      return GetMinesOptionResponseBody(
        status: false,
        message: e.toString(),
        statusCode: 500,
        data: null,
      );
    }
  }


    //--------Client -----------

  static Future<GetClientListResponseBody> getClientList(String? search, String? clientTypeCode) async {
    // Build query params outside try block so it's accessible in catch blocks
    final queryParams = <String>[];
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=$search');
    }
    if (clientTypeCode != null && clientTypeCode.isNotEmpty) {
      queryParams.add('clientTypeCode=$clientTypeCode');
    }
    final queryString = queryParams.isNotEmpty ? '&${queryParams.join('&')}' : '';

    try {
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading Clients List from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.getClientsList);

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return GetClientListResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached ClientsList: $e');
            return GetClientListResponseBody(
              status: false,
              message: 'Failed to load cached Clients List: ${e.toString()}',
            );
          }
        }

        // No cache available
        return GetClientListResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse("${ApiConstants.getClientsList}$queryString");

      if (kDebugMode) {
        print('📤 Sending getClientsList request to: $url');
        print('📤 Sending getClientsList header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 Response getClientsList status: ${response.statusCode}');
        print('Response getClientsList body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetClientListResponseBody.fromJson(jsonResponse);

        if (kDebugMode) {
          print('✅ getClientsList successful: ${result.message}');
        }

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                "${ApiConstants.getClientsList}$queryString",
                result,
                200,
              ),
            );
            print('📦 Cached getClientsList response');
          }
        } catch (e) {
          print('Error caching getClientsList: $e');
        }

        return result;
      } else {
        if (kDebugMode) {
          print('❌ getClientsList failed with status ${response.statusCode}');
        }
        final jsonResponse = jsonDecode(response.body);
        final result = GetClientListResponseBody.fromJson(jsonResponse);
        return GetClientListResponseBody(
          status: false,
          message: result.message,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getClientsList}$queryString");
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetClientListResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
      }

      return GetClientListResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getClientsList}${search!=null?"&search=$search":""}");
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetClientListResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return GetClientListResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



  static Future<GetClientIdDetailsResponseBody> getClientDetails(String clientId) async {
    try {
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading Clients List from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getClientsDetails}/$clientId");

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return GetClientIdDetailsResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached Clients Details: $e');
            return GetClientIdDetailsResponseBody(
              status: false,
              message: 'Failed to load cached Clients Details: ${e.toString()}',
            );
          }
        }

        // No cache available
        return GetClientIdDetailsResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse("${ApiConstants.getClientsDetails}/$clientId");

      if (kDebugMode) {
        print('📤 Sending Client Details request to: $url');
        print('📤 Sending getClients Details header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 Response getClients Details status: ${response.statusCode}');
        print('Response getClients Details body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetClientIdDetailsResponseBody.fromJson(jsonResponse);

        if (kDebugMode) {
          print('✅ getClients Details successful: ${result.message}');
        }

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                "${ApiConstants.getClientsDetails}/$clientId" ,
                result,
                200,
              ),
            );
            print('📦 Cached getClientsList response');
          }
        } catch (e) {
          print('Error caching getClientsList: $e');
        }

        return result;
      } else {
        if (kDebugMode) {
          print('❌ getClients Details failed with status ${response.statusCode}');
        }
        final jsonResponse = jsonDecode(response.body);
        final result = GetClientIdDetailsResponseBody.fromJson(jsonResponse);
        return GetClientIdDetailsResponseBody(
          status: false,
          message: result.message,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getClientsDetails}/$clientId");
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetClientIdDetailsResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
      }

      return GetClientIdDetailsResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getClientsDetails}/$clientId");
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetClientIdDetailsResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return GetClientIdDetailsResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



    //--------MOM -----------

  static Future<GetMomResponseBody> getMomList() async {
    try {
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading MOM List from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.getMomList);

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return GetMomResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached MOM List: $e');
            return GetMomResponseBody(
              status: false,
              message: 'Failed to load cached MOM List: ${e.toString()}',
            );
          }
        }

        // No cache available
        return GetMomResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse(ApiConstants.getMomList);

      if (kDebugMode) {
        print('📤 Sending get MOM List request to: $url');
        print('📤 Sending get MOM List header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 Response getMOMList status: ${response.statusCode}');
        print('Response getMOMList body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetMomResponseBody.fromJson(jsonResponse);

        if (kDebugMode) {
          print('✅ getMOMList successful: ${result.message}');
        }

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                ApiConstants.getMomList,
                result,
                200,
              ),
            );
            print('📦 Cached getMOMList response');
          }
        } catch (e) {
          print('Error caching getMOMList: $e');
        }

        return result;
      } else {
        if (kDebugMode) {
          print('❌ getMOMList failed with status ${response.statusCode}');
        }
        final jsonResponse = jsonDecode(response.body);
        final result = GetMomResponseBody.fromJson(jsonResponse);
        return GetMomResponseBody(
          status: false,
          message: result.message,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.getMomList);
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetMomResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
      }

      return GetMomResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse(ApiConstants.getMomList);
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetMomResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return GetMomResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



  static Future<GetMomIdDetailsResponseBody> getMomIdDetails(String momId) async {
    try {
      // Check connectivity first
      final hasConnection = await hasConnectivity();

      // If offline, try to load from cache
      if (!hasConnection) {
        print('📍 No connectivity - Loading Mom List from local cache');
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getMomDetails}/$momId");

        if (cachedData?.responseData != null) {
          try {
            final jsonData = jsonDecode(cachedData!.responseData!);
            return GetMomIdDetailsResponseBody.fromJson(jsonData);
          } catch (e) {
            print('Error parsing cached MOM Details: $e');
            return GetMomIdDetailsResponseBody(
              status: false,
              message: 'Failed to load cached MOM Details: ${e.toString()}',
            );
          }
        }

        // No cache available
        return GetMomIdDetailsResponseBody(
          status: false,
          message: 'No internet connectivity and no cached data available',
        );
      }

      // Online - fetch from API
      final url = Uri.parse("${ApiConstants.getMomDetails}/$momId");

      if (kDebugMode) {
        print('📤 Sending MOM Details request to: $url');
        print('📤 Sending getMOM Details header: ${ApiConstants.headerWithToken}');
      }

      final response = await ApiClient.send(() {
        return http.get(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 Response getMOM Details status: ${response.statusCode}');
        print('Response getMOM Details body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetMomIdDetailsResponseBody.fromJson(jsonResponse);

        if (kDebugMode) {
          print('✅ getMOM Details successful: ${result.message}');
        }

        // Cache successful response
        try {
          if (result.status == true && result.data != null) {
            await AppBlocProvider.cacheRepository.saveCachedResponse(
              _createCachedResponse(
                "${ApiConstants.getMomDetails}/$momId" ,
                result,
                200,
              ),
            );
            print('📦 Cached getMOMDetails response');
          }
        } catch (e) {
          print('Error caching getMom Details: $e');
        }

        return result;
      } else {
        if (kDebugMode) {
          print('❌ get MOM Details failed with status ${response.statusCode}');
        }
        final jsonResponse = jsonDecode(response.body);
        final result = GetMomIdDetailsResponseBody.fromJson(jsonResponse);
        return GetMomIdDetailsResponseBody(
          status: false,
          message: result.message,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on network error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getMomDetails}/$momId");
        if (cachedData?.responseData != null) {
          print('📍 Network error - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetMomIdDetailsResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on network error: $cacheError');
      }

      return GetMomIdDetailsResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ $errorMsg');
      }

      // Try to return cached data on error
      try {
        final cachedData = await AppBlocProvider.cacheRepository
            .getCachedResponse("${ApiConstants.getMomDetails}/$momId");
        if (cachedData?.responseData != null) {
          print('📍 Error occurred - Falling back to cached data');
          final jsonData = jsonDecode(cachedData!.responseData!);
          return GetMomIdDetailsResponseBody.fromJson(jsonData);
        }
      } catch (cacheError) {
        print('Error loading cache on error: $cacheError');
      }

      return GetMomIdDetailsResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }

  ///-----------------PATCH METHOD --------------------------

  static Future<GetProfileResponseBody> updateProfile(GetProfileRequestBody requestBody) async {
    try {
      final url = Uri.parse(ApiConstants.updateProfile);

      print('📤 Sending updateProfile request to: $url');
      print('Request body: ${requestBody.toJson()}');

      final response = await ApiClient.send(() {
        return http.patch(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = GetProfileResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ update Profile successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = GetProfileResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ Update Profile failed with status ${response.statusCode}');
        }
        return GetProfileResponseBody(
          status: false,
          message: 'Update Profile failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error login: ${ErrorMessages.networkError}';
      print('❌ $errorMsg');
      return GetProfileResponseBody(
        status: false,
        message:errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return GetProfileResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }


  static Future<ApproveResponseBody> approvePendingUsers(ApproveRequestBody requestBody,String id) async {
    try {
      final url = Uri.parse("${ApiConstants.approveRegistration}/$id");

      print('📤 Sending approveRegistration request to: $url');
      print('Request body: ${requestBody.toJson()}');

      final response = await ApiClient.send(() {
        return http.patch(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ApproveResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ approveRegistration successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = ApproveResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ Registration failed with status ${response.statusCode}');
        }
        return ApproveResponseBody(
          status: false,
          message: 'Approved failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error login: ${e.toString()}';
      print('❌ $errorMsg');
      return ApproveResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return ApproveResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }




  /// ---------------- DELETE METHOD -------------------------

  static Future<ApproveResponseBody> rejectPendingUsers(String id) async {
    try {
      final url = Uri.parse("${ApiConstants.rejectRegistration}/$id");

      print('📤 Sending rejectRegistration request to: $url');


      final response = await ApiClient.send(() {
        return http.delete(
          url,
          headers: ApiConstants.headerWithToken(),

        ).timeout(_timeout);
      });

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ApproveResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('✅ rejectRegistration successful: ${result.message}');
        }
        return result;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = ApproveResponseBody.fromJson(jsonResponse);
        if (kDebugMode) {
          print('❌ Rejection failed with status ${response.statusCode}');
        }
        return ApproveResponseBody(
          status: false,
          message: 'Registration failed. Status: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error login: ${e.toString()}';
      print('❌ $errorMsg');
      return ApproveResponseBody(
        status: false,
        message: errorMsg,
      );
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      print('❌ $errorMsg');
      return ApproveResponseBody(
        status: false,
        message: errorMsg,
      );
    }
  }



  /// Check if device has internet connectivity
  static Future<bool> hasConnectivity() async {
    try {
      final connectivityService = AppBlocProvider.connectivityService;
      return connectivityService.isOnline;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }


  /// Helper method to create cached response object
  static _createCachedResponse(String endpoint, dynamic data, int statusCode) {
    try {
      final jsonString = jsonEncode(data);
      return CachedResponse(
        id: endpoint,
        endpoint: endpoint,
        responseData: jsonString,
        statusCode: statusCode,
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        requestMethod: 'GET',
      );
    } catch (e) {
      print('Error creating cached response: $e');
      return null;
    }
  }


  ///---------------------POST METHOD ---------------------------

  static Future<PunchInOutResponseBody> punchIn(PunchInOutRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.punchIn);
      if (kDebugMode) print('📤 Sending punchIn request to: $url');
      if (kDebugMode) print('📤 Sending headers: ${ApiConstants.headerWithToken()}');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 punchIn status: ${response.statusCode}');
        print('📥 punchIn request body: ${jsonEncode(body.toJson())}');
        print('📥 punchIn body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PunchInOutResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PunchInOutResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Punch in failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ punchIn error: $e');
      return PunchInOutResponseBody(status: false, message: e.toString());
    }
  }

  static Future<PunchInOutResponseBody> punchOut(PunchInOutRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.punchOut);
      if (kDebugMode) print('📤 Sending punchOut request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 punchOut status: ${response.statusCode}');
        print('📥 punchOut body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PunchInOutResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PunchInOutResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Punch out failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ punchOut error: $e');
      return PunchInOutResponseBody(status: false, message: e.toString());
    }
  }


  // static Future<ApiCommonResponseBody> locationPing(PunchInOutRequestBody requestBody) async {
  //   // try {
  //     final url = Uri.parse(ApiConstants.locationPing);
  //
  //     print('📤 Sending locationPing request to: $url');
  //     print('Request body: ${json.encode(requestBody)}');
  //     print('headers: ${ApiConstants.headerWithToken()}');
  //     print('headers: ${SessionManager.getAccessTokenSync()}');
  //
  //     final response = await
  //     // ApiClient.send(() {
  //     //   return http.post(
  //     //     url,
  //     //     headers: {
  //     //       'Content-Type': 'application/json',
  //     //       'Authorization': 'Bearer ${SessionManager.getAccessTokenSync()}',
  //     //     },
  //     //     body: jsonEncode(requestBody.toJson()),
  //     //   ).timeout(_timeout);
  //     // });
  //     http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${SessionManager.getAccessTokenSync()}',
  //       },
  //       body: jsonEncode(requestBody.toJson()),
  //     ).timeout(_timeout);
  //
  //     print('📥 Response status: ${response.statusCode}');
  //     if (kDebugMode) {
  //       print('Response body: ${response.body}');
  //     }
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final jsonResponse = jsonDecode(response.body);
  //       final result = ApiCommonResponseBody.fromJson(jsonResponse);
  //       if (kDebugMode) {
  //         print('✅ locationPing successful: ${result.message}');
  //       }
  //       return result;
  //     } else {
  //       final jsonResponse = jsonDecode(response.body);
  //       final result = ApiCommonResponseBody.fromJson(jsonResponse);
  //       if (kDebugMode) {
  //         print('❌ locationPing failed with status ${response.statusCode}');
  //       }
  //       return ApiCommonResponseBody(
  //         status: false,
  //         message: 'Location Ping failed. Status: ${result.message}',
  //         statusCode: response.statusCode,
  //       );
  //     }
  //   // } on http.ClientException catch (e) {
  //   //   final errorMsg = 'Network error login: ${e.toString()}';
  //   //   print('❌ $errorMsg');
  //   //   return ApiCommonResponseBody(
  //   //     status: false,
  //   //     message: errorMsg,
  //   //   );
  //   // } catch (e) {
  //   //   final errorMsg = 'Error: ${e.toString()}';
  //   //   print('❌ $errorMsg');
  //   //   return ApiCommonResponseBody(
  //   //     status: false,
  //   //     message: errorMsg,
  //   //   );
  //   // }
  // }
  //
  //

  static Future<ApiCommonResponseBody> locationPing(PunchInOutRequestBody requestBody) async {
    try {
      final url = Uri.parse(ApiConstants.locationPing);

      print('📤 Sending locationPing request to: $url');
      print('Request body: ${json.encode(requestBody)}');

      // ✅ Ensure SessionManager is ready


      print('🔑 Access Token: ${SessionManager.getAccessToken()}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SessionManager.getAccessToken()}',
        },
        body: jsonEncode(requestBody.toJson()),
      ).timeout(_timeout);

      print('📥 Response status: ${response.statusCode}');
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final result = ApiCommonResponseBody.fromJson(jsonResponse);
        print('✅ locationPing successful: ${result.message}');
        return result;
      } else if (response.statusCode == 401) {
        // ✅ FIXED: Handle 401 without void method
        print('🔓 Token expired - clearing session locally');

        // Option 1: Clear session locally (no bloc needed)
        await SessionManager.logout();

        // Option 2: Dispatch logout event (if you have AuthBloc)
        // context.read<AuthBloc>().add(AuthLogoutRequested());

        return ApiCommonResponseBody(
          status: false,
          message: 'Session expired. Please login again.',
          statusCode: 401,
        );
      } else {
        final jsonResponse = jsonDecode(response.body);
        final result = ApiCommonResponseBody.fromJson(jsonResponse);
        print('❌ locationPing failed with status ${response.statusCode}');
        return ApiCommonResponseBody(
          status: false,
          message: 'Location Ping failed: ${result.message}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      print('❌ Network error locationPing: ${e.toString()}');
      return ApiCommonResponseBody(
        status: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    } catch (e) {
      print('❌ Unexpected error locationPing: $e');
      return ApiCommonResponseBody(
        status: false,
        message: 'Error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }


  static Future<PostCatalogueCommonResponseBody> postColors(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postColors);
      if (kDebugMode) print('📤 Sending postColors request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postColors status: ${response.statusCode}');
        print('📥 postColors body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Colors failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postColors error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postFinishes(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postFinishes);
      if (kDebugMode) print('📤 Sending postFinishes request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postFinishes status: ${response.statusCode}');
        print('📥 postFinishes body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Finishes failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postFinishes error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postTextures(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postTextures);
      if (kDebugMode) print('📤 Sending postTextures request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postTextures status: ${response.statusCode}');
        print('📥 postTextures body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Texture failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postTextures error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postNaturalColors(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postNaturalColors);
      if (kDebugMode) print('📤 Sending postNaturalColors request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postNaturalColors status: ${response.statusCode}');
        print('📥 postNaturalColors body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Colors failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postNaturalColors error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postOrigins(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postOrigins);
      if (kDebugMode) print('📤 Sending postOrigins request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postOrigins status: ${response.statusCode}');
        print('📥 postOrigins body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Origin failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postOrigins error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postStateCountries(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postStateCountries);
      if (kDebugMode) print('📤 Sending postStateCountries request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postStateCountries status: ${response.statusCode}');
        print('📥 postStateCountries body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert State Countries failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postStateCountries error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postProcessingNatures(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postProcessingNatures);
      if (kDebugMode) print('📤 Sending postProcessingNatures request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postProcessingNatures status: ${response.statusCode}');
        print('📥 postProcessingNatures body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert postProcessing Natures failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postProcessingNatures error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postNaturalMaterials(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postNaturalMaterials);
      if (kDebugMode) print('📤 Sending postColors request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postNaturalMaterials status: ${response.statusCode}');
        print('📥 postNaturalMaterials body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Natural Materials failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postNaturalMaterials error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<PostCatalogueCommonResponseBody> postHandicraftsTypes(PostCatalogueCommonRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postHandicraftsTypes);
      if (kDebugMode) print('📤 Sending postHandicraftsTypes request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postHandicraftsTypes status: ${response.statusCode}');
        print('📥 postHandicraftsTypes body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostCatalogueCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Insert Handicrafts failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postHandicraftsTypes error: $e');
      return PostCatalogueCommonResponseBody(status: false, message: e.toString());
    }
  }


  static Future<ProductEntryResponseBody> postProductEntry(ProductEntryRequestBody body) async {
    try {
      final url = Uri.parse(ApiConstants.postProductEntry);
      if (kDebugMode) print('📤 Sending postProductEntry request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(body.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postProductEntry status: ${response.statusCode}');
        print('📥 postProductEntry body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ProductEntryResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return ProductEntryResponseBody.fromJson(jsonResponse);
        //   ProductEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Insert Product failed',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postProductEntry error: $e');
      return ProductEntryResponseBody(status: false, message: e.toString());
    }
  }

  /// Post Image Entry - Upload product image with multipart form data
  ///
  /// Parameters:
  /// - [productId]: The product ID to associate the image with
  /// - [imageFile]: The image file to upload
  /// - [setAsPrimary]: Whether to set as primary image (default: false)
  /// - [sortOrder]: Sort order for the image (default: 0)
  ///
  /// Returns [CatalogueImageEntryResponseBody] with uploaded image details
  static Future<CatalogueImageEntryResponseBody> postImageEntry({
    required String productId,
    required File imageFile,
    bool setAsPrimary = false,
    int sortOrder = 0,
  }) async
  {
    try {
      final url = Uri.parse('${ApiConstants.postImageEntry}/$productId/images');
      if (kDebugMode) print('📤 Sending postImageEntry request to: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers (token authentication)
      final headers = ApiConstants.headerWithToken();
      request.headers.addAll({
        'Authorization': headers['Authorization'] ?? '',
      });

      // Add the image file
      var multipartFile = await http.MultipartFile.fromPath(
        'File',
        imageFile.path,
        // contentType is automatically detected from file extension
      );
      request.files.add(multipartFile);

      // Add form fields
      request.fields['SetAsPrimary'] = setAsPrimary.toString();
      request.fields['SortOrder'] = sortOrder.toString();

      if (kDebugMode) {
        print('📤 Upload details:');
        print('   - File: ${imageFile.path}');
        print('   - Size: ${await imageFile.length()} bytes');
        print('   - SetAsPrimary: $setAsPrimary');
        print('   - SortOrder: $sortOrder');
      }

      // Send request
      final streamedResponse = await request.send().timeout(_timeout);

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📥 postImageEntry status: ${response.statusCode}');
        print('📥 postImageEntry body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return CatalogueImageEntryResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return CatalogueImageEntryResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Image upload failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postImageEntry error: $e');
      return CatalogueImageEntryResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  /// Put Catalogue Options Entry - Update product with selected options
  ///
  /// Parameters:
  /// - [productId]: The product ID to update
  /// - [requestBody]: Contains all selected option IDs (colors, finishes, etc.)
  ///
  /// Returns [ApiCommonResponseBody] with update status
  static Future<ApiCommonResponseBody> putCatalogueOptionsEntry({
    required String productId,
    required PutCatalogueOptionEntryRequestBody requestBody,
  })
  async {
    try {
      final url = Uri.parse('${ApiConstants.putCatalogueOptionsEntry}/$productId/options');
      if (kDebugMode) print('📤 Sending putCatalogueOptionsEntry request to: $url');

      final response = await ApiClient.send(() {
        return http.put(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 putCatalogueOptionsEntry status: ${response.statusCode}');
        print('📥 putCatalogueOptionsEntry request: ${jsonEncode(requestBody.toJson())}');
        print('📥 putCatalogueOptionsEntry body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ApiCommonResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return ApiCommonResponseBody(
          status: false,
          message: jsonResponse['message'] ?? 'Failed to update product options',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ putCatalogueOptionsEntry error: $e');
      return ApiCommonResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }



  static Future<PostMinesEntryResponseBody> postMinesEntry({
    required PostMinesEntryRequestBody requestBody,
  })
  async {
    try {
      final url = Uri.parse(ApiConstants.postMinesEntry);
      if (kDebugMode) print('📤 Sending postMinesEntry request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postMinesEntry status: ${response.statusCode}');
        print('📥 postMinesEntry request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postMinesEntry body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostMinesEntryResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostMinesEntryResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postMinesEntry error: $e');
      return PostMinesEntryResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<PostMomImageUploadResponseBody> postMomImageUpload({
    required String momId,
    required File imageFile,
    required String? caption,
    int sortOrder = 0,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.postMomImage}/$momId/images');

      if (kDebugMode) {
        print('📤 Sending postMomImageUpload request to: $url');
      }

      /// Create multipart request
      final request = http.MultipartRequest('POST', url);

      /// Add headers (Authorization token)
      final headers = ApiConstants.headerWithToken();
      request.headers.addAll({
        'Authorization': headers['Authorization'] ?? '',
      });

      /// Add image file
      final multipartFile = await http.MultipartFile.fromPath(
        'File', // MUST match backend key
        imageFile.path,
      );
      request.files.add(multipartFile);

      /// Add form fields
      request.fields['Caption'] = caption ?? "";
      request.fields['SortOrder'] = sortOrder.toString();

      if (kDebugMode) {
        print('📤 Upload details:');
        print('   - File: ${imageFile.path}');
        print('   - Size: ${await imageFile.length()} bytes');
        print('   - Caption: $caption');
        print('   - SortOrder: $sortOrder');
      }

      /// Send request
      final streamedResponse = await request.send().timeout(_timeout);

      /// Convert stream to response
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📥 postMomImageUpload status: ${response.statusCode}');
        print('📥 postMomImageUpload body: ${response.body}');
      }

      /// Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostMomImageUploadResponseBody.fromJson(jsonResponse);
      }

      /// Handle failure
      final jsonResponse = jsonDecode(response.body);
      return PostMomImageUploadResponseBody(
        status: false,
        message: jsonResponse['message'] ?? 'MOM image upload failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ postMomImageUpload error: $e');
      }
      return PostMomImageUploadResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }


  static Future<GetCatalogueProductResponseBody> postSearch({
    required PostSearchRequestBody requestBody,
  })
  async {
    try {
      final url = Uri.parse(ApiConstants.postSearch);
      if (kDebugMode) print('📤 Sending postSearch request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postSearch status: ${response.statusCode}');
        print('📥 postSearch request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postSearch body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return GetCatalogueProductResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postSearch error: $e');
      return GetCatalogueProductResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<PostMomEntryResponseBody> postMomEntry({
    required PostSearchRequestBody requestBody,
  })
  async {
    try {
      final url = Uri.parse(ApiConstants.postMomEntry);
      if (kDebugMode) print('📤 Sending postMomEntry request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postMomEntry status: ${response.statusCode}');
        print('📥 postMomEntry request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postMomEntry body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostMomEntryResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostMomEntryResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postMomEntry error: $e');
      return PostMomEntryResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<PostClientAddResponseBody> postClientAdd({
    required PostClientAddRequestBody requestBody,
  })
  async {
    try {
      final url = Uri.parse(ApiConstants.postClients);
      if (kDebugMode) print('📤 Sending postClients request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postClients status: ${response.statusCode}');
        print('📥 postClients request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postClients body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postClients error: $e');
      return PostClientAddResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<PostClientAddContactResponseBody> postClientAddContact({
    required PostClientAddContactRequestBody requestBody,
    required String clientId,
    required String locationId
  })
  async {
    try {
      final url = Uri.parse("${ApiConstants.postClients}/$clientId/locations/$locationId/contacts");
      if (kDebugMode) print('📤 Sending postClients contacts request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postClients contacts status: ${response.statusCode}');
        print('📥 postClients contacts request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postClients contacts body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddContactResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddContactResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postClients contacts error: $e');
      return PostClientAddContactResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<PostClientAddLocationResponseBody> postClientAddLocation({
    required PostClientAddLocationRequestBody requestBody,
    required String clientId,
  })
  async {
    try {
      final url = Uri.parse("${ApiConstants.postClients}/$clientId/locations");
      if (kDebugMode) print('📤 Sending postClients locations request to: $url');

      final response = await ApiClient.send(() {
        return http.post(
          url,
          headers: ApiConstants.headerWithToken(),
          body: jsonEncode(requestBody.toJson()),
        ).timeout(_timeout);
      });

      if (kDebugMode) {
        print('📥 postClients locations status: ${response.statusCode}');
        print('📥 postClients locations request: ${jsonEncode(requestBody.toJson())}');
        print('📥 postClients locations body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddLocationResponseBody.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return PostClientAddLocationResponseBody.fromJson(jsonResponse);
        // return PostMinesEntryResponseBody(
        //   status: false,
        //   message: jsonResponse['message'] ?? 'Failed to update product options',
        //   statusCode: response.statusCode,
        // );
      }
    } catch (e) {
      if (kDebugMode) print('❌ postClients locations error: $e');
      return PostClientAddLocationResponseBody(
        status: false,
        message: e.toString(),
      );
    }
  }


}
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
