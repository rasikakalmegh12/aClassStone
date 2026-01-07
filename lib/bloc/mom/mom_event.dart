// ========================= Mom Image Upload Events =========================
import 'dart:io';

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
