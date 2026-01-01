import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';
import 'post_catalogue_event.dart';
import 'post_catalogue_state.dart';

// ========================= Post Colors BLoC =========================
class PostColorsBloc extends Bloc<PostColorsEvent, PostColorsState> {
  PostColorsBloc() : super(PostColorsInitial()) {
    on<SubmitPostColors>((SubmitPostColors event, Emitter<PostColorsState> emit) async {
      emit(PostColorsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postColors(event.requestBody);

        if (response.status == true) {
          emit(PostColorsSuccess(response: response));
        } else {
          emit(PostColorsError(message: response.message ?? 'Failed to post colors'));
        }
      } catch (e) {
        emit(PostColorsError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}


// ========================= Post Finishes BLoC =========================
class PostFinishesBloc extends Bloc<PostFinishesEvent, PostFinishesState> {
  PostFinishesBloc() : super(PostFinishesInitial()) {
    on<SubmitPostFinishes>((SubmitPostFinishes event, Emitter<PostFinishesState> emit) async {
      emit(PostFinishesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postFinishes(event.requestBody);

        if (response.status == true) {
          emit(PostFinishesSuccess(response: response));
        } else {
          emit(PostFinishesError(message: response.message ?? 'Failed to post finishes'));
        }
      } catch (e) {
        emit(PostFinishesError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Textures BLoC =========================
class PostTexturesBloc extends Bloc<PostTexturesEvent, PostTexturesState> {
  PostTexturesBloc() : super(PostTexturesInitial()) {
    on<SubmitPostTextures>((SubmitPostTextures event, Emitter<PostTexturesState> emit) async {
      emit(PostTexturesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postTextures(event.requestBody);

        if (response.status == true) {
          emit(PostTexturesSuccess(response: response));
        } else {
          emit(PostTexturesError(message: response.message ?? 'Failed to post textures'));
        }
      } catch (e) {
        emit(PostTexturesError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Natural Colors BLoC =========================
class PostNaturalColorsBloc extends Bloc<PostNaturalColorsEvent, PostNaturalColorsState> {
  PostNaturalColorsBloc() : super(PostNaturalColorsInitial()) {
    on<SubmitPostNaturalColors>((SubmitPostNaturalColors event, Emitter<PostNaturalColorsState> emit) async {
      emit(PostNaturalColorsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postNaturalColors(event.requestBody);

        if (response.status == true) {
          emit(PostNaturalColorsSuccess(response: response));
        } else {
          emit(PostNaturalColorsError(message: response.message ?? 'Failed to post natural colors'));
        }
      } catch (e) {
        emit(PostNaturalColorsError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Origins BLoC =========================
class PostOriginsBloc extends Bloc<PostOriginsEvent, PostOriginsState> {
  PostOriginsBloc() : super(PostOriginsInitial()) {
    on<SubmitPostOrigins>((SubmitPostOrigins event, Emitter<PostOriginsState> emit) async {
      emit(PostOriginsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postOrigins(event.requestBody);

        if (response.status == true) {
          emit(PostOriginsSuccess(response: response));
        } else {
          emit(PostOriginsError(message: response.message ?? 'Failed to post origins'));
        }
      } catch (e) {
        emit(PostOriginsError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post State Countries BLoC =========================
class PostStateCountriesBloc extends Bloc<PostStateCountriesEvent, PostStateCountriesState> {
  PostStateCountriesBloc() : super(PostStateCountriesInitial()) {
    on<SubmitPostStateCountries>((SubmitPostStateCountries event, Emitter<PostStateCountriesState> emit) async {
      emit(PostStateCountriesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postStateCountries(event.requestBody);

        if (response.status == true) {
          emit(PostStateCountriesSuccess(response: response));
        } else {
          emit(PostStateCountriesError(message: response.message ?? 'Failed to post state countries'));
        }
      } catch (e) {
        emit(PostStateCountriesError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Processing Natures BLoC =========================
class PostProcessingNaturesBloc extends Bloc<PostProcessingNaturesEvent, PostProcessingNaturesState> {
  PostProcessingNaturesBloc() : super(PostProcessingNaturesInitial()) {
    on<SubmitPostProcessingNatures>((SubmitPostProcessingNatures event, Emitter<PostProcessingNaturesState> emit) async {
      emit(PostProcessingNaturesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postProcessingNatures(event.requestBody);

        if (response.status == true) {
          emit(PostProcessingNaturesSuccess(response: response));
        } else {
          emit(PostProcessingNaturesError(message: response.message ?? 'Failed to post processing natures'));
        }
      } catch (e) {
        emit(PostProcessingNaturesError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Natural Materials BLoC =========================
class PostNaturalMaterialsBloc extends Bloc<PostNaturalMaterialsEvent, PostNaturalMaterialsState> {
  PostNaturalMaterialsBloc() : super(PostNaturalMaterialsInitial()) {
    on<SubmitPostNaturalMaterials>((SubmitPostNaturalMaterials event, Emitter<PostNaturalMaterialsState> emit) async {
      emit(PostNaturalMaterialsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postNaturalMaterials(event.requestBody);

        if (response.status == true) {
          emit(PostNaturalMaterialsSuccess(response: response));
        } else {
          emit(PostNaturalMaterialsError(message: response.message ?? 'Failed to post natural materials'));
        }
      } catch (e) {
        emit(PostNaturalMaterialsError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Post Handicrafts Types BLoC =========================
class PostHandicraftsTypesBloc extends Bloc<PostHandicraftsTypesEvent, PostHandicraftsTypesState> {
  PostHandicraftsTypesBloc() : super(PostHandicraftsTypesInitial()) {
    on<SubmitPostHandicraftsTypes>((SubmitPostHandicraftsTypes event, Emitter<PostHandicraftsTypesState> emit) async {
      emit(PostHandicraftsTypesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postHandicraftsTypes(event.requestBody);

        if (response.status == true) {
          emit(PostHandicraftsTypesSuccess(response: response));
        } else {
          emit(PostHandicraftsTypesError(message: response.message ?? 'Failed to post handicrafts types'));
        }
      } catch (e) {
        emit(PostHandicraftsTypesError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}


// ========================= Post Product Entry BLoC =========================
class ProductEntryBloc extends Bloc<ProductEntryEvent, ProductEntryState> {
  ProductEntryBloc() : super(ProductEntryInitial()) {
    on<FetchProductEntry>((FetchProductEntry event, Emitter<ProductEntryState> emit) async {
      emit(ProductEntryLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postProductEntry(event.requestBody);

        if (response.status == true) {
          emit(ProductEntrySuccess(response: response));
        } else {
          emit(ProductEntryError(message: response.message ?? 'Failed to post handicrafts types'));
        }
      } catch (e) {
        emit(ProductEntryError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Catalogue Image Entry BLoC =========================
class CatalogueImageEntryBloc extends Bloc<CatalogueImageEntryEvent, CatalogueImageEntryState> {
  CatalogueImageEntryBloc() : super(CatalogueImageEntryInitial()) {
    on<UploadCatalogueImage>((UploadCatalogueImage event, Emitter<CatalogueImageEntryState> emit) async {
      emit(CatalogueImageEntryLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.postImageEntry(
          productId: event.productId,
          imageFile: event.imageFile,
          setAsPrimary: event.setAsPrimary,
          sortOrder: event.sortOrder,
        );

        if (response.status == true) {
          emit(CatalogueImageEntrySuccess(response: response));
        } else {
          emit(CatalogueImageEntryError(message: response.message ?? 'Failed to upload image'));
        }
      } catch (e) {
        emit(CatalogueImageEntryError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

// ========================= Put Catalogue Options Entry BLoC =========================
class PutCatalogueOptionsEntryBloc extends Bloc<PutCatalogueOptionsEntryEvent, PutCatalogueOptionsEntryState> {
  PutCatalogueOptionsEntryBloc() : super(PutCatalogueOptionsEntryInitial()) {
    on<UpdateCatalogueOptions>((UpdateCatalogueOptions event, Emitter<PutCatalogueOptionsEntryState> emit) async {
      emit(PutCatalogueOptionsEntryLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.putCatalogueOptionsEntry(
          productId: event.productId,
          requestBody: event.requestBody,
        );

        if (response.status == true) {
          emit(PutCatalogueOptionsEntrySuccess(response: response));
        } else {
          emit(PutCatalogueOptionsEntryError(message: response.message ?? 'Failed to update product options'));
        }
      } catch (e) {
        emit(PutCatalogueOptionsEntryError(message: 'Error: ${e.toString()}'));
      }
    });
  }
}

