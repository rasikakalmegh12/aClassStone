import 'package:apclassstone/api/models/response/RoleChangeResponsebody.dart';
import 'package:apclassstone/api/models/response/StatusChangeResponsebody.dart';
import 'package:apclassstone/api/models/response/UserProfileDetailsResponsebody.dart';

abstract class UserManagementState {}

// Initial State
class UserManagementInitial extends UserManagementState {}

// ========== User Profile Details States ==========
class UserProfileDetailsLoading extends UserManagementState {
  final bool showLoader;
  UserProfileDetailsLoading({this.showLoader = true});
}

class UserProfileDetailsLoaded extends UserManagementState {
  final UserProfileDetailsResponseBody response;
  UserProfileDetailsLoaded(this.response);
}

class UserProfileDetailsError extends UserManagementState {
  final String message;
  UserProfileDetailsError(this.message);
}

// ========== Change Role States ==========
class ChangeRoleLoading extends UserManagementState {
  final bool showLoader;
  ChangeRoleLoading({this.showLoader = true});
}

class ChangeRoleSuccess extends UserManagementState {
  final RoleChangeResponseBody response;
  ChangeRoleSuccess(this.response);
}

class ChangeRoleError extends UserManagementState {
  final String message;
  ChangeRoleError(this.message);
}

// ========== Change Status States ==========
class ChangeStatusLoading extends UserManagementState {
  final bool showLoader;
  ChangeStatusLoading({this.showLoader = true});
}

class ChangeStatusSuccess extends UserManagementState {
  final StatusChangeResponseBody response;
  ChangeStatusSuccess(this.response);
}

class ChangeStatusError extends UserManagementState {
  final String message;
  ChangeStatusError(this.message);
}

