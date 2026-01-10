import 'package:apclassstone/api/models/request/WorkPlanDecisionRequestBody.dart';

abstract class WorkPlanDecisionEvent {}

class SubmitWorkPlanDecision extends WorkPlanDecisionEvent {
  final String workPlanId;
  final WorkPlanDecisionRequestBody requestBody;
  final bool showLoader;

  SubmitWorkPlanDecision({
    required this.workPlanId,
    required this.requestBody,
    this.showLoader = true,
  });
}

