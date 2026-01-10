class WorkPlanDecisionRequestBody {
  String? decision;
  String? adminComment;

  WorkPlanDecisionRequestBody({this.decision, this.adminComment});

  WorkPlanDecisionRequestBody.fromJson(Map<String, dynamic> json) {
    decision = json['decision'];
    adminComment = json['adminComment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['decision'] = this.decision;
    data['adminComment'] = this.adminComment;
    return data;
  }
}
