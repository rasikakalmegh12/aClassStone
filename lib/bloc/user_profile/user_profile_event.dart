// User Profile Events
abstract class UserProfileEvent {}

class LoadUserProfileEvent extends UserProfileEvent {}

class UpdateUserProfileEvent extends UserProfileEvent {
  final String firstName;
  final String lastName;
  final String email;

  UpdateUserProfileEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}

class ChangePasswordEvent extends UserProfileEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}
