import 'dart:async';
import 'package:dio/dio.dart';
import '../../data/local/queue_repository.dart';
import '../../data/models/queued_request.dart';
import '../../api/network/network_service.dart';
import 'connectivity_service.dart';
import 'package:apclassstone/api/constants/api_constants.dart';


typedef OnSyncCallback = Future<bool> Function(QueuedRequest request);

/// Service to manage syncing of queued requests when connectivity resumes
class SyncService {
  static SyncService? _instance;

  final QueueRepository _queueRepository;
  final ConnectivityService _connectivityService;
  final NetworkService _networkService;

  late StreamSubscription<ConnectivityStatus> _connectivitySubscription;
  final StreamController<SyncEvent> _syncEventController = StreamController<SyncEvent>.broadcast();

  Timer? _autoSyncTimer;
  bool _isSyncing = false;
  Map<String, OnSyncCallback> _customSyncHandlers = {};

  SyncService._internal(
    this._queueRepository,
    this._connectivityService,
    this._networkService,
  );

  static SyncService? _createInstance(QueueRepository repo, ConnectivityService conn, NetworkService net) {
    _instance ??= SyncService._internal(repo, conn, net);
    return _instance!;
  }

  static SyncService get instance {
    if (_instance == null) {
      throw Exception('SyncService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize sync service
  static Future<SyncService> initialize({
    required QueueRepository queueRepository,
    required ConnectivityService connectivityService,
    required NetworkService networkService,
  }) async {
    _createInstance(queueRepository, connectivityService, networkService);
    await _instance!._setupListeners();
    return _instance!;
  }

  /// Setup connectivity listeners
  Future<void> _setupListeners() async {
    _connectivitySubscription = _connectivityService.statusStream.listen(
      (status) async {
        if (status == ConnectivityStatus.online) {
          print('[SyncService] Connectivity restored, starting sync...');
          await startSync();
        }
      },
    );

    // Start periodic sync every 5 minutes as fallback
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        if (_connectivityService.isOnline && !_isSyncing) {
          await startSync();
        }
      },
    );
  }

  /// Register custom sync handler for specific endpoint
  void registerCustomHandler(String endpoint, OnSyncCallback handler) {
    _customSyncHandlers[endpoint] = handler;
  }

  /// Start syncing queued requests
  Future<void> startSync() async {
    if (_isSyncing) return;
    if (!_connectivityService.isOnline) return;

    _isSyncing = true;
    _syncEventController.add(SyncEvent(type: SyncEventType.started));

    try {
      final pendingRequests = await _queueRepository.getPendingRequests();

      if (pendingRequests.isEmpty) {
        _syncEventController.add(SyncEvent(type: SyncEventType.completed));
        _isSyncing = false;
        return;
      }

      print('[SyncService] Starting sync for ${pendingRequests.length} requests');

      for (final request in pendingRequests) {
        // Skip login requests - they should not be queued
        if (request.endpoint.contains('login')) {
          await _queueRepository.updateRequestStatus(request.id, QueueRequestStatus.failed);
          _syncEventController.add(
            SyncEvent(
              type: SyncEventType.failed,
              requestId: request.id,
              message: 'Login requests cannot be queued',
            ),
          );
          continue;
        }

        await _syncRequest(request);
      }

      _syncEventController.add(SyncEvent(type: SyncEventType.completed));
    } catch (e) {
      print('[SyncService] Sync error: $e');
      _syncEventController.add(
        SyncEvent(
          type: SyncEventType.error,
          message: e.toString(),
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync individual request
  Future<void> _syncRequest(QueuedRequest request) async {
    try {
      // Check if there's a custom handler for this endpoint
      if (_customSyncHandlers.containsKey(request.endpoint)) {
        final handler = _customSyncHandlers[request.endpoint]!;
        final success = await handler(request);

        if (success) {
          await _queueRepository.updateRequestStatus(request.id, QueueRequestStatus.success);
          _syncEventController.add(
            SyncEvent(
              type: SyncEventType.success,
              requestId: request.id,
              message: 'Request synced successfully',
            ),
          );
        } else {
          await _handleSyncFailure(request);
        }
        return;
      }

      // Default sync using the network service
      await _syncRequestDefault(request);
    } catch (e) {
      print('[SyncService] Error syncing request ${request.id}: $e');
      await _handleSyncFailure(request, error: e.toString());
    }
  }

  /// Default sync implementation using Dio
  Future<void> _syncRequestDefault(QueuedRequest request) async {
    try {
      await _queueRepository.updateRequestStatus(request.id, QueueRequestStatus.inProgress);

      final dio = _networkService.dio;
      final method = request.method.toUpperCase();
      final fullUrl = request.endpoint.startsWith('http')
          ? request.endpoint
          : '${ApiConstants.baseUrl}${request.endpoint}';

      Response response;

      switch (method) {
        case 'GET':
          response = await dio.get(fullUrl);
          break;
        case 'POST':
          response = await dio.post(
            fullUrl,
            data: request.requestBody,
            options: Options(headers: request.headers),
          );
          break;
        case 'PUT':
          response = await dio.put(
            fullUrl,
            data: request.requestBody,
            options: Options(headers: request.headers),
          );
          break;
        case 'DELETE':
          response = await dio.delete(fullUrl);
          break;
        case 'PATCH':
          response = await dio.patch(
            fullUrl,
            data: request.requestBody,
            options: Options(headers: request.headers),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw Exception('Request failed with status: ${response.statusCode}');
      }

      await _queueRepository.updateRequestStatus(request.id, QueueRequestStatus.success);
      _syncEventController.add(
        SyncEvent(
          type: SyncEventType.success,
          requestId: request.id,
          message: 'Request synced successfully',
        ),
      );
    } catch (e) {
      await _handleSyncFailure(request, error: e.toString());
    }
  }

  /// Handle sync failure with retry logic
  Future<void> _handleSyncFailure(QueuedRequest request, {String? error}) async {
    if (request.canRetry()) {
      await _queueRepository.updateRequestRetry(
        request.id,
        QueueRequestStatus.retrying,
        error,
      );
      _syncEventController.add(
        SyncEvent(
          type: SyncEventType.retrying,
          requestId: request.id,
          message: 'Retrying request (${request.retryCount + 1}/${request.maxRetries})',
        ),
      );
    } else {
      await _queueRepository.updateRequestStatus(request.id, QueueRequestStatus.failed);
      _syncEventController.add(
        SyncEvent(
          type: SyncEventType.failed,
          requestId: request.id,
          message: error ?? 'Max retries exceeded',
        ),
      );
    }
  }

  /// Get sync event stream
  Stream<SyncEvent> get syncEventStream => _syncEventController.stream;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
    _autoSyncTimer?.cancel();
    _syncEventController.close();
  }
}

enum SyncEventType { started, inProgress, success, failed, retrying, completed, error }

class SyncEvent {
  final SyncEventType type;
  final String? requestId;
  final String? message;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    this.requestId,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

