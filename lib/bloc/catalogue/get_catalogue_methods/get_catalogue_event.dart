abstract class GetProductTypeEvent {}
class FetchGetProductType extends GetProductTypeEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetProductType({this.showLoader = false});
}


abstract class GetUtilitiesEvent {}
class FetchGetUtilities extends GetUtilitiesEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetUtilities({this.showLoader = false});
}


abstract class GetColorsEvent {}
class FetchGetColors extends GetColorsEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetColors({this.showLoader = false});
}


abstract class GetFinishesEvent {}
class FetchGetFinishes extends GetFinishesEvent {
  final bool showLoader; // new: whether the UI should show a full-page loader
  FetchGetFinishes({this.showLoader = false});
}


abstract class GetTexturesEvent {}
class FetchGetTextures extends GetTexturesEvent {
  final bool showLoader; // new: whether the UI should show a full-page loader
  FetchGetTextures({this.showLoader = false});
}


abstract class GetNaturalColorsEvent {}
class FetchGetNaturalColors extends GetNaturalColorsEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetNaturalColors({this.showLoader = false});
}


abstract class GetOriginsEvent {}
class FetchGetOrigins extends GetOriginsEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetOrigins({this.showLoader = false});
}


abstract class GetStateCountriesEvent {}
class FetchGetStateCountries extends GetStateCountriesEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetStateCountries({this.showLoader = false});
}


abstract class GetProcessingNatureEvent {}
class FetchGetProcessingNature extends GetProcessingNatureEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetProcessingNature({this.showLoader = false});
}


abstract class GetNaturalMaterialEvent {}
class FetchGetNaturalMaterial extends GetNaturalMaterialEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetNaturalMaterial({this.showLoader = false});
}


abstract class GetHandicraftsEvent {}
class FetchGetHandicrafts extends GetHandicraftsEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetHandicrafts({this.showLoader = false});
}

// ========================= Get Catalogue Product List Event =========================
abstract class GetCatalogueProductListEvent {}
class FetchGetCatalogueProductList extends GetCatalogueProductListEvent {
  final int page;
  final int pageSize;
  final bool showLoader;
  final String? search;

  FetchGetCatalogueProductList({
    this.page = 1,
    this.pageSize = 20,
    this.showLoader = false,
    this.search
  });
}

// ======================== Get Catalogue Product Details Events ========================
abstract class GetCatalogueProductDetailsEvent {}

class FetchGetCatalogueProductDetails extends GetCatalogueProductDetailsEvent {
  final String productId;
  final bool showLoader;

  FetchGetCatalogueProductDetails({
    required this.productId,
    this.showLoader = true,
  });
}



// ======================== Get Price Range Events ========================
abstract class GetPriceRangeEvent {}

class FetchGetPriceRange extends GetPriceRangeEvent {

  final bool showLoader;

  FetchGetPriceRange({

    this.showLoader = true,
  });
}



// ======================== Get Catalogue Product Details Events ========================
abstract class GetMinesOptionEvent {}

class FetchGetMinesOption extends GetMinesOptionEvent {

  final bool showLoader;

  FetchGetMinesOption({

    this.showLoader = true,
  });
}


