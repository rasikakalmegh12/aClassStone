

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



// ========================= Post MOM Entry BLoC =========================
class PostMomEntryBloc
    extends Bloc<PostMomEntryEvent, PostMomEntryState> {

  PostMomEntryBloc() : super(PostMomEntryInitial()) {
    on<SubmitMomEntry>(
          (SubmitMomEntry event, Emitter<PostMomEntryState> emit) async {

        emit(PostMomEntryLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.postMomEntry(
            requestBody: event.requestBody,
          );

          if (response.status == true) {
            emit(PostMomEntrySuccess(response: response));
          } else {
            emit(
              PostMomEntryError(
                message: response.message ?? 'Failed to submit MOM entry',
              ),
            );
          }
        } catch (e) {
          emit(
            PostMomEntryError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}

// ========================= Get MOM List BLoC =========================
class GetMomListBloc extends Bloc<GetMomListEvent, GetMomListState> {
  GetMomListBloc() : super(GetMomListInitial()) {
    on<FetchMomList>(
          (FetchMomList event, Emitter<GetMomListState> emit) async {
        emit(GetMomListLoading(showLoader: event.showLoader));

        try {
          final response = await ApiIntegration.getMomList(
            search: event.search,
            isConvertedToLead: event.isConvertedToLead,
          );

          if (response.status == true) {
            emit(GetMomListSuccess(response: response));
          } else {
            emit(
              GetMomListError(
                message: response.message ?? 'Failed to fetch MOM list',
              ),
            );
          }
        } catch (e) {
          emit(
            GetMomListError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}



// ========================= Get MOM Details BLoC =========================
class GetMomDetailsBloc
    extends Bloc<GetMomDetailsEvent, GetMomDetailsState> {
  GetMomDetailsBloc() : super(GetMomDetailsInitial()) {
    on<FetchMomDetails>(
          (FetchMomDetails event, Emitter<GetMomDetailsState> emit) async {
        emit(GetMomDetailsLoading(showLoader: event.showLoader));

        try {
          final response =
          await ApiIntegration.getMomIdDetails(event.momId);

          if (response.status == true) {
            emit(GetMomDetailsSuccess(response: response));
          } else {
            emit(
              GetMomDetailsError(
                message:
                response.message ?? 'Failed to fetch MOM details',
              ),
            );
          }
        } catch (e) {
          emit(
            GetMomDetailsError(
              message: 'Error: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}
