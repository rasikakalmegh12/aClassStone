abstract class UserManagementEvent {}

// Get User Profile Details
class FetchUserProfileDetails extends UserManagementEvent {
  final String userId;
  final bool showLoader;

  FetchUserProfileDetails({
    required this.userId,
    this.showLoader = true,
  });
}

// Change User Role
class ChangeUserRole extends UserManagementEvent {
  final String userId;
  final String role;
  final bool showLoader;

  ChangeUserRole({
    required this.userId,
    required this.role,
    this.showLoader = true,
  });
}

// Change User Status
class ChangeUserStatus extends UserManagementEvent {
  final String userId;
  final bool isActive;
  final bool showLoader;

  ChangeUserStatus({
    required this.userId,
    required this.isActive,
    this.showLoader = true,
  });
}

