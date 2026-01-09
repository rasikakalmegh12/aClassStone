import '../../api/models/response/GetWorkPlanDetailsResponseBody.dart';
import '../../api/models/response/GetWorkPlanResponseBody.dart';
import '../../api/models/response/PostWorkPlanResponseBody.dart';

// ========================= Get Work Plan List States =========================
abstract class GetWorkPlanListState {}

class GetWorkPlanListInitial extends GetWorkPlanListState {}

class GetWorkPlanListLoading extends GetWorkPlanListState {
  final bool showLoader;

  GetWorkPlanListLoading({this.showLoader = false});
}

class GetWorkPlanListSuccess extends GetWorkPlanListState {
  final GetWorkPlanResponseBody response;

  GetWorkPlanListSuccess({required this.response});
}

class GetWorkPlanListError extends GetWorkPlanListState {
  final String message;

  GetWorkPlanListError({required this.message});
}

// ========================= Get Work Plan Details States =========================
abstract class GetWorkPlanDetailsState {}

class GetWorkPlanDetailsInitial extends GetWorkPlanDetailsState {}

class GetWorkPlanDetailsLoading extends GetWorkPlanDetailsState {
  final bool showLoader;

  GetWorkPlanDetailsLoading({this.showLoader = false});
}

class GetWorkPlanDetailsSuccess extends GetWorkPlanDetailsState {
  final GetWorkPlanDetailsResponseBody response;

  GetWorkPlanDetailsSuccess({required this.response});
}

class GetWorkPlanDetailsError extends GetWorkPlanDetailsState {
  final String message;

  GetWorkPlanDetailsError({required this.message});
}

// ========================= Post Work Plan States =========================
abstract class PostWorkPlanState {}

class PostWorkPlanInitial extends PostWorkPlanState {}

class PostWorkPlanLoading extends PostWorkPlanState {
  final bool showLoader;

  PostWorkPlanLoading({this.showLoader = false});
}

class PostWorkPlanSuccess extends PostWorkPlanState {
  final PostWorkPlanResponseBody response;

  PostWorkPlanSuccess({required this.response});
}

class PostWorkPlanError extends PostWorkPlanState {
  final String message;

  PostWorkPlanError({required this.message});
}

