import 'package:apclassstone/api/models/response/PutEditCatalogueResponseBody.dart';

// ========================= Put Edit Product State =========================
abstract class PutEditProductState {}

class PutEditProductInitial extends PutEditProductState {}

class PutEditProductLoading extends PutEditProductState {
  final bool showLoader;

  PutEditProductLoading({this.showLoader = false});
}

class PutEditProductSuccess extends PutEditProductState {
  final PutEditCatalogueResponseBody response;

  PutEditProductSuccess({required this.response});
}

class PutEditProductError extends PutEditProductState {
  final String message;

  PutEditProductError({required this.message});
}

