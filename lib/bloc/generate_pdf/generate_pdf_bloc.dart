import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apclassstone/api/integration/api_integration.dart';
import 'generate_pdf_event.dart';
import 'generate_pdf_state.dart';

class GeneratePdfBloc extends Bloc<GeneratePdfEvent, GeneratePdfState> {
  GeneratePdfBloc() : super(GeneratePdfInitial()) {
    on<GeneratePdfForProduct>(_onGeneratePdfForProduct);
  }

  Future<void> _onGeneratePdfForProduct(
    GeneratePdfForProduct event,
    Emitter<GeneratePdfState> emit,
  ) async {
    emit(GeneratePdfLoading(showLoader: event.showLoader));

    final response = await ApiIntegration.generatePdf(event.productId);

    if (response.status == true) {
      emit(GeneratePdfSuccess(response));
    } else {
      emit(GeneratePdfError(response.message ?? 'Failed to generate PDF'));
    }
  }
}

