import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';
import 'put_catalogue_image_operations_event.dart';
import 'put_catalogue_image_operations_state.dart';

// ========================= Put Catalogue Image Operations BLoC =========================
class PutCatalogueImageOperationsBloc extends Bloc<PutCatalogueImageOperationsEvent, PutCatalogueImageOperationsState> {
  PutCatalogueImageOperationsBloc() : super(PutCatalogueImageOperationsInitial()) {
    on<DeleteProductImage>((DeleteProductImage event, Emitter<PutCatalogueImageOperationsState> emit) async {
      emit(PutCatalogueImageOperationsLoading(
        showLoader: event.showLoader,
        operationType: 'delete',
      ));

      try {
        final response = await ApiIntegration.deleteProductImage(
          event.productId,
          event.imageId,
        );

        if (response.status == true) {
          emit(DeleteImageSuccess(
            response: response,
            imageId: event.imageId,
          ));
        } else {
          emit(PutCatalogueImageOperationsError(
            message: response.message ?? 'Failed to delete image',
            operationType: 'delete',
          ));
        }
      } catch (e) {
        emit(PutCatalogueImageOperationsError(
          message: 'Error: ${e.toString()}',
          operationType: 'delete',
        ));
      }
    });

    on<SetImagePrimary>((SetImagePrimary event, Emitter<PutCatalogueImageOperationsState> emit) async {
      emit(PutCatalogueImageOperationsLoading(
        showLoader: event.showLoader,
        operationType: 'setPrimary',
      ));

      try {
        final response = await ApiIntegration.setImagePrimary(
          productId: event.productId,
          imageId: event.imageId,
        );

        if (response.status == true) {
          emit(SetImagePrimarySuccess(
            response: response,
            imageId: event.imageId,
          ));
        } else {
          emit(PutCatalogueImageOperationsError(
            message: response.message ?? 'Failed to set image as primary',
            operationType: 'setPrimary',
          ));
        }
      } catch (e) {
        emit(PutCatalogueImageOperationsError(
          message: 'Error: ${e.toString()}',
          operationType: 'setPrimary',
        ));
      }
    });
  }
}

