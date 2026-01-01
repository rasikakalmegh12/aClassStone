import 'package:apclassstone/api/models/response/ProductEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/CatalogueImageEntryResponseBody.dart';
import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';

import '../../../api/models/response/PostCatalogueCommonResponseBody.dart';

// ========================= Post Colors State =========================
abstract class PostColorsState {}
class PostColorsInitial extends PostColorsState {}
class PostColorsLoading extends PostColorsState {
  final bool showLoader;
  PostColorsLoading({this.showLoader = false});
}
class PostColorsSuccess extends PostColorsState {
  final PostCatalogueCommonResponseBody response;
  PostColorsSuccess({required this.response});
}
class PostColorsError extends PostColorsState {
  final String message;
  PostColorsError({required this.message});
}

// ========================= Post Utilities State =========================
abstract class PostUtilitiesState {}
class PostUtilitiesInitial extends PostUtilitiesState {}
class PostUtilitiesLoading extends PostUtilitiesState {
  final bool showLoader;
  PostUtilitiesLoading({this.showLoader = false});
}
class PostUtilitiesSuccess extends PostUtilitiesState {
  final PostCatalogueCommonResponseBody response;
  PostUtilitiesSuccess({required this.response});
}
class PostUtilitiesError extends PostUtilitiesState {
  final String message;
  PostUtilitiesError({required this.message});
}

// ========================= Post Finishes State =========================
abstract class PostFinishesState {}
class PostFinishesInitial extends PostFinishesState {}
class PostFinishesLoading extends PostFinishesState {
  final bool showLoader;
  PostFinishesLoading({this.showLoader = false});
}
class PostFinishesSuccess extends PostFinishesState {
  final PostCatalogueCommonResponseBody response;
  PostFinishesSuccess({required this.response});
}
class PostFinishesError extends PostFinishesState {
  final String message;
  PostFinishesError({required this.message});
}

// ========================= Post Textures State =========================
abstract class PostTexturesState {}
class PostTexturesInitial extends PostTexturesState {}
class PostTexturesLoading extends PostTexturesState {
  final bool showLoader;
  PostTexturesLoading({this.showLoader = false});
}
class PostTexturesSuccess extends PostTexturesState {
  final PostCatalogueCommonResponseBody response;
  PostTexturesSuccess({required this.response});
}
class PostTexturesError extends PostTexturesState {
  final String message;
  PostTexturesError({required this.message});
}

// ========================= Post Natural Colors State =========================
abstract class PostNaturalColorsState {}
class PostNaturalColorsInitial extends PostNaturalColorsState {}
class PostNaturalColorsLoading extends PostNaturalColorsState {
  final bool showLoader;
  PostNaturalColorsLoading({this.showLoader = false});
}
class PostNaturalColorsSuccess extends PostNaturalColorsState {
  final PostCatalogueCommonResponseBody response;
  PostNaturalColorsSuccess({required this.response});
}
class PostNaturalColorsError extends PostNaturalColorsState {
  final String message;
  PostNaturalColorsError({required this.message});
}

// ========================= Post Origins State =========================
abstract class PostOriginsState {}
class PostOriginsInitial extends PostOriginsState {}
class PostOriginsLoading extends PostOriginsState {
  final bool showLoader;
  PostOriginsLoading({this.showLoader = false});
}
class PostOriginsSuccess extends PostOriginsState {
  final PostCatalogueCommonResponseBody response;
  PostOriginsSuccess({required this.response});
}
class PostOriginsError extends PostOriginsState {
  final String message;
  PostOriginsError({required this.message});
}

// ========================= Post State Countries State =========================
abstract class PostStateCountriesState {}
class PostStateCountriesInitial extends PostStateCountriesState {}
class PostStateCountriesLoading extends PostStateCountriesState {
  final bool showLoader;
  PostStateCountriesLoading({this.showLoader = false});
}
class PostStateCountriesSuccess extends PostStateCountriesState {
  final PostCatalogueCommonResponseBody response;
  PostStateCountriesSuccess({required this.response});
}
class PostStateCountriesError extends PostStateCountriesState {
  final String message;
  PostStateCountriesError({required this.message});
}

