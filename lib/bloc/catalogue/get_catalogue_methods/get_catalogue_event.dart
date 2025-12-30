


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

