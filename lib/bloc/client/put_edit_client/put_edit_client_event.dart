import 'package:apclassstone/api/models/request/PostClientAddRequestBody.dart';

abstract class PutEditClientEvent {}

class FetchPutEditClient extends PutEditClientEvent {
  final String clientId;
  final PostClientAddRequestBody requestBody;
  final bool showLoader;

  FetchPutEditClient({
    required this.clientId,
    required this.requestBody,
    this.showLoader = false,
  });
}

