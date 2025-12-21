part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class FetchQueueStatusEvent extends QueueEvent {
  const FetchQueueStatusEvent();
}

class FetchAllQueuedRequestsEvent extends QueueEvent {
  const FetchAllQueuedRequestsEvent();
}

class RetryFailedRequestEvent extends QueueEvent {
  final String requestId;

  const RetryFailedRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RemoveQueuedRequestEvent extends QueueEvent {
  final String requestId;

  const RemoveQueuedRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class ClearQueueEvent extends QueueEvent {
  const ClearQueueEvent();
}

class ManualSyncEvent extends QueueEvent {
  const ManualSyncEvent();
}

class ListenToSyncEvent extends QueueEvent {
  const ListenToSyncEvent();
}

