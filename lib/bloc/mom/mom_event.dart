// ========================= Mom Image Upload Events =========================
import 'dart:io';

import '../../api/models/request/PostMomEntryRequestBody.dart';

abstract class MomImageUploadEvent {}

class UploadMomImage extends MomImageUploadEvent {
  final String momId;
  final File imageFile;
  final String caption;
  final int sortOrder;
  final bool showLoader;

  UploadMomImage({
    required this.momId,
    required this.imageFile,
    required this.caption,
    this.sortOrder = 0,
    this.showLoader = false,
  });
}


// ========================= Post MOM Entry Events =========================
abstract class PostMomEntryEvent {}

class SubmitMomEntry extends PostMomEntryEvent {
  final PostMomEntryRequestBody requestBody;
  final bool showLoader;

  SubmitMomEntry({
    required this.requestBody,
    this.showLoader = false,
  });
}


// ========================= Get MOM List Events =========================
abstract class GetMomListEvent {}

class FetchMomList extends GetMomListEvent {
  final bool showLoader;
  final String? search;
  final String? status;
  final bool? isConvertedToLead;

  FetchMomList({
    this.showLoader = false,
    this.search,
    this.status,
    this.isConvertedToLead,
  });
}

// ========================= Get MOM Details Events =========================
abstract class GetMomDetailsEvent {}

class FetchMomDetails extends GetMomDetailsEvent {
  final String momId;
  final bool showLoader;

  FetchMomDetails({
    required this.momId,
    this.showLoader = false,
  });
}
