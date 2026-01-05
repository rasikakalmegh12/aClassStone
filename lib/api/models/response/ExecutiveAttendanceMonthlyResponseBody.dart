class ExecutiveAttendanceMonthlyResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  List<Data>? data;

  ExecutiveAttendanceMonthlyResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  ExecutiveAttendanceMonthlyResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? date;
  String? dateDisplay;
  int? sessionCount;
  int? totalPingCount;
  String? firstPunchInAt;
  String? firstPunchInAtDisplay;
  FirstPunchInLocation? firstPunchInLocation;
  String? lastPunchOutAt;
  String? lastPunchOutAtDisplay;
  FirstPunchInLocation? lastPunchOutLocation;
  int? totalWorkMinutes;
  String? dayStatus;
  FirstPunchInLocation? lastKnownLocation;

  Data(
      {this.date,
        this.dateDisplay,
        this.sessionCount,
        this.totalPingCount,
        this.firstPunchInAt,
        this.firstPunchInAtDisplay,
        this.firstPunchInLocation,
        this.lastPunchOutAt,
        this.lastPunchOutAtDisplay,
        this.lastPunchOutLocation,
        this.totalWorkMinutes,
        this.dayStatus,
        this.lastKnownLocation});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    dateDisplay = json['dateDisplay'];
    sessionCount = json['sessionCount'];
    totalPingCount = json['totalPingCount'];
    firstPunchInAt = json['firstPunchInAt'];
    firstPunchInAtDisplay = json['firstPunchInAtDisplay'];
    firstPunchInLocation = json['firstPunchInLocation'] != null
        ? new FirstPunchInLocation.fromJson(json['firstPunchInLocation'])
        : null;
    lastPunchOutAt = json['lastPunchOutAt'];
    lastPunchOutAtDisplay = json['lastPunchOutAtDisplay'];
    lastPunchOutLocation = json['lastPunchOutLocation'] != null
        ? new FirstPunchInLocation.fromJson(json['lastPunchOutLocation'])
        : null;
    totalWorkMinutes = json['totalWorkMinutes'];
    dayStatus = json['dayStatus'];
    lastKnownLocation = json['lastKnownLocation'] != null
        ? new FirstPunchInLocation.fromJson(json['lastKnownLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['dateDisplay'] = this.dateDisplay;
    data['sessionCount'] = this.sessionCount;
    data['totalPingCount'] = this.totalPingCount;
    data['firstPunchInAt'] = this.firstPunchInAt;
    data['firstPunchInAtDisplay'] = this.firstPunchInAtDisplay;
    if (this.firstPunchInLocation != null) {
      data['firstPunchInLocation'] = this.firstPunchInLocation!.toJson();
    }
    data['lastPunchOutAt'] = this.lastPunchOutAt;
    data['lastPunchOutAtDisplay'] = this.lastPunchOutAtDisplay;
    if (this.lastPunchOutLocation != null) {
      data['lastPunchOutLocation'] = this.lastPunchOutLocation!.toJson();
    }
    data['totalWorkMinutes'] = this.totalWorkMinutes;
    data['dayStatus'] = this.dayStatus;
    if (this.lastKnownLocation != null) {
      data['lastKnownLocation'] = this.lastKnownLocation!.toJson();
    }
    return data;
  }
}

class FirstPunchInLocation {
  double? lat;
  double? lng;
  int? accuracyM;
  String? capturedAt;
  String? capturedAtDisplay;

  FirstPunchInLocation(
      {this.lat,
        this.lng,
        this.accuracyM,
        this.capturedAt,
        this.capturedAtDisplay});

  FirstPunchInLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    accuracyM = json['accuracyM'];
    capturedAt = json['capturedAt'];
    capturedAtDisplay = json['capturedAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['accuracyM'] = this.accuracyM;
    data['capturedAt'] = this.capturedAt;
    data['capturedAtDisplay'] = this.capturedAtDisplay;
    return data;
  }
}
