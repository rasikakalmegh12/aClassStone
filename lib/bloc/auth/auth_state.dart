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

