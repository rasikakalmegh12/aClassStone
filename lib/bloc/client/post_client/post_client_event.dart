


import 'package:apclassstone/api/models/request/PostClientAddContactRequestBody.dart';
import 'package:apclassstone/api/models/request/PostClientAddLocationRequestBody.dart';
import 'package:apclassstone/api/models/request/PostClientAddRequestBody.dart';

abstract class PostClientAddEvent {}
class FetchPostClientAdd extends PostClientAddEvent {

  final PostClientAddRequestBody requestBody;
  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchPostClientAdd({this.showLoader = false, required this.requestBody, });
}

abstract class PostClientAddLocationEvent {}
class FetchPostClientAddLocation extends PostClientAddLocationEvent {

  final PostClientAddLocationRequestBody requestBody;
  final bool showLoader; // new: whether the UI should show a full-page loader
  final String clientId;
  FetchPostClientAddLocation({this.showLoader = false, required this.requestBody, required this.clientId, });
}

abstract class PostClientAddContactEvent {}
class FetchPostClientAddContact extends PostClientAddContactEvent {

  final PostClientAddContactRequestBody requestBody;
  final bool showLoader; // new: whether the UI should show a full-page loader
  final String clientId;
  final String locationId;
  FetchPostClientAddContact({this.showLoader = false, required this.requestBody, required this.clientId, required this.locationId, });
}

