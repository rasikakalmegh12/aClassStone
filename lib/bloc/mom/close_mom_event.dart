abstract class CloseMomEvent {}

class FetchCloseMom extends CloseMomEvent {
  final String momId;
  final String? remarks;
  final bool showLoader;

  FetchCloseMom({
    required this.momId,
    this.remarks,
    this.showLoader = true,
  });
}

