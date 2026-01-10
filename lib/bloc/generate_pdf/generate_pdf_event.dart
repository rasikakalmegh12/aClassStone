
abstract class GeneratePdfEvent {}

class GeneratePdfForProduct extends GeneratePdfEvent {
  final String productId;
  final bool showLoader;

  GeneratePdfForProduct({
    required this.productId,
    this.showLoader = true,
  });
}

