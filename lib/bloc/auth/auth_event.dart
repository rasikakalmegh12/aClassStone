// Auth Events
abstract class LoginEvent {}

class FetchLogin extends LoginEvent {
  final String username;
  final String password;

  FetchLogin({required this.username, required this.password});
}

