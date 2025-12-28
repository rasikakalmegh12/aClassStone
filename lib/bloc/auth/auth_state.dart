import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';
import 'package:apclassstone/api/models/response/LoginResponseBody.dart';

import '../../api/models/api_models.dart';
import '../../api/models/models.dart';

// Auth States
// ==================== LOGIN  ====================
abstract class LoginState {}

/// Initial state before any registration attempt
class LoginInitial extends LoginState {}

/// Loading state while registration API is being called
class LoginLoading extends LoginState {}

/// Success state when registration completes successfully
class LoginSuccess extends LoginState {
  final LoginResponseBody response;

  LoginSuccess({required this.response});
}

/// Error state when registration fails
class LoginError extends LoginState {
  final String message;

  LoginError({required this.message});
}

/// ✅ ADD THIS
class LoginLoggedOut extends LoginState {}




abstract class LogoutState {}
class LogoutInitial extends LogoutState {}
class LogoutLoading extends LogoutState {}
class LogoutLoaded extends LogoutState {
  final ApiCommonResponseBody response;
  LogoutLoaded({required this.response});
}
class LogoutError extends LogoutState {
  final String message;
  LogoutError({required this.message});
}