

// ========================= Mom Image Upload States =========================
import 'package:apclassstone/api/models/response/PostMomImageUploadResponseBody.dart';

import '../../api/models/response/GetMomIdDetailsResponseBody.dart';
import '../../api/models/response/GetMomResponseBody.dart';
import '../../api/models/response/PostMomEntryResponseBody.dart';

abstract class MomImageUploadState {}

class MomImageUploadInitial extends MomImageUploadState {}

class MomImageUploadLoading extends MomImageUploadState {
  final bool showLoader;
  MomImageUploadLoading({this.showLoader = false});
}

class MomImageUploadSuccess extends MomImageUploadState {
  final PostMomImageUploadResponseBody response;
  MomImageUploadSuccess({required this.response});
}

class MomImageUploadError extends MomImageUploadState {
  final String message;
  MomImageUploadError({required this.message});
}



// ========================= Post MOM Entry States =========================
abstract class PostMomEntryState {}

class PostMomEntryInitial extends PostMomEntryState {}

class PostMomEntryLoading extends PostMomEntryState {
  final bool showLoader;
  PostMomEntryLoading({this.showLoader = false});
}

class PostMomEntrySuccess extends PostMomEntryState {
  final PostMomEntryResponseBody response;
  PostMomEntrySuccess({required this.response});
}

class PostMomEntryError extends PostMomEntryState {
  final String message;
  PostMomEntryError({required this.message});
}


// ========================= Get MOM Details States =========================
abstract class GetMomDetailsState {}

class GetMomDetailsInitial extends GetMomDetailsState {}

class GetMomDetailsLoading extends GetMomDetailsState {
  final bool showLoader;

  GetMomDetailsLoading({this.showLoader = false});
}

class GetMomDetailsSuccess extends GetMomDetailsState {
  final GetMomIdDetailsResponseBody response;

  GetMomDetailsSuccess({required this.response});
}

class GetMomDetailsError extends GetMomDetailsState {
  final String message;

  GetMomDetailsError({required this.message});
}



// ========================= Get MOM List States =========================
abstract class GetMomListState {}

class GetMomListInitial extends GetMomListState {}

class GetMomListLoading extends GetMomListState {
  final bool showLoader;

  GetMomListLoading({this.showLoader = false});
}

class GetMomListSuccess extends GetMomListState {
  final GetMomResponseBody response;

  GetMomListSuccess({required this.response});
}

class GetMomListError extends GetMomListState {
  final String message;

  GetMomListError({required this.message});
}
