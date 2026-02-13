import 'package:apclassstone/api/models/response/PostClientAddResponseBody.dart';

// ========================= Put Edit Client State =========================
abstract class PutEditClientState {}

class PutEditClientInitial extends PutEditClientState {}

class PutEditClientLoading extends PutEditClientState {
  final bool showLoader;
  PutEditClientLoading({this.showLoader = false});
}

class PutEditClientSuccess extends PutEditClientState {
  final PostClientAddResponseBody response;
  PutEditClientSuccess({required this.response});
}

class PutEditClientError extends PutEditClientState {
  final String message;
  PutEditClientError({required this.message});
}


