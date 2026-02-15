// ========================= Put Catalogue Image Operations Event =========================
abstract class PutCatalogueImageOperationsEvent {}

/// Event to delete a product image
class DeleteProductImage extends PutCatalogueImageOperationsEvent {
  final String productId;
  final String imageId;
  final bool showLoader;

  DeleteProductImage({
    required this.productId,
    required this.imageId,
    this.showLoader = true,
  });
}

/// Event to set an image as primary
class SetImagePrimary extends PutCatalogueImageOperationsEvent {
  final String productId;
  final String imageId;
  final bool showLoader;

  SetImagePrimary({
    required this.productId,
    required this.imageId,
    this.showLoader = true,
  });
}

