import 'package:apclassstone/api/models/response/ApproveResponseBody.dart';
import 'package:apclassstone/api/models/response/PendingRegistrationResponseBody.dart';

import '../../api/models/response/RegistrationResponseBody.dart';

// ==================== REGISTRATION STATES ====================
abstract class RegistrationState {}

/// Initial state before any registration attempt
class RegistrationInitial extends RegistrationState {}

/// Loading state while registration API is being called
class RegistrationLoading extends RegistrationState {}

/// Success state when registration completes successfully
class RegistrationSuccess extends RegistrationState {
  final RegistrationResponseBody response;

  RegistrationSuccess({required this.response});
}

/// Error state when registration fails
class RegistrationError extends RegistrationState {
  final String message;

  RegistrationError({required this.message});
}



abstract class PendingState {}

/// Initial state before any registration attempt
class PendingInitial extends PendingState {}

/// Loading state while registration API is being called
class PendingLoading extends PendingState {}

/// Success state when registration completes successfully
class PendingLoaded extends PendingState {
  final PendingRegistrationResponseBody response;

  PendingLoaded({required this.response});
}

/// Error state when registration fails
class PendingError extends PendingState {
  final String message;

  PendingError({required this.message});
}



abstract class ApproveRegistrationState {}
class ApproveRegistrationInitial extends ApproveRegistrationState {}
class ApproveRegistrationLoading extends ApproveRegistrationState {}
class ApproveRegistrationLoaded extends ApproveRegistrationState {
  final ApproveResponseBody response;
  ApproveRegistrationLoaded({required this.response});
}
class ApproveRegistrationError extends ApproveRegistrationState {
  final String message;
  ApproveRegistrationError({required this.message});
}


abstract class RejectRegistrationState {}
class RejectRegistrationInitial extends RejectRegistrationState {}
class RejectRegistrationLoading extends RejectRegistrationState {}
class RejectRegistrationLoaded extends RejectRegistrationState {
  final ApproveResponseBody response;
  RejectRegistrationLoaded({required this.response});
}
class RejectRegistrationError extends RejectRegistrationState {
  final String message;
  RejectRegistrationError({required this.message});
}