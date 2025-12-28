// Auth Events
abstract class LoginEvent {}

class FetchLogin extends LoginEvent {
  final String username;
  final String password;

  FetchLogin({required this.username, required this.password});
}

/// ✅ ADD THIS
class ForceLogoutRequested extends LoginEvent {}




abstract class LogoutEvent {}
class FetchLogout extends LogoutEvent {
  final String  refreshToken;

  FetchLogout({required this.refreshToken});
}