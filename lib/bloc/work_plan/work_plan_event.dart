import '../../api/models/request/PostWorkPlanRequestBody.dart';

// ========================= Get Work Plan List Events =========================
abstract class GetWorkPlanListEvent {}

class FetchWorkPlanList extends GetWorkPlanListEvent {
  final bool showLoader;
  final String? search;
  final bool? isConvertedToLead;

  FetchWorkPlanList({
    this.showLoader = false,
    this.search,
    this.isConvertedToLead,
  });
}

// ========================= Get Work Plan Details Events =========================
abstract class GetWorkPlanDetailsEvent {}

class FetchWorkPlanDetails extends GetWorkPlanDetailsEvent {
  final String workPlanId;
  final bool showLoader;

  FetchWorkPlanDetails({
    required this.workPlanId,
    this.showLoader = false,
  });
}

// ========================= Post Work Plan Events =========================
abstract class PostWorkPlanEvent {}

class SubmitWorkPlan extends PostWorkPlanEvent {
  final PostWorkPlanRequestBody requestBody;
  final bool showLoader;

  SubmitWorkPlan({
    required this.requestBody,
    this.showLoader = false,
  });
}

