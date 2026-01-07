


// ========================= Client List Bloc =========================
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';
import 'get_client_event.dart';
import 'get_client_state.dart';

class GetClientListBloc extends Bloc<GetClientListEvent, GetClientListState> {
  GetClientListBloc() : super(GetClientListInitial()) {
    on<FetchGetClientList>((event, emit) async {
      emit(GetClientListLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getClientList(event.search, event.clientTypeCode);

        if (response.status == true) {
          emit(GetClientListLoaded(response: response));
        } else {
          emit(GetClientListLoaded(response: response));
        }
      } catch (e) {
        emit(GetClientListError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}



class GetClientDetailsBloc extends Bloc<GetClientDetailsEvent, GetClientDetailsState> {
  GetClientDetailsBloc() : super(GetClientDetailsInitial()) {
    on<FetchGetClientDetails>((event, emit) async {
      emit(GetClientDetailsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getClientDetails(event.clientId);

        if (response.status == true) {
          emit(GetClientDetailsLoaded(response: response));
        } else {
          emit(GetClientDetailsLoaded(response: response));
        }
      } catch (e) {
        emit(GetClientDetailsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}