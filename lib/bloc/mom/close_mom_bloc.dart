import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'close_mom_event.dart';
import 'close_mom_state.dart';

class CloseMomBloc extends Bloc<CloseMomEvent, CloseMomState> {
  CloseMomBloc() : super(CloseMomInitial()) {
    on<FetchCloseMom>((event, emit) async {
      emit(CloseMomLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.closeMOM(
          id: event.momId,
          message: event.remarks ?? '',
        );

        if (response.status == true) {
          emit(CloseMomSuccess(message: response.message ?? 'MOM closed successfully'));
        } else {
          emit(CloseMomError(message: response.message ?? 'Failed to close MOM'));
        }
      } catch (error) {
        emit(CloseMomError(message: 'Error: ${error.toString()}'));
      }
    });
  }
}

