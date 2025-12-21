import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/sync_service.dart';
import '../../data/local/queue_repository.dart';
import '../../data/models/queued_request.dart';
import 'package:apclassstone/api/network/offline_api_wrapper.dart';

part 'queue_event.dart';
part 'queue_state.dart';

/// BLoC for managing request queue (Super Admin only)
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository _queueRepository;
  final SyncService? _syncService;
  final OfflineApiWrapper _offlineApiWrapper;

  QueueBloc({
    required QueueRepository queueRepository,
    SyncService? syncService,
    required OfflineApiWrapper offlineApiWrapper,
  })  : _queueRepository = queueRepository,
        _syncService = syncService,
        _offlineApiWrapper = offlineApiWrapper,
        super(const QueueInitial()) {
    on<FetchQueueStatusEvent>(_onFetchQueueStatus);
    on<FetchAllQueuedRequestsEvent>(_onFetchAllQueuedRequests);
    on<RetryFailedRequestEvent>(_onRetryFailedRequest);
    on<RemoveQueuedRequestEvent>(_onRemoveQueuedRequest);
    on<ClearQueueEvent>(_onClearQueue);
    on<ManualSyncEvent>(_onManualSync);
    on<ListenToSyncEvent>(_onListenToSync);
  }

  /// Fetch current queue status
  Future<void> _onFetchQueueStatus(
    FetchQueueStatusEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      final stats = await _queueRepository.getQueueStatistics();
      final status = await _offlineApiWrapper.getQueueStatus();

      emit(QueueStatusLoaded(
        totalQueued: status.totalQueued,
        pending: status.pending,
        failed: status.failed,
        successful: status.successful,
        lastChecked: status.lastChecked,
      ));
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Fetch all queued requests
  Future<void> _onFetchAllQueuedRequests(
    FetchAllQueuedRequestsEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      final requests = await _queueRepository.getAllQueuedRequests();
      emit(QueuedRequestsLoaded(requests: requests));
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Retry a failed request
  Future<void> _onRetryFailedRequest(
    RetryFailedRequestEvent event,
    Emitter<QueueState> emit,
  ) async {
    try {
      final request = await _queueRepository.getRequestById(event.requestId);
      if (request != null) {
        await _queueRepository.updateRequestStatus(
          event.requestId,
          QueueRequestStatus.pending,
        );
        emit(QueueActionSuccess(message: 'Request marked for retry'));

        // Trigger manual sync
        if (_syncService != null) {
          add(ManualSyncEvent());
        }
      }
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Remove a queued request
  Future<void> _onRemoveQueuedRequest(
    RemoveQueuedRequestEvent event,
    Emitter<QueueState> emit,
  ) async {
    try {
      await _queueRepository.deleteFromQueue(event.requestId);
      emit(QueueActionSuccess(message: 'Request removed from queue'));
      add(FetchQueueStatusEvent());
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Clear entire queue
  Future<void> _onClearQueue(
    ClearQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    try {
      await _queueRepository.clearAllQueue();
      emit(QueueActionSuccess(message: 'Queue cleared'));
      add(FetchQueueStatusEvent());
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Manual sync
  Future<void> _onManualSync(
    ManualSyncEvent event,
    Emitter<QueueState> emit,
  ) async {
    try {
      if (_syncService != null) {
        emit(const QueueSyncing());
        await _syncService!.startSync();
        add(FetchQueueStatusEvent());
      }
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  /// Listen to sync events
  Future<void> _onListenToSync(
    ListenToSyncEvent event,
    Emitter<QueueState> emit,
  ) async {
    if (_syncService != null) {
      await emit.forEach<SyncEvent>(
        _syncService!.syncEventStream,
        onData: (syncEvent) {
          if (syncEvent.type == SyncEventType.completed) {
            return QueueSyncCompleted();
          } else if (syncEvent.type == SyncEventType.error) {
            return QueueError(message: syncEvent.message ?? 'Sync error');
          }
          return state;
        },
        onError: (error, stackTrace) =>
            QueueError(message: 'Sync stream error: $error'),
      );
    }
  }
}

