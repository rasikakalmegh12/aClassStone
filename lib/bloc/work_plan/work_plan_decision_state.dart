import 'package:apclassstone/api/models/response/GetWorkPlanDetailsResponseBody.dart';

abstract class WorkPlanDecisionState {}

class WorkPlanDecisionInitial extends WorkPlanDecisionState {}

class WorkPlanDecisionLoading extends WorkPlanDecisionState {
  final bool showLoader;
  WorkPlanDecisionLoading({this.showLoader = true});
}

class WorkPlanDecisionSuccess extends WorkPlanDecisionState {
  final GetWorkPlanDetailsResponseBody response;
  WorkPlanDecisionSuccess(this.response);
}

class WorkPlanDecisionError extends WorkPlanDecisionState {
  final String message;
  WorkPlanDecisionError(this.message);
}

