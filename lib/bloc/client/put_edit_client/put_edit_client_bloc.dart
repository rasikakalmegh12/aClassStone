import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../api/integration/api_integration.dart';
import 'put_edit_client_event.dart';
import 'put_edit_client_state.dart';

// ========================= Put Edit Client BLoC =========================
class PutEditClientBloc extends Bloc<PutEditClientEvent, PutEditClientState> {
  PutEditClientBloc() : super(PutEditClientInitial()) {
    on<FetchPutEditClient>((event, emit) async {
      emit(PutEditClientLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.putEditClient(
          clientId: event.clientId,
          requestBody: event.requestBody,
        );

        if (response.status == true) {
          emit(PutEditClientSuccess(response: response));
        } else {
          emit(PutEditClientError(message: response.message ?? 'Failed to update client'));
        }
      } catch (e) {
        emit(PutEditClientError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

