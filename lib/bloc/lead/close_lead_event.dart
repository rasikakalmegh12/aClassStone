abstract class CloseLeadEvent {}

class FetchCloseLead extends CloseLeadEvent {
  final String leadId;
  final String? notes; // Optional notes when closing the lead
  final bool showLoader;

  FetchCloseLead({
    required this.leadId,
    this.notes,
    this.showLoader = true,
  });
}

