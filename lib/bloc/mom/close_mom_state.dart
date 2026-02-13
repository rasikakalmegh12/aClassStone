abstract class CloseMomState {}

class CloseMomInitial extends CloseMomState {}

class CloseMomLoading extends CloseMomState {
  final bool showLoader;
  CloseMomLoading({this.showLoader = false});
}

class CloseMomSuccess extends CloseMomState {
  final String message;
  CloseMomSuccess({required this.message});
}

class CloseMomError extends CloseMomState {
  final String message;
  CloseMomError({required this.message});
}
