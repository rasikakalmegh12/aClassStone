import 'package:apclassstone/api/models/response/GetColorsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetFinishesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetHandicraftsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetMaterialNatureResponseBody.dart';
import 'package:apclassstone/api/models/response/GetNaturalColorResponseBody.dart';
import 'package:apclassstone/api/models/response/GetOriginsResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProcessingNaturesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetProductTypeResponseBody.dart';
import 'package:apclassstone/api/models/response/GetStateCountriesResponseBody.dart';
import 'package:apclassstone/api/models/response/GetTextureResponseBody.dart';
import 'package:apclassstone/api/models/response/GetUtilitiesTypeResponseBody.dart';
import 'package:apclassstone/api/models/response/GetCatalogueProductResponseBody.dart';
import 'package:apclassstone/api/models/response/GetCatalogueProductDetailsResponseBody.dart';

// ========================= Product Type States =========================
abstract class GetProductTypeState {}
class GetProductTypeInitial extends GetProductTypeState {}
class GetProductTypeLoading extends GetProductTypeState {
  final bool showLoader;
  GetProductTypeLoading({this.showLoader = false});
}
class GetProductTypeLoaded extends GetProductTypeState {
  final GetProductTypeResponseBody response;
  GetProductTypeLoaded({required this.response});
}
class GetProductTypeError extends GetProductTypeState {
  final String message;
  GetProductTypeError({required this.message});
}

// ========================= Utilities States =========================
abstract class GetUtilitiesState {}
class GetUtilitiesInitial extends GetUtilitiesState {}
class GetUtilitiesLoading extends GetUtilitiesState {
  final bool showLoader;
  GetUtilitiesLoading({this.showLoader = false});
}
class GetUtilitiesLoaded extends GetUtilitiesState {
  final GetUtilitiesTypeResponseBody response;
  GetUtilitiesLoaded({required this.response});
}
class GetUtilitiesError extends GetUtilitiesState {
  final String message;
  GetUtilitiesError({required this.message});
}

// ========================= Colors States =========================
abstract class GetColorsState {}
class GetColorsInitial extends GetColorsState {}
class GetColorsLoading extends GetColorsState {
  final bool showLoader;
  GetColorsLoading({this.showLoader = false});
}
class GetColorsLoaded extends GetColorsState {
  final GetColorsResponseBody response;
  GetColorsLoaded({required this.response});
}
class GetColorsError extends GetColorsState {
  final String message;
  GetColorsError({required this.message});
}

// ========================= Finishes States =========================
abstract class GetFinishesState {}
class GetFinishesInitial extends GetFinishesState {}
class GetFinishesLoading extends GetFinishesState {
  final bool showLoader;
  GetFinishesLoading({this.showLoader = false});
}
class GetFinishesLoaded extends GetFinishesState {
  final GetFinishesResponseBody response;
  GetFinishesLoaded({required this.response});
}
class GetFinishesError extends GetFinishesState {
  final String message;
  GetFinishesError({required this.message});
}

// ========================= Textures States =========================
abstract class GetTexturesState {}
class GetTexturesInitial extends GetTexturesState {}
class GetTexturesLoading extends GetTexturesState {
  final bool showLoader;
  GetTexturesLoading({this.showLoader = false});
}
class GetTexturesLoaded extends GetTexturesState {
  final GetTextureResponseBody response;
  GetTexturesLoaded({required this.response});
}
class GetTexturesError extends GetTexturesState {
  final String message;
  GetTexturesError({required this.message});
}

// ========================= Natural Colors States =========================
abstract class GetNaturalColorsState {}
class GetNaturalColorsInitial extends GetNaturalColorsState {}
class GetNaturalColorsLoading extends GetNaturalColorsState {
  final bool showLoader;
  GetNaturalColorsLoading({this.showLoader = false});
}
class GetNaturalColorsLoaded extends GetNaturalColorsState {
  final GetNaturalColorResponseBody response;
  GetNaturalColorsLoaded({required this.response});
}
class GetNaturalColorsError extends GetNaturalColorsState {
  final String message;
  GetNaturalColorsError({required this.message});
}

