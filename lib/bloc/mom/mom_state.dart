

// ========================= Mom Image Upload States =========================
import 'package:apclassstone/api/models/response/PostMomImageUploadResponseBody.dart';

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
