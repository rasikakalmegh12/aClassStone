import 'package:apclassstone/api/models/response/GetClientIdDetailsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetClientListResponseBody.dart';

// ========================= Client List States =========================

abstract class GetClientListState {}
class GetClientListInitial extends GetClientListState {}
class GetClientListLoading extends GetClientListState {
  final bool showLoader;
  GetClientListLoading({this.showLoader = false});
}
class GetClientListLoaded extends GetClientListState {
  final GetClientListResponseBody response;
  GetClientListLoaded({required this.response});
}
class GetClientListError extends GetClientListState {
  final String message;
  GetClientListError({required this.message});
}


// ========================= Client List States =========================

abstract class GetClientDetailsState {}
class GetClientDetailsInitial extends GetClientDetailsState {}
class GetClientDetailsLoading extends GetClientDetailsState {
  final bool showLoader;
  GetClientDetailsLoading({this.showLoader = false});
}
class GetClientDetailsLoaded extends GetClientDetailsState {
  final GetClientIdDetailsResponseBody response;
  GetClientDetailsLoaded({required this.response});
}
class GetClientDetailsError extends GetClientDetailsState {
  final String message;
  GetClientDetailsError({required this.message});
}
