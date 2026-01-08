class PostWorkPlanRequestBody {
  String? fromDate;
  String? toDate;
  String? executiveNote;
  bool? submitNow;
  List<Days>? days;

  PostWorkPlanRequestBody(
      {this.fromDate,
        this.toDate,
        this.executiveNote,
        this.submitNow,
        this.days});

  PostWorkPlanRequestBody.fromJson(Map<String, dynamic> json) {
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    executiveNote = json['executiveNote'];
    submitNow = json['submitNow'];
    if (json['days'] != null) {
      days = <Days>[];
      json['days'].forEach((v) {
        days!.add(new Days.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['executiveNote'] = this.executiveNote;
    data['submitNow'] = this.submitNow;
    if (this.days != null) {
      data['days'] = this.days!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Days {
  String? planDate;
  String? dayNote;
  List<String>? clientIds;
  List<Prospects>? prospects;

  Days({this.planDate, this.dayNote, this.clientIds, this.prospects});

  Days.fromJson(Map<String, dynamic> json) {
    planDate = json['planDate'];
    dayNote = json['dayNote'];
    clientIds = json['clientIds'].cast<String>();
    if (json['prospects'] != null) {
      prospects = <Prospects>[];
      json['prospects'].forEach((v) {
        prospects!.add(new Prospects.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planDate'] = this.planDate;
    data['dayNote'] = this.dayNote;
    data['clientIds'] = this.clientIds;
    if (this.prospects != null) {
      data['prospects'] = this.prospects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Prospects {
  String? prospectName;
  String? locationText;
  String? contactText;
  String? note;

  Prospects(
      {this.prospectName, this.locationText, this.contactText, this.note});

  Prospects.fromJson(Map<String, dynamic> json) {
    prospectName = json['prospectName'];
    locationText = json['locationText'];
    contactText = json['contactText'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prospectName'] = this.prospectName;
    data['locationText'] = this.locationText;
    data['contactText'] = this.contactText;
    data['note'] = this.note;
    return data;
  }
}
