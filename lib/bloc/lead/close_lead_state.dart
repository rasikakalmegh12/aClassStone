abstract class CloseLeadState {}

class CloseLeadInitial extends CloseLeadState {}

class CloseLeadLoading extends CloseLeadState {
  final bool showLoader;
  CloseLeadLoading({this.showLoader = false});
}

class CloseLeadSuccess extends CloseLeadState {
  final String message;
  CloseLeadSuccess({required this.message});
}

class CloseLeadError extends CloseLeadState {
  final String message;
  CloseLeadError({required this.message});
}

