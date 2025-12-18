// ==================== REGISTRATION EVENTS ====================
import 'package:apclassstone/api/models/request/ApproveRequestBody.dart';

abstract class RegistrationEvent {}

/// Event to register a new user
class RegisterUserEvent extends RegistrationEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String appCode;

  RegisterUserEvent({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.appCode,
  });
}

/// Event to clear registration state (useful after navigation)
class ResetRegistrationEvent extends RegistrationEvent {}


abstract class PendingEvent {}
class GetPendingEvent extends PendingEvent {}



abstract class ApproveRegistrationEvent {}
class FetchApproveRegistration extends ApproveRegistrationEvent {
  final ApproveRequestBody body;
  final String id;
  FetchApproveRegistration({required this.body,required this.id});
}


abstract class RejectRegistrationEvent {}
class FetchRejectRegistration extends RejectRegistrationEvent {
  final String id;
  FetchRejectRegistration({required this.id});
}