import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';
import 'put_edit_product_event.dart';
import 'put_edit_product_state.dart';

// ========================= Put Edit Product BLoC =========================
class PutEditProductBloc extends Bloc<PutEditProductEvent, PutEditProductState> {
  PutEditProductBloc() : super(PutEditProductInitial()) {
    on<SubmitPutEditProduct>((SubmitPutEditProduct event, Emitter<PutEditProductState> emit) async {
      emit(PutEditProductLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.putEditProduct(
          productId: event.productId,
          requestBody: event.requestBody,
        );

        if (response.status == true) {
          emit(PutEditProductSuccess(response: response));
        } else {
          emit(PutEditProductError(message: response.message ?? 'Failed to update product'));
        }
      } catch (e) {
        emit(PutEditProductError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

