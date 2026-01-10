import 'package:apclassstone/api/models/response/GeneratePdfResponseBody.dart';

abstract class GeneratePdfState {}

// Initial State
class GeneratePdfInitial extends GeneratePdfState {}

// Loading State
class GeneratePdfLoading extends GeneratePdfState {
  final bool showLoader;
  GeneratePdfLoading({this.showLoader = true});
}

// Success State
class GeneratePdfSuccess extends GeneratePdfState {
  final GeneratePdfResponseBody response;
  GeneratePdfSuccess(this.response);
}

// Error State
class GeneratePdfError extends GeneratePdfState {
  final String message;
  GeneratePdfError(this.message);
}

