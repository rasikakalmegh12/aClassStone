// ==================== REGISTRATION EVENTS ====================
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
/// Event to register a new user
class GetPendingEvent extends PendingEvent {}

