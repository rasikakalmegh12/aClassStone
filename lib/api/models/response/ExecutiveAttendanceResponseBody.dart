class ExecutiveAttendanceResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  ExecutiveAttendanceResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  ExecutiveAttendanceResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? date;
  int? totalExecutives;
  int? loggedInExecutives;
  int? activeExecutives;
  int? loggedOutExecutives;
  int? notLoggedInExecutives;
  List<Items>? items;

  Data(
      {this.date,
        this.totalExecutives,
        this.loggedInExecutives,
        this.activeExecutives,
        this.loggedOutExecutives,
        this.notLoggedInExecutives,
        this.items});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    totalExecutives = json['totalExecutives'];
    loggedInExecutives = json['loggedInExecutives'];
    activeExecutives = json['activeExecutives'];
    loggedOutExecutives = json['loggedOutExecutives'];
    notLoggedInExecutives = json['notLoggedInExecutives'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['totalExecutives'] = this.totalExecutives;
    data['loggedInExecutives'] = this.loggedInExecutives;
    data['activeExecutives'] = this.activeExecutives;
    data['loggedOutExecutives'] = this.loggedOutExecutives;
    data['notLoggedInExecutives'] = this.notLoggedInExecutives;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? executiveUserId;
  String? executiveName;
  String? phone;
  String? date;
  int? sessionCount;
  String? firstPunchInAt;
  String? firstPunchInAtDisplay;
  Null? lastPunchOutAt;
  Null? lastPunchOutAtDisplay;
  String? activeSessionPunchInAt;
  String? activeSessionPunchInAtDisplay;
  bool? isActive;
  String? dayStatus;

  Items(
      {this.executiveUserId,
        this.executiveName,
        this.phone,
        this.date,
        this.sessionCount,
        this.firstPunchInAt,
        this.firstPunchInAtDisplay,
        this.lastPunchOutAt,
        this.lastPunchOutAtDisplay,
        this.activeSessionPunchInAt,
        this.activeSessionPunchInAtDisplay,
        this.isActive,
        this.dayStatus});

  Items.fromJson(Map<String, dynamic> json) {
    executiveUserId = json['executiveUserId'];
    executiveName = json['executiveName'];
    phone = json['phone'];
    date = json['date'];
    sessionCount = json['sessionCount'];
    firstPunchInAt = json['firstPunchInAt'];
    firstPunchInAtDisplay = json['firstPunchInAtDisplay'];
    lastPunchOutAt = json['lastPunchOutAt'];
    lastPunchOutAtDisplay = json['lastPunchOutAtDisplay'];
    activeSessionPunchInAt = json['activeSessionPunchInAt'];
    activeSessionPunchInAtDisplay = json['activeSessionPunchInAtDisplay'];
    isActive = json['isActive'];
    dayStatus = json['dayStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['executiveUserId'] = this.executiveUserId;
    data['executiveName'] = this.executiveName;
    data['phone'] = this.phone;
    data['date'] = this.date;
    data['sessionCount'] = this.sessionCount;
    data['firstPunchInAt'] = this.firstPunchInAt;
    data['firstPunchInAtDisplay'] = this.firstPunchInAtDisplay;
    data['lastPunchOutAt'] = this.lastPunchOutAt;
    data['lastPunchOutAtDisplay'] = this.lastPunchOutAtDisplay;
    data['activeSessionPunchInAt'] = this.activeSessionPunchInAt;
    data['activeSessionPunchInAtDisplay'] = this.activeSessionPunchInAtDisplay;
    data['isActive'] = this.isActive;
    data['dayStatus'] = this.dayStatus;
    return data;
  }
}
