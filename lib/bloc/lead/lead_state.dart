import 'package:apclassstone/api/models/response/NewLeadResponseBody.dart';
import 'package:apclassstone/api/models/response/GetLeadListResponseBody.dart';
import 'package:apclassstone/api/models/response/GetLeadDetailsResponseBody.dart';
import 'package:apclassstone/api/models/response/LeadAssignResponseBody.dart';

abstract class LeadState {}

// Initial State
class LeadInitial extends LeadState {}

// ========== POST NEW LEAD STATES ==========

class PostNewLeadLoading extends LeadState {
  final bool showLoader;
  PostNewLeadLoading({this.showLoader = true});
}

class PostNewLeadSuccess extends LeadState {
  final NewLeadResponseBody response;
  PostNewLeadSuccess(this.response);
}

class PostNewLeadError extends LeadState {
  final String message;
  PostNewLeadError(this.message);
}

// ========== GET LEAD LIST STATES ==========

class GetLeadListLoading extends LeadState {
  final bool showLoader;
  GetLeadListLoading({this.showLoader = true});
}

class GetLeadListLoaded extends LeadState {
  final GetLeadListResponseBody response;
  GetLeadListLoaded(this.response);
}

class GetLeadListError extends LeadState {
  final String message;
  GetLeadListError(this.message);
}

// ========== GET LEAD DETAILS STATES ==========

class GetLeadDetailsLoading extends LeadState {
  final bool showLoader;
  GetLeadDetailsLoading({this.showLoader = true});
}

class GetLeadDetailsLoaded extends LeadState {
  final GetLeadDetailsResponseBody response;
  GetLeadDetailsLoaded(this.response);
}

class GetLeadDetailsError extends LeadState {
  final String message;
  GetLeadDetailsError(this.message);
}

// ========== LEAD ASSIGN STATES ==========

class LeadAssignLoading extends LeadState {
  final bool showLoader;
  LeadAssignLoading({this.showLoader = true});
}

class LeadAssignSuccess extends LeadState {
  final LeadAssignResponseBody response;
  LeadAssignSuccess(this.response);
}

class LeadAssignError extends LeadState {
  final String message;
  LeadAssignError(this.message);
}

// ========== GET ASSIGNABLE USERS STATES ==========

class GetAssignableUsersLoading extends LeadState {
  final bool showLoader;
  GetAssignableUsersLoading({this.showLoader = true});
}

class GetAssignableUsersLoaded extends LeadState {
  final LeadAssignResponseBody response;
  GetAssignableUsersLoaded(this.response);
}

class GetAssignableUsersError extends LeadState {
  final String message;
  GetAssignableUsersError(this.message);
}

