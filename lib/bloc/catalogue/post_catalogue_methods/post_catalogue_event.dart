import 'package:apclassstone/api/models/request/PostMinesEntryRequestBody.dart';
import 'package:apclassstone/api/models/request/PostSearchRequestBody.dart';
import 'package:apclassstone/api/models/request/ProductEntryRequestBody.dart';
import 'package:apclassstone/api/models/request/PutCatalogueOptionEntryRequestBody.dart';
import 'dart:io';

import '../../../api/models/request/PostCatalogueCommonRequestBody.dart';

// ========================= Post Colors Event =========================
abstract class PostColorsEvent {}
class SubmitPostColors extends PostColorsEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostColors({required this.requestBody, this.showLoader = false});
}

// ========================= Post Utilities Event =========================
abstract class PostUtilitiesEvent {}
class SubmitPostUtilities extends PostUtilitiesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostUtilities({required this.requestBody, this.showLoader = false});
}

// ========================= Post Finishes Event =========================
abstract class PostFinishesEvent {}
class SubmitPostFinishes extends PostFinishesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostFinishes({required this.requestBody, this.showLoader = false});
}

// ========================= Post Textures Event =========================
abstract class PostTexturesEvent {}
class SubmitPostTextures extends PostTexturesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostTextures({required this.requestBody, this.showLoader = false});
}

// ========================= Post Natural Colors Event =========================
abstract class PostNaturalColorsEvent {}
class SubmitPostNaturalColors extends PostNaturalColorsEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostNaturalColors({required this.requestBody, this.showLoader = false});
}

// ========================= Post Origins Event =========================
abstract class PostOriginsEvent {}
class SubmitPostOrigins extends PostOriginsEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostOrigins({required this.requestBody, this.showLoader = false});
}

// ========================= Post State Countries Event =========================
abstract class PostStateCountriesEvent {}
class SubmitPostStateCountries extends PostStateCountriesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostStateCountries({required this.requestBody, this.showLoader = false});
}

// ========================= Post Processing Natures Event =========================
abstract class PostProcessingNaturesEvent {}
class SubmitPostProcessingNatures extends PostProcessingNaturesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostProcessingNatures({required this.requestBody, this.showLoader = false});
}

// ========================= Post Natural Materials Event =========================
abstract class PostNaturalMaterialsEvent {}
class SubmitPostNaturalMaterials extends PostNaturalMaterialsEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostNaturalMaterials({required this.requestBody, this.showLoader = false});
}

// ========================= Post Handicrafts Types Event =========================
abstract class PostHandicraftsTypesEvent {}
class SubmitPostHandicraftsTypes extends PostHandicraftsTypesEvent {
  final PostCatalogueCommonRequestBody requestBody;
  final bool showLoader;

  SubmitPostHandicraftsTypes({required this.requestBody, this.showLoader = false});
}


// ========================= Post Handicrafts Types Event =========================
abstract class ProductEntryEvent {}
class FetchProductEntry extends ProductEntryEvent {
  final ProductEntryRequestBody requestBody;
  final bool showLoader;

  FetchProductEntry({required this.requestBody, this.showLoader = false});
}

// ========================= Catalogue Image Entry Event =========================
abstract class CatalogueImageEntryEvent {}
class UploadCatalogueImage extends CatalogueImageEntryEvent {
  final String productId;
  final File imageFile;
  final bool setAsPrimary;
  final int sortOrder;
  final bool showLoader;

  UploadCatalogueImage({
    required this.productId,
    required this.imageFile,
    this.setAsPrimary = false,
    this.sortOrder = 0,
    this.showLoader = false,
  });
}

// ========================= Put Catalogue Options Entry Event =========================
abstract class PutCatalogueOptionsEntryEvent {}
class UpdateCatalogueOptions extends PutCatalogueOptionsEntryEvent {
  final String productId;
  final PutCatalogueOptionEntryRequestBody requestBody;
  final bool showLoader;

  UpdateCatalogueOptions({
    required this.productId,
    required this.requestBody,
    this.showLoader = false,
  });
}



// ========================= Post Mines Entry Event =========================
abstract class PostMinesEntryEvent {}
class SubmitPostMinesEntry extends PostMinesEntryEvent {

  final PostMinesEntryRequestBody requestBody;
  final bool showLoader;

  SubmitPostMinesEntry({

    required this.requestBody,
    this.showLoader = false,
  });
}


// ========================= Post Mines Entry Event =========================
abstract class PostSearchEvent {}
class SubmitPostSearch extends PostSearchEvent {

  final PostSearchRequestBody requestBody;
  final bool showLoader;

  SubmitPostSearch({

    required this.requestBody,
    this.showLoader = false,
  });
}