// ========================= Post Processing Natures State =========================
abstract class PostProcessingNaturesState {}
class PostProcessingNaturesInitial extends PostProcessingNaturesState {}
class PostProcessingNaturesLoading extends PostProcessingNaturesState {
  final bool showLoader;
  PostProcessingNaturesLoading({this.showLoader = false});
}
class PostProcessingNaturesSuccess extends PostProcessingNaturesState {
  final PostCatalogueCommonResponseBody response;
  PostProcessingNaturesSuccess({required this.response});
}
class PostProcessingNaturesError extends PostProcessingNaturesState {
  final String message;
  PostProcessingNaturesError({required this.message});
}

// ========================= Post Natural Materials State =========================
abstract class PostNaturalMaterialsState {}
class PostNaturalMaterialsInitial extends PostNaturalMaterialsState {}
class PostNaturalMaterialsLoading extends PostNaturalMaterialsState {
  final bool showLoader;
  PostNaturalMaterialsLoading({this.showLoader = false});
}
class PostNaturalMaterialsSuccess extends PostNaturalMaterialsState {
  final PostCatalogueCommonResponseBody response;
  PostNaturalMaterialsSuccess({required this.response});
}
class PostNaturalMaterialsError extends PostNaturalMaterialsState {
  final String message;
  PostNaturalMaterialsError({required this.message});
}

// ========================= Post Handicrafts Types State =========================
abstract class PostHandicraftsTypesState {}
class PostHandicraftsTypesInitial extends PostHandicraftsTypesState {}
class PostHandicraftsTypesLoading extends PostHandicraftsTypesState {
  final bool showLoader;
  PostHandicraftsTypesLoading({this.showLoader = false});
}
class PostHandicraftsTypesSuccess extends PostHandicraftsTypesState {
  final PostCatalogueCommonResponseBody response;
  PostHandicraftsTypesSuccess({required this.response});
}
class PostHandicraftsTypesError extends PostHandicraftsTypesState {
  final String message;
  PostHandicraftsTypesError({required this.message});
}


// ========================= Product Entry State =========================
abstract class ProductEntryState {}
class ProductEntryInitial extends ProductEntryState {}
class ProductEntryLoading extends ProductEntryState {
  final bool showLoader;
  ProductEntryLoading({this.showLoader = false});
}
class ProductEntrySuccess extends ProductEntryState {
  final ProductEntryResponseBody response;
  ProductEntrySuccess({required this.response});
}
class ProductEntryError extends ProductEntryState {
  final String message;
  ProductEntryError({required this.message});
}

// ========================= Catalogue Image Entry State =========================
abstract class CatalogueImageEntryState {}
class CatalogueImageEntryInitial extends CatalogueImageEntryState {}
class CatalogueImageEntryLoading extends CatalogueImageEntryState {
  final bool showLoader;
  CatalogueImageEntryLoading({this.showLoader = false});
}
class CatalogueImageEntrySuccess extends CatalogueImageEntryState {
  final CatalogueImageEntryResponseBody response;
  CatalogueImageEntrySuccess({required this.response});
}
class CatalogueImageEntryError extends CatalogueImageEntryState {
  final String message;
  CatalogueImageEntryError({required this.message});
}

// ========================= Put Catalogue Options Entry State =========================
abstract class PutCatalogueOptionsEntryState {}
class PutCatalogueOptionsEntryInitial extends PutCatalogueOptionsEntryState {}
class PutCatalogueOptionsEntryLoading extends PutCatalogueOptionsEntryState {
  final bool showLoader;
  PutCatalogueOptionsEntryLoading({this.showLoader = false});
}
class PutCatalogueOptionsEntrySuccess extends PutCatalogueOptionsEntryState {
  final ApiCommonResponseBody response;
  PutCatalogueOptionsEntrySuccess({required this.response});
}
class PutCatalogueOptionsEntryError extends PutCatalogueOptionsEntryState {
  final String message;
  PutCatalogueOptionsEntryError({required this.message});
}

