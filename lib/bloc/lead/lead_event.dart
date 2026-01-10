import 'package:apclassstone/api/models/request/PostNewLeadRequestBody.dart';

abstract class LeadEvent {}

// Post New Lead Events
class SubmitNewLead extends LeadEvent {
  final PostNewLeadRequestBody requestBody;
  final bool showLoader;

  SubmitNewLead({
    required this.requestBody,
    this.showLoader = true,
  });
}

// Get Lead List Events
class FetchLeadList extends LeadEvent {
  final int? page;
  final int? pageSize;
  final String? search;
  final bool showLoader;

  FetchLeadList({
    this.page,
    this.pageSize,
    this.search,
    this.showLoader = true,
  });
}

// Get Lead Details Events
class FetchLeadDetails extends LeadEvent {
  final String leadId;
  final bool showLoader;

  FetchLeadDetails({
    required this.leadId,
    this.showLoader = true,
  });
}

// Lead Assign Events
class AssignLead extends LeadEvent {

  final bool showLoader;

  AssignLead({

    this.showLoader = true,
  });
}

// Get Assignable Users Events
class FetchAssignableUsers extends LeadEvent {
  final bool showLoader;

  FetchAssignableUsers({
    this.showLoader = true,
  });
}

