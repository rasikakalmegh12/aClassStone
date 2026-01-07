

// ========================= Mom Image Upload BLoC =========================
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/integration/api_integration.dart';
import 'mom_event.dart';
import 'mom_state.dart';

class MomImageUploadBloc
    extends Bloc<MomImageUploadEvent, MomImageUploadState> {
  MomImageUploadBloc() : super(MomImageUploadInitial()) {
    on<UploadMomImage>(
          (UploadMomImage event, Emitter<MomImageUploadState> emit) async {
        emit(MomImageUploadLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.postMomImageUpload(
            momId: event.momId,
            imageFile: event.imageFile,
            caption: event.caption,
            sortOrder: event.sortOrder,
          );

          if (response.status == true) {
            emit(MomImageUploadSuccess(response: response));
          } else {
            emit(
              MomImageUploadError(
                message: response.message ?? 'Failed to upload image',
              ),
            );
          }
        } catch (e) {
          emit(
            MomImageUploadError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}
