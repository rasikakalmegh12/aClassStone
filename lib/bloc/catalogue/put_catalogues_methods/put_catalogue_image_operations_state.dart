import 'package:apclassstone/api/models/response/ApiCommonResponseBody.dart';

// ========================= Put Catalogue Image Operations State =========================
abstract class PutCatalogueImageOperationsState {}

/// Initial state
class PutCatalogueImageOperationsInitial extends PutCatalogueImageOperationsState {}

/// Loading state for image operations
class PutCatalogueImageOperationsLoading extends PutCatalogueImageOperationsState {
  final bool showLoader;
  final String operationType; // 'delete' or 'setPrimary'

  PutCatalogueImageOperationsLoading({
    this.showLoader = true,
    this.operationType = '',
  });
}

/// Success state for delete image
class DeleteImageSuccess extends PutCatalogueImageOperationsState {
  final ApiCommonResponseBody response;
  final String imageId;

  DeleteImageSuccess({
    required this.response,
    required this.imageId,
  });
}

/// Success state for set image primary
class SetImagePrimarySuccess extends PutCatalogueImageOperationsState {
  final ApiCommonResponseBody response;
  final String imageId;

  SetImagePrimarySuccess({
    required this.response,
    required this.imageId,
  });
}

/// Error state for image operations
class PutCatalogueImageOperationsError extends PutCatalogueImageOperationsState {
  final String message;
  final String operationType; // 'delete' or 'setPrimary'

  PutCatalogueImageOperationsError({
    required this.message,
    this.operationType = '',
  });
}

