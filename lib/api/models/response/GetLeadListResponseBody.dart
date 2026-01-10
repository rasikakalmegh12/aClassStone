class GetLeadListResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetLeadListResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetLeadListResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? leadNo;
  String? clientId;
  String? clientName;
  String? executiveUserId;
  String? executiveName;
  bool? isFromMom;
  int? grandTotal;
  String? deadlineDate;
  String? assignedToUserId;
  String? assignedToName;
  String? createdAt;

  Items(
      {this.id,
        this.leadNo,
        this.clientId,
        this.clientName,
        this.executiveUserId,
        this.executiveName,
        this.isFromMom,
        this.grandTotal,
        this.deadlineDate,
        this.assignedToUserId,
        this.assignedToName,
        this.createdAt});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leadNo = json['leadNo'];
    clientId = json['clientId'];
    clientName = json['clientName'];
    executiveUserId = json['executiveUserId'];
    executiveName = json['executiveName'];
    isFromMom = json['isFromMom'];
    grandTotal = json['grandTotal'];
    deadlineDate = json['deadlineDate'];
    assignedToUserId = json['assignedToUserId'];
    assignedToName = json['assignedToName'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['leadNo'] = this.leadNo;
    data['clientId'] = this.clientId;
    data['clientName'] = this.clientName;
    data['executiveUserId'] = this.executiveUserId;
    data['executiveName'] = this.executiveName;
    data['isFromMom'] = this.isFromMom;
    data['grandTotal'] = this.grandTotal;
    data['deadlineDate'] = this.deadlineDate;
    data['assignedToUserId'] = this.assignedToUserId;
    data['assignedToName'] = this.assignedToName;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
