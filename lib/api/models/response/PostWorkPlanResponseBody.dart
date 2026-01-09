class PostWorkPlanResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostWorkPlanResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostWorkPlanResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? executiveUserId;
  String? executiveName;
  String? fromDate;
  String? toDate;
  String? status;
  String? executiveNote;
  String? adminComment;
  String? submittedAt;
  String? approvedAt;
  String? approvedByAdminUserId;
  List<Days>? days;

  Data(
      {this.id,
        this.executiveUserId,
        this.executiveName,
        this.fromDate,
        this.toDate,
        this.status,
        this.executiveNote,
        this.adminComment,
        this.submittedAt,
        this.approvedAt,
        this.approvedByAdminUserId,
        this.days});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    executiveUserId = json['executiveUserId'];
    executiveName = json['executiveName'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    status = json['status'];
    executiveNote = json['executiveNote'];
    adminComment = json['adminComment'];
    submittedAt = json['submittedAt'];
    approvedAt = json['approvedAt'];
    approvedByAdminUserId = json['approvedByAdminUserId'];
    if (json['days'] != null) {
      days = <Days>[];
      json['days'].forEach((v) {
        days!.add(new Days.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['executiveUserId'] = this.executiveUserId;
    data['executiveName'] = this.executiveName;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['status'] = this.status;
    data['executiveNote'] = this.executiveNote;
    data['adminComment'] = this.adminComment;
    data['submittedAt'] = this.submittedAt;
    data['approvedAt'] = this.approvedAt;
    data['approvedByAdminUserId'] = this.approvedByAdminUserId;
    if (this.days != null) {
      data['days'] = this.days!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Days {
  String? id;
  String? planDate;
  String? dayNote;
  List<Clients>? clients;
  List<Prospects>? prospects;

  Days({this.id, this.planDate, this.dayNote, this.clients, this.prospects});

  Days.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planDate = json['planDate'];
    dayNote = json['dayNote'];
    if (json['clients'] != null) {
      clients = <Clients>[];
      json['clients'].forEach((v) {
        clients!.add(new Clients.fromJson(v));
      });
    }
    if (json['prospects'] != null) {
      prospects = <Prospects>[];
      json['prospects'].forEach((v) {
        prospects!.add(new Prospects.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['planDate'] = this.planDate;
    data['dayNote'] = this.dayNote;
    if (this.clients != null) {
      data['clients'] = this.clients!.map((v) => v.toJson()).toList();
    }
    if (this.prospects != null) {
      data['prospects'] = this.prospects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Clients {
  String? id;
  String? clientId;
  String? clientName;
  String? addedBy;
  String ? adminNote;
  String? createdAt;

  Clients(
      {this.id,
        this.clientId,
        this.clientName,
        this.addedBy,
        this.adminNote,
        this.createdAt});

  Clients.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['clientId'];
    clientName = json['clientName'];
    addedBy = json['addedBy'];
    adminNote = json['adminNote'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientId'] = this.clientId;
    data['clientName'] = this.clientName;
    data['addedBy'] = this.addedBy;
    data['adminNote'] = this.adminNote;
    data['createdAt'] = this.createdAt;
    return data;
  }
}

class Prospects {
  String? id;
  String? prospectName;
  String? locationText;
  String? contactText;
  String? note;
  String? createdBy;
  String? createdAt;

  Prospects(
      {this.id,
        this.prospectName,
        this.locationText,
        this.contactText,
        this.note,
        this.createdBy,
        this.createdAt});

  Prospects.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    prospectName = json['prospectName'];
    locationText = json['locationText'];
    contactText = json['contactText'];
    note = json['note'];
    createdBy = json['createdBy'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['prospectName'] = this.prospectName;
    data['locationText'] = this.locationText;
    data['contactText'] = this.contactText;
    data['note'] = this.note;
    data['createdBy'] = this.createdBy;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
