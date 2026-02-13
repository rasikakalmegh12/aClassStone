import 'package:apclassstone/api/models/request/PutEditCatalogueRequestBody.dart';

// ========================= Put Edit Product Event =========================
abstract class PutEditProductEvent {}

class SubmitPutEditProduct extends PutEditProductEvent {
  final String productId;
  final PutEditCatalogueRequestBody requestBody;
  final bool showLoader;

  SubmitPutEditProduct({
    required this.productId,
    required this.requestBody,
    this.showLoader = false,
  });
}

