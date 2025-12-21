part of 'queue_bloc.dart';

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {
  const QueueInitial();
}

class QueueLoading extends QueueState {
  const QueueLoading();
}

class QueueStatusLoaded extends QueueState {
  final int totalQueued;
  final int pending;
  final int failed;
  final int successful;
  final DateTime lastChecked;

  const QueueStatusLoaded({
    required this.totalQueued,
    required this.pending,
    required this.failed,
    required this.successful,
    required this.lastChecked,
  });

  @override
  List<Object?> get props => [totalQueued, pending, failed, successful, lastChecked];
}

class QueuedRequestsLoaded extends QueueState {
  final List<QueuedRequest> requests;

  const QueuedRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class QueueSyncing extends QueueState {
  const QueueSyncing();
}

class QueueSyncCompleted extends QueueState {
  const QueueSyncCompleted();
}

class QueueActionSuccess extends QueueState {
  final String message;

  const QueueActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class QueueError extends QueueState {
  final String message;

  const QueueError({required this.message});

  @override
  List<Object?> get props => [message];
}