// ========================= Origins States =========================
abstract class GetOriginsState {}
class GetOriginsInitial extends GetOriginsState {}
class GetOriginsLoading extends GetOriginsState {
  final bool showLoader;
  GetOriginsLoading({this.showLoader = false});
}
class GetOriginsLoaded extends GetOriginsState {
  final GetOriginsResponseBody response;
  GetOriginsLoaded({required this.response});
}
class GetOriginsError extends GetOriginsState {
  final String message;
  GetOriginsError({required this.message});
}

// ========================= State Countries States =========================
abstract class GetStateCountriesState {}
class GetStateCountriesInitial extends GetStateCountriesState {}
class GetStateCountriesLoading extends GetStateCountriesState {
  final bool showLoader;
  GetStateCountriesLoading({this.showLoader = false});
}
class GetStateCountriesLoaded extends GetStateCountriesState {
  final GetStateCountriesResponseBody response;
  GetStateCountriesLoaded({required this.response});
}
class GetStateCountriesError extends GetStateCountriesState {
  final String message;
  GetStateCountriesError({required this.message});
}

// ========================= Processing Nature States =========================
abstract class GetProcessingNatureState {}
class GetProcessingNatureInitial extends GetProcessingNatureState {}
class GetProcessingNatureLoading extends GetProcessingNatureState {
  final bool showLoader;
  GetProcessingNatureLoading({this.showLoader = false});
}
class GetProcessingNatureLoaded extends GetProcessingNatureState {
  final GetProcessingNaturesResponseBody response;
  GetProcessingNatureLoaded({required this.response});
}
class GetProcessingNatureError extends GetProcessingNatureState {
  final String message;
  GetProcessingNatureError({required this.message});
}

// ========================= Natural Material States =========================
abstract class GetNaturalMaterialState {}
class GetNaturalMaterialInitial extends GetNaturalMaterialState {}
class GetNaturalMaterialLoading extends GetNaturalMaterialState {
  final bool showLoader;
  GetNaturalMaterialLoading({this.showLoader = false});
}
class GetNaturalMaterialLoaded extends GetNaturalMaterialState {
  final GetMaterialNatureResponseBody response;
  GetNaturalMaterialLoaded({required this.response});
}
class GetNaturalMaterialError extends GetNaturalMaterialState {
  final String message;
  GetNaturalMaterialError({required this.message});
}

// ========================= Handicrafts States =========================
abstract class GetHandicraftsState {}
class GetHandicraftsInitial extends GetHandicraftsState {}
class GetHandicraftsLoading extends GetHandicraftsState {
  final bool showLoader;
  GetHandicraftsLoading({this.showLoader = false});
}
class GetHandicraftsLoaded extends GetHandicraftsState {
  final GetHandicraftsResponseBody response;
  GetHandicraftsLoaded({required this.response});
}
class GetHandicraftsError extends GetHandicraftsState {
  final String message;
  GetHandicraftsError({required this.message});
}

// ========================= Get Catalogue Product List State =========================
abstract class GetCatalogueProductListState {}
class GetCatalogueProductListInitial extends GetCatalogueProductListState {}
class GetCatalogueProductListLoading extends GetCatalogueProductListState {
  final bool showLoader;
  GetCatalogueProductListLoading({this.showLoader = false});
}
class GetCatalogueProductListLoaded extends GetCatalogueProductListState {
  final GetCatalogueProductResponseBody response;
  GetCatalogueProductListLoaded({required this.response});
}
class GetCatalogueProductListError extends GetCatalogueProductListState {
  final String message;
  GetCatalogueProductListError({required this.message});
}

// ======================== Get Catalogue Product Details State ========================
abstract class GetCatalogueProductDetailsState {}

class GetCatalogueProductDetailsInitial extends GetCatalogueProductDetailsState {}

class GetCatalogueProductDetailsLoading extends GetCatalogueProductDetailsState {
  final bool showLoader;
  GetCatalogueProductDetailsLoading({this.showLoader = false});
}

class GetCatalogueProductDetailsLoaded extends GetCatalogueProductDetailsState {
  final GetCatalogueProductDetailsResponseBody response;
  GetCatalogueProductDetailsLoaded({required this.response});
}

class GetCatalogueProductDetailsError extends GetCatalogueProductDetailsState {
  final String message;
  GetCatalogueProductDetailsError({required this.message});
}
