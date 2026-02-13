import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'close_lead_event.dart';
import 'close_lead_state.dart';

class CloseLeadBloc extends Bloc<CloseLeadEvent, CloseLeadState> {
  CloseLeadBloc() : super(CloseLeadInitial()) {
    on<FetchCloseLead>((event, emit) async {
      emit(CloseLeadLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.closeLead(
          event.leadId,
          event.notes ?? '',
        );

        if (response.status == true) {
          emit(CloseLeadSuccess(message: response.message ?? 'Lead closed successfully'));
        } else {
          emit(CloseLeadError(message: response.message ?? 'Failed to close lead'));
        }
      } catch (error) {
        emit(CloseLeadError(message: 'Error: ${error.toString()}'));
      }
    });
  }
}

