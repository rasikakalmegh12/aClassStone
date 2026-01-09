class GetWorkPlanResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetWorkPlanResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetWorkPlanResponseBody.fromJson(Map<String, dynamic> json) {
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
  int? page;
  int? pageSize;
  int? total;
  List<Items>? items;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;

  Data(
      {this.page,
        this.pageSize,
        this.total,
        this.items,
        this.totalPages,
        this.hasNext,
        this.hasPrev});

  Data.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
    hasNext = json['hasNext'];
    hasPrev = json['hasPrev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    data['total'] = this.total;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = this.totalPages;
    data['hasNext'] = this.hasNext;
    data['hasPrev'] = this.hasPrev;
    return data;
  }
}

class Items {
  String? id;
  String? executiveUserId;
  String? executiveName;
  String? fromDate;
  String? toDate;
  String? status;
  String? submittedAt;
  String? approvedAt;
  int? totalDays;
  int? totalClients;
  int? totalProspects;

  Items(
      {this.id,
        this.executiveUserId,
        this.executiveName,
        this.fromDate,
        this.toDate,
        this.status,
        this.submittedAt,
        this.approvedAt,
        this.totalDays,
        this.totalClients,
        this.totalProspects});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    executiveUserId = json['executiveUserId'];
    executiveName = json['executiveName'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    status = json['status'];
    submittedAt = json['submittedAt'];
    approvedAt = json['approvedAt'];
    totalDays = json['totalDays'];
    totalClients = json['totalClients'];
    totalProspects = json['totalProspects'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['executiveUserId'] = this.executiveUserId;
    data['executiveName'] = this.executiveName;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['status'] = this.status;
    data['submittedAt'] = this.submittedAt;
    data['approvedAt'] = this.approvedAt;
    data['totalDays'] = this.totalDays;
    data['totalClients'] = this.totalClients;
    data['totalProspects'] = this.totalProspects;
    return data;
  }
}
