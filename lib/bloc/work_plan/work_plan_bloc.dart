import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/integration/api_integration.dart';
import 'work_plan_event.dart';
import 'work_plan_state.dart';

// ========================= Get Work Plan List BLoC =========================
class GetWorkPlanListBloc extends Bloc<GetWorkPlanListEvent, GetWorkPlanListState> {
  GetWorkPlanListBloc() : super(GetWorkPlanListInitial()) {
    on<FetchWorkPlanList>(
      (FetchWorkPlanList event, Emitter<GetWorkPlanListState> emit) async {
        emit(GetWorkPlanListLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.getWorkPlanList(
            search: event.search,
            isConvertedToLead: event.isConvertedToLead,
          );

          if (response.status == true) {
            emit(GetWorkPlanListSuccess(response: response));
          } else {
            emit(
              GetWorkPlanListError(
                message: response.message ?? 'Failed to fetch Work Plan list',
              ),
            );
          }
        } catch (e) {
          emit(
            GetWorkPlanListError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}

// ========================= Get Work Plan Details BLoC =========================
class GetWorkPlanDetailsBloc
    extends Bloc<GetWorkPlanDetailsEvent, GetWorkPlanDetailsState> {
  GetWorkPlanDetailsBloc() : super(GetWorkPlanDetailsInitial()) {
    on<FetchWorkPlanDetails>(
      (FetchWorkPlanDetails event, Emitter<GetWorkPlanDetailsState> emit) async {
        emit(GetWorkPlanDetailsLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.getWorkPlanIdDetails(event.workPlanId);

          if (response.status == true) {
            emit(GetWorkPlanDetailsSuccess(response: response));
          } else {
            emit(
              GetWorkPlanDetailsError(
                message: response.message ?? 'Failed to fetch Work Plan details',
              ),
            );
          }
        } catch (e) {
          emit(
            GetWorkPlanDetailsError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}

// ========================= Post Work Plan BLoC =========================
class PostWorkPlanBloc extends Bloc<PostWorkPlanEvent, PostWorkPlanState> {
  PostWorkPlanBloc() : super(PostWorkPlanInitial()) {
    on<SubmitWorkPlan>(
      (SubmitWorkPlan event, Emitter<PostWorkPlanState> emit) async {
        emit(PostWorkPlanLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.postWorkPlan(
            event.requestBody,
          );

          if (response.status == true) {
            emit(PostWorkPlanSuccess(response: response));
          } else {
            emit(
              PostWorkPlanError(
                message: response.message ?? 'Failed to submit Work Plan',
              ),
            );
          }
        } catch (e) {
          emit(
            PostWorkPlanError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}

