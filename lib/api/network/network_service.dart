import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class NetworkService {
  static NetworkService? _instance;
  late Dio _dio;

  NetworkService._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  static NetworkService get instance {
    _instance ??= NetworkService._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: int.parse(AppConstants.apiTimeout));
    _dio.options.receiveTimeout = Duration(seconds: int.parse(AppConstants.apiTimeout));

    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.userTokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );

    // Logging Interceptor (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (object) {
          print('[API] $object');
        },
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);

    // Navigate to login screen
    // This would typically be handled by the BLoC layer
  }

  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: ErrorMessages.timeoutError,
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = ErrorMessages.genericError;

        if (statusCode == 401) {
          message = ErrorMessages.unauthorizedAccess;
        } else if (statusCode == 404) {
          message = ErrorMessages.userNotFound;
        } else if (error.response?.data != null && error.response?.data['message'] != null) {
          message = error.response?.data['message'];
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          details: error.response?.data?.toString(),
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: ErrorMessages.networkError,
          statusCode: error.response?.statusCode,
        );
    }
  }
}
