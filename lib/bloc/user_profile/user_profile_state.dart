import 'package:apclassstone/api/models/response/GetProfileResponseBody.dart';

import '../../api/models/api_models.dart';

// User Profile States
abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final GetProfileResponseBody user;

  UserProfileLoaded({required this.user});
}

class UserProfileUpdated extends UserProfileState {

  final GetProfileResponseBody user;

  UserProfileUpdated({

    required this.user,
  });
}

class PasswordChanged extends UserProfileState {
  final String message;

  PasswordChanged({required this.message});
}

class UserProfileError extends UserProfileState {
  final String error;

  UserProfileError(this.error);
}
