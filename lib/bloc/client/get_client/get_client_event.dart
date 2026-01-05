

abstract class GetClientListEvent {}
class FetchGetClientList extends GetClientListEvent {

  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetClientList({this.showLoader = false});
}


abstract class GetClientDetailsEvent {}
class FetchGetClientDetails extends GetClientDetailsEvent {
  final String clientId;
  final bool showLoader; // new: whether the UI should show a full-page loader

  FetchGetClientDetails({this.showLoader = false, required this.clientId});
}

