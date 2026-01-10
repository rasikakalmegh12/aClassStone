import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'work_plan_decision_event.dart';
import 'work_plan_decision_state.dart';

class WorkPlanDecisionBloc extends Bloc<WorkPlanDecisionEvent, WorkPlanDecisionState> {
  WorkPlanDecisionBloc() : super(WorkPlanDecisionInitial()) {
    on<SubmitWorkPlanDecision>(_onSubmitWorkPlanDecision);
  }

  Future<void> _onSubmitWorkPlanDecision(
    SubmitWorkPlanDecision event,
    Emitter<WorkPlanDecisionState> emit,
  ) async {
    emit(WorkPlanDecisionLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.workPlanDecision(
      event.workPlanId,
      event.requestBody,
    );

    if (response.status == true) {
      emit(WorkPlanDecisionSuccess(response));
    } else {
      emit(WorkPlanDecisionError(response.message ?? 'Failed to submit work plan decision'));
    }
  }
}

