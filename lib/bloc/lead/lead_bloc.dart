import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'lead_event.dart';
import 'lead_state.dart';

// ========== POST NEW LEAD BLOC ==========

class PostNewLeadBloc extends Bloc<LeadEvent, LeadState> {
  PostNewLeadBloc() : super(LeadInitial()) {
    on<SubmitNewLead>(_onSubmitNewLead);
  }

  Future<void> _onSubmitNewLead(
    SubmitNewLead event,
    Emitter<LeadState> emit,
  ) async {
    emit(PostNewLeadLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.postNewLead(
      requestBody: event.requestBody,
    );

    if (response.status == true) {
      emit(PostNewLeadSuccess(response));
    } else {
      emit(PostNewLeadError(response.message ?? 'Failed to create lead'));
    }
  }
}

// ========== GET LEAD LIST BLOC ==========

class GetLeadListBloc extends Bloc<LeadEvent, LeadState> {
  GetLeadListBloc() : super(LeadInitial()) {
    on<FetchLeadList>(_onFetchLeadList);
  }

  Future<void> _onFetchLeadList(
    FetchLeadList event,
    Emitter<LeadState> emit,
  ) async {
    emit(GetLeadListLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.getLeadList(
      page: event.page,
      pageSize: event.pageSize,
      search: event.search,
      view: event.view,
    );

    if (response.status == true) {
      emit(GetLeadListLoaded(response));
    } else {
      emit(GetLeadListError(response.message ?? 'Failed to fetch lead list'));
    }
  }
}

// ========== GET LEAD DETAILS BLOC ==========

class GetLeadDetailsBloc extends Bloc<LeadEvent, LeadState> {
  GetLeadDetailsBloc() : super(LeadInitial()) {
    on<FetchLeadDetails>(_onFetchLeadDetails);
  }

  Future<void> _onFetchLeadDetails(
    FetchLeadDetails event,
    Emitter<LeadState> emit,
  ) async {
    emit(GetLeadDetailsLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.getLeadDetails(event.leadId);

    if (response.status == true) {
      emit(GetLeadDetailsLoaded(response));
    } else {
      emit(GetLeadDetailsError(response.message ?? 'Failed to fetch lead details'));
    }
  }
}


// ========== GET ASSIGNABLE USERS BLOC ==========

class GetAssignableUsersBloc extends Bloc<LeadEvent, LeadState> {
  GetAssignableUsersBloc() : super(LeadInitial()) {
    on<FetchAssignableUsers>(_onFetchAssignableUsers);
  }

  Future<void> _onFetchAssignableUsers(
    FetchAssignableUsers event,
    Emitter<LeadState> emit,
  ) async {
    emit(GetAssignableUsersLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.getAssignableUsers();

    if (response.status == true) {
      emit(GetAssignableUsersLoaded(response));
    } else {
      emit(GetAssignableUsersError(response.message ?? 'Failed to fetch assignable users'));
    }
  }
}
