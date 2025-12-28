import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/session/session_manager.dart';
import '../../data/local/cache_repository.dart';
import '../../data/local/queue_repository.dart';
import '../../data/models/cached_response.dart';
import '../../data/models/queued_request.dart';

/// Wraps API calls with offline support and queuing
class OfflineApiWrapper {
  static OfflineApiWrapper? _instance;

  final CacheRepository _cacheRepository;
  final QueueRepository _queueRepository;
  final ConnectivityService _connectivityService;
  final Dio _dio;

  static const _uuid = Uuid();

  // Exclude these endpoints from queuing (must be real-time)
  static const List<String> _excludedFromQueue = [
    'auth/login',
    'login/sendotp',
    'login/verifyotp',
    'loginWithPassword',
  ];

  OfflineApiWrapper._internal(
    this._cacheRepository,
    this._queueRepository,
    this._connectivityService,
    this._dio,
  );

  static OfflineApiWrapper get instance {
    if (_instance == null) {
      throw Exception('OfflineApiWrapper not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize({
    required CacheRepository cacheRepository,
    required QueueRepository queueRepository,
    required ConnectivityService connectivityService,
    required Dio dio,
  }) async {
    _instance = OfflineApiWrapper._internal(
      cacheRepository,
      queueRepository,
      connectivityService,
      dio,
    );
  }

  /// Make GET request with offline support
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    bool useCache = true,
  }) async {
    return _executeWithOfflineSupport(
      endpoint,
      'GET',
      queryParameters: queryParameters,
      options: options,
      cacheDuration: cacheDuration,
      useCache: useCache,
    );
  }

  /// Make POST request with offline support and queuing
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    bool shouldQueue = true,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    return _executeWithOfflineSupport(
      endpoint,
      'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cacheDuration: cacheDuration,
      shouldQueue: shouldQueue,
      userId: userId,
      metadata: metadata,
    );
  }

  /// Make PUT request with offline support and queuing
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    bool shouldQueue = true,
    String? userId,
  }) async {
    return _executeWithOfflineSupport(
      endpoint,
      'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cacheDuration: cacheDuration,
      shouldQueue: shouldQueue,
      userId: userId,
    );
  }

  /// Make DELETE request with offline support and queuing
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool shouldQueue = true,
    String? userId,
  }) async {
    return _executeWithOfflineSupport(
      endpoint,
      'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: options,
      shouldQueue: shouldQueue,
      userId: userId,
    );
  }

  /// Execute API request with offline support
  Future<Response> _executeWithOfflineSupport(
    String endpoint,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    bool useCache = true,
    bool shouldQueue = false,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    // Check for cached response first (for GET requests)
    if (useCache && method == 'GET') {
      final cached = await _cacheRepository.getCachedResponse(endpoint);
      if (cached != null && cached.responseData != null) {
        print('[OfflineAPI] Returning cached response for: $endpoint');
        return Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: cached.statusCode,
          data: jsonDecode(cached.responseData!),
        );
      }
    }

    // Try to make the request if online
    if (_connectivityService.isOnline) {
      try {
        print('[OfflineAPI] Making online request: $method $endpoint');
        final response = await _dio.request(
          endpoint,
          queryParameters: queryParameters,
          options: Options(
            method: method,
            headers: options?.headers,
          ),
          data: data,
        );

        // Cache successful responses
        if (response.statusCode != null && response.statusCode! < 400) {
          await _cacheResponse(endpoint, response, cacheDuration ?? const Duration(minutes: 30));
        }

        return response;
      } on DioException catch (e) {
        // Handle connectivity or request errors
        if (e.error is SocketException || e.type == DioExceptionType.connectionTimeout) {
          print('[OfflineAPI] Request failed, attempting offline/queue fallback');
          return _handleOfflineRequest(
            endpoint,
            method,
            data,
            shouldQueue,
            userId,
            metadata,
          );
        }
        rethrow;
      }
    } else {
      // Offline: return cached or queue
      print('[OfflineAPI] Offline mode: handling request for $endpoint');
      return _handleOfflineRequest(
        endpoint,
        method,
        data,
        shouldQueue,
        userId,
        metadata,
      );
    }
  }

  /// Handle request when offline
  Future<Response> _handleOfflineRequest(
    String endpoint,
    String method,
    dynamic data,
    bool shouldQueue,
    String? userId,
    Map<String, dynamic>? metadata,
  ) async {
    // For GET requests, try to return cached data
    if (method == 'GET') {
      final cached = await _cacheRepository.getCachedResponse(endpoint);
      if (cached != null && cached.responseData != null) {
        return Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: cached.statusCode,
          data: jsonDecode(cached.responseData!),
        );
      }

      throw Exception('No cached data available for offline GET request');
    }

    // For POST/PUT/DELETE, queue if enabled and not excluded
    if (shouldQueue && !_isExcludedFromQueue(endpoint)) {
      await _queueRequest(
        endpoint,
        method,
        data,
        userId,
        metadata,
      );

      return Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 202, // Accepted - queued
        data: {
          'message': 'Request queued for processing',
          'status': 'queued',
          'endpoint': endpoint,
        },
      );
    }

    // If not queued and offline, throw error
    throw Exception(
      'Request cannot be processed. No connectivity and queuing is disabled for this endpoint.',
    );
  }

  /// Queue request for later processing
  Future<void> _queueRequest(
    String endpoint,
    String method,
    dynamic data,
    String? userId,
    Map<String, dynamic>? metadata,
  ) async {
    final requestId = _uuid.v4();

    print('[OfflineAPI] Queuing request: $method $endpoint');

    final queuedRequest = QueuedRequest(
      id: requestId,
      endpoint: endpoint,
      method: method.toUpperCase(),
      requestBody: data != null ? jsonEncode(data) : null,
      headers: {'Authorization': 'Bearer ${SessionManager.getAccessToken() ?? ''}'},
      status: QueueRequestStatus.pending,
      createdAt: DateTime.now(),
      retryCount: 0,
      userId: userId,
      metadata: metadata,
    );

    await _queueRepository.addToQueue(queuedRequest);
  }

  /// Cache API response
  Future<void> _cacheResponse(
    String endpoint,
    Response response,
    Duration duration,
  ) async {
    try {
      final cached = CachedResponse(
        id: endpoint,
        endpoint: endpoint,
        responseData: jsonEncode(response.data),
        statusCode: response.statusCode ?? 200,
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(duration),
        requestMethod: 'GET',
      );

      await _cacheRepository.saveCachedResponse(cached);
      print('[OfflineAPI] Cached response for: $endpoint');
    } catch (e) {
      print('[OfflineAPI] Error caching response: $e');
    }
  }

  /// Check if endpoint should be excluded from queuing
  bool _isExcludedFromQueue(String endpoint) {
    return _excludedFromQueue.any((excluded) => endpoint.contains(excluded));
  }

  /// Get queue status (visible to super admin)
  Future<QueueStatus> getQueueStatus() async {
    final stats = await _queueRepository.getQueueStatistics();
    return QueueStatus(
      totalQueued: stats.totalCount,
      pending: stats.pendingCount,
      failed: stats.failedCount,
      successful: stats.successCount,
      lastChecked: DateTime.now(),
    );
  }
}

class QueueStatus {
  final int totalQueued;
  final int pending;
  final int failed;
  final int successful;
  final DateTime lastChecked;

  QueueStatus({
    required this.totalQueued,
    required this.pending,
    required this.failed,
    required this.successful,
    required this.lastChecked,
  });
}

