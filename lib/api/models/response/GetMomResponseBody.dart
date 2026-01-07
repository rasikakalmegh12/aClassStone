class GetMomResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetMomResponseBody({this.status, this.message, this.statusCode, this.data});

  GetMomResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? momId;
  String? clientCode;
  String? clientName;
  String? contactName;
  String? executiveFullName;
  String? meetingType;
  String? meetingAt;
  String? meetingAtDisplay;
  String? shortNotes;

  Items(
      {this.id,
        this.momId,
        this.clientCode,
        this.clientName,
        this.contactName,
        this.executiveFullName,
        this.meetingType,
        this.meetingAt,
        this.meetingAtDisplay,
        this.shortNotes});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    momId = json['momId'];
    clientCode = json['clientCode'];
    clientName = json['clientName'];
    contactName = json['contactName'];
    executiveFullName = json['executiveFullName'];
    meetingType = json['meetingType'];
    meetingAt = json['meetingAt'];
    meetingAtDisplay = json['meetingAtDisplay'];
    shortNotes = json['shortNotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['momId'] = this.momId;
    data['clientCode'] = this.clientCode;
    data['clientName'] = this.clientName;
    data['contactName'] = this.contactName;
    data['executiveFullName'] = this.executiveFullName;
    data['meetingType'] = this.meetingType;
    data['meetingAt'] = this.meetingAt;
    data['meetingAtDisplay'] = this.meetingAtDisplay;
    data['shortNotes'] = this.shortNotes;
    return data;
  }
}

