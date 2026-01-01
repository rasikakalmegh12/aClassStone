import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../api/integration/api_integration.dart';
import 'get_catalogue_event.dart';
import 'get_catalogue_state.dart';

// ========================= Product Type Bloc =========================
class GetProductTypeBloc extends Bloc<GetProductTypeEvent, GetProductTypeState> {
  GetProductTypeBloc() : super(GetProductTypeInitial()) {
    on<FetchGetProductType>((event, emit) async {
      emit(GetProductTypeLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getProductType();

        if (response.status == true) {
          emit(GetProductTypeLoaded(response: response));
        } else {
          emit(GetProductTypeLoaded(response: response));
        }
      } catch (e) {
        emit(GetProductTypeError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Utilities Bloc =========================
class GetUtilitiesBloc extends Bloc<GetUtilitiesEvent, GetUtilitiesState> {
  GetUtilitiesBloc() : super(GetUtilitiesInitial()) {
    on<FetchGetUtilities>((FetchGetUtilities event, Emitter<GetUtilitiesState> emit) async {
      emit(GetUtilitiesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getUtilities();

        if (response.status == true) {
          emit(GetUtilitiesLoaded(response: response));
        } else {
          emit(GetUtilitiesLoaded(response: response));
        }
      } catch (e) {
        emit(GetUtilitiesError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Colors Bloc =========================
class GetColorsBloc extends Bloc<GetColorsEvent, GetColorsState> {
  GetColorsBloc() : super(GetColorsInitial()) {
    on<FetchGetColors>((event, emit) async {
      emit(GetColorsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getColors();

        if (response.status == true) {
          emit(GetColorsLoaded(response: response));
        } else {
          emit(GetColorsLoaded(response: response));
        }
      } catch (e) {
        emit(GetColorsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Finishes Bloc =========================
class GetFinishesBloc extends Bloc<GetFinishesEvent, GetFinishesState> {
  GetFinishesBloc() : super(GetFinishesInitial()) {
    on<FetchGetFinishes>((event, emit) async {
      emit(GetFinishesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getFinishes();

        if (response.status == true) {
          emit(GetFinishesLoaded(response: response));
        } else {
          emit(GetFinishesLoaded(response: response));
        }
      } catch (e) {
        emit(GetFinishesError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Textures Bloc =========================
class GetTexturesBloc extends Bloc<GetTexturesEvent, GetTexturesState> {
  GetTexturesBloc() : super(GetTexturesInitial()) {
    on<FetchGetTextures>((event, emit) async {
      emit(GetTexturesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getTextures();

        if (response.status == true) {
          emit(GetTexturesLoaded(response: response));
        } else {
          emit(GetTexturesLoaded(response: response));
        }
      } catch (e) {
        emit(GetTexturesError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Natural Colors Bloc =========================
class GetNaturalColorsBloc extends Bloc<GetNaturalColorsEvent, GetNaturalColorsState> {
  GetNaturalColorsBloc() : super(GetNaturalColorsInitial()) {
    on<FetchGetNaturalColors>((event, emit) async {
      emit(GetNaturalColorsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getNaturalColours();

        if (response.status == true) {
          emit(GetNaturalColorsLoaded(response: response));
        } else {
          emit(GetNaturalColorsLoaded(response: response));
        }
      } catch (e) {
        emit(GetNaturalColorsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Origins Bloc =========================
class GetOriginsBloc extends Bloc<GetOriginsEvent, GetOriginsState> {
  GetOriginsBloc() : super(GetOriginsInitial()) {
    on<FetchGetOrigins>((event, emit) async {
      emit(GetOriginsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getOrigins();

        if (response.status == true) {
          emit(GetOriginsLoaded(response: response));
        } else {
          emit(GetOriginsLoaded(response: response));
        }
      } catch (e) {
        emit(GetOriginsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= State Countries Bloc =========================
class GetStateCountriesBloc extends Bloc<GetStateCountriesEvent, GetStateCountriesState> {
  GetStateCountriesBloc() : super(GetStateCountriesInitial()) {
    on<FetchGetStateCountries>((event, emit) async {
      emit(GetStateCountriesLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getStateCountries();

        if (response.status == true) {
          emit(GetStateCountriesLoaded(response: response));
        } else {
          emit(GetStateCountriesLoaded(response: response));
        }
      } catch (e) {
        emit(GetStateCountriesError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Processing Nature Bloc =========================
class GetProcessingNatureBloc extends Bloc<GetProcessingNatureEvent, GetProcessingNatureState> {
  GetProcessingNatureBloc() : super(GetProcessingNatureInitial()) {
    on<FetchGetProcessingNature>((event, emit) async {
      emit(GetProcessingNatureLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getProcessingNature();

        if (response.status == true) {
          emit(GetProcessingNatureLoaded(response: response));
        } else {
          emit(GetProcessingNatureLoaded(response: response));
        }
      } catch (e) {
        emit(GetProcessingNatureError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Natural Material Bloc =========================
class GetNaturalMaterialBloc extends Bloc<GetNaturalMaterialEvent, GetNaturalMaterialState> {
  GetNaturalMaterialBloc() : super(GetNaturalMaterialInitial()) {
    on<FetchGetNaturalMaterial>((event, emit) async {
      emit(GetNaturalMaterialLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getNaturalMaterial();

        if (response.status == true) {
          emit(GetNaturalMaterialLoaded(response: response));
        } else {
          emit(GetNaturalMaterialLoaded(response: response));
        }
      } catch (e) {
        emit(GetNaturalMaterialError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Handicrafts Bloc =========================
class GetHandicraftsBloc extends Bloc<GetHandicraftsEvent, GetHandicraftsState> {
  GetHandicraftsBloc() : super(GetHandicraftsInitial()) {
    on<FetchGetHandicrafts>((event, emit) async {
      emit(GetHandicraftsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getHandicraftsTypes();

        if (response.status == true) {
          emit(GetHandicraftsLoaded(response: response));
        } else {
          emit(GetHandicraftsLoaded(response: response));
        }
      } catch (e) {
        emit(GetHandicraftsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ========================= Get Catalogue Product List BLoC =========================
class GetCatalogueProductListBloc extends Bloc<GetCatalogueProductListEvent, GetCatalogueProductListState> {
  GetCatalogueProductListBloc() : super(GetCatalogueProductListInitial()) {
    on<FetchGetCatalogueProductList>((FetchGetCatalogueProductList event, Emitter<GetCatalogueProductListState> emit) async {
      emit(GetCatalogueProductListLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getCatalogueProductList(
          page: event.page,
          pageSize: event.pageSize,
        );

        if (response.status == true) {
          emit(GetCatalogueProductListLoaded(response: response));
        } else {
          emit(GetCatalogueProductListError(message: response.message ?? 'Failed to fetch products'));
        }
      } catch (e) {
        emit(GetCatalogueProductListError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}

// ======================== Get Catalogue Product Details BLoC ========================
class GetCatalogueProductDetailsBloc extends Bloc<GetCatalogueProductDetailsEvent, GetCatalogueProductDetailsState> {
  GetCatalogueProductDetailsBloc() : super(GetCatalogueProductDetailsInitial()) {
    on<FetchGetCatalogueProductDetails>((FetchGetCatalogueProductDetails event, Emitter<GetCatalogueProductDetailsState> emit) async {
      emit(GetCatalogueProductDetailsLoading(showLoader: event.showLoader));

      try {
        final response = await ApiIntegration.getCatalogueProductDetails(
          productId: event.productId,
        );

        if (response.status == true) {
          emit(GetCatalogueProductDetailsLoaded(response: response));
        } else {
          emit(GetCatalogueProductDetailsError(message: response.message ?? 'Failed to fetch product details'));
        }
      } catch (e) {
        emit(GetCatalogueProductDetailsError(
          message: 'Error: ${e.toString()}',
        ));
      }
    });
  }
}
