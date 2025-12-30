import 'dart:convert';
import 'dart:async';

import 'package:apclassstone/api/models/request/ApproveRequestBody.dart';
import 'package:apclassstone/api/models/request/PostCatalogueCommonRequestBody.dart';
import 'package:apclassstone/api/models/request/ProductEntryRequestBody.dart';
import 'package:apclassstone/api/models/response/AllUsersResponseBody.dart';
import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';
import 'package:apclassstone/api/models/response/ApproveResponseBody.dart';
import 'package:apclassstone/api/models/response/ExecutiveAttendanceResponseBody.dart';
import 'package:apclassstone/api/models/response/ExecutiveTrackingByDaysResponse.dart';
import 'package:apclassstone/api/models/response/GetFinishesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetHandicraftsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMaterialNatureResponseBody.dart';
import 'package:apclassstone/api/models/response/GetNaturalColorResponseBody.dart';
import 'package:apclassstone/api/models/response/GetOriginsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProcessingNaturesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProfileResponseBody.dart';
import 'package:apclassstone/api/models/response/GetStateCountriesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetTextureResponseBody.dart';
import 'package:apclassstone/api/models/response/LoginResponseBody.dart';
import 'package:apclassstone/api/models/response/PostCatalogueCommonResponseBody.dart';
import 'package:apclassstone/api/models/response/ProductEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/PunchInOutResponseBody.dart';
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
    // try {
    final url = Uri.parse("${ApiConstants.executiveAttendance}?date=$date");

    print('📤 Sending locationPing request to: $url');


    final response = await ApiClient.send(() {
      return http.get(
        url,
        headers: ApiConstants.headerWithToken(),

      ).timeout(_timeout);
    });

    print('📥 Response status: ${response.statusCode}');
    if (kDebugMode) {
      print('Response body: ${response.body}');
      print('headers body: ${ApiConstants.headerWithToken}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveAttendanceResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('✅ locationPing successful: ${result.message}');
      }
      return result;
    } else {
      final jsonResponse = jsonDecode(response.body);
      final result = ExecutiveAttendanceResponseBody.fromJson(jsonResponse);
      if (kDebugMode) {
        print('❌ locationPing failed with status ${response.statusCode}');
      }
      return ExecutiveAttendanceResponseBody(
        status: false,
        message: 'Location Ping failed. Status: ${result.message}',
        statusCode: response.statusCode,
      );
    }
    // } on http.ClientException catch (e) {
    //   final errorMsg = 'Network error login: ${e.toString()}';
    //   print('❌ $errorMsg');
    //   return ApiCommonResponseBody(
    //     status: false,
    //     message: errorMsg,
    //   );
    // } catch (e) {
    //   final errorMsg = 'Error: ${e.toString()}';
    //   print('❌ $errorMsg');
    //   return ApiCommonResponseBody(
    //     status: false,
    //     message: errorMsg,
    //   );
    // }
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
