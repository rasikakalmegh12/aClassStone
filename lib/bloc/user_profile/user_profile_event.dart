// User Profile Events
import 'package:apclassstone/api/models/request/GetProfileRequestBody.dart';
import 'package:apclassstone/api/models/response/GetProfileResponseBody.dart';

abstract class UserProfileEvent {}

class LoadUserProfileEvent extends UserProfileEvent {}

class UpdateUserProfileEvent extends UserProfileEvent {
  final GetProfileRequestBody requestBody;


  UpdateUserProfileEvent({
    required this.requestBody,

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
