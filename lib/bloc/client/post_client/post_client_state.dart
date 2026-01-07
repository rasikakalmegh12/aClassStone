

// ========================= Client List States =========================

import 'package:apclassstone/api/models/response/PostMomEntryResponseBody.dart';

import '../../../api/models/response/PostClientAddContactResponseBody.dart';
import '../../../api/models/response/PostClientAddLocationResponseBody.dart';
import '../../../api/models/response/PostClientAddResponseBody.dart';

abstract class PostClientAddState {}
class PostClientAddInitial extends PostClientAddState {}
class PostClientAddLoading extends PostClientAddState {
  final bool showLoader;
  PostClientAddLoading({this.showLoader = false});
}
class PostClientAddLoaded extends PostClientAddState {
  final PostClientAddResponseBody response;
  PostClientAddLoaded({required this.response});
}
class PostClientAddError extends PostClientAddState {
  final String message;
  PostClientAddError({required this.message});
}

abstract class PostClientAddLocationState {}
class PostClientAddLocationInitial extends PostClientAddLocationState {}
class PostClientAddLocationLoading extends PostClientAddLocationState {
  final bool showLoader;
  PostClientAddLocationLoading({this.showLoader = false});
}
class PostClientAddLocationLoaded extends PostClientAddLocationState {
  final PostClientAddLocationResponseBody response;
  PostClientAddLocationLoaded({required this.response});
}
class PostClientAddLocationError extends PostClientAddLocationState {
  final String message;
  PostClientAddLocationError({required this.message});
}

abstract class PostClientAddContactState {}
class PostClientAddContactInitial extends PostClientAddContactState {}
class PostClientAddContactLoading extends PostClientAddContactState {
  final bool showLoader;
  PostClientAddContactLoading({this.showLoader = false});
}
class PostClientAddContactLoaded extends PostClientAddContactState {
  final PostClientAddContactResponseBody response;
  PostClientAddContactLoaded({required this.response});
}
class PostClientAddContactError extends PostClientAddContactState {
  final String message;
  PostClientAddContactError({required this.message});
}
