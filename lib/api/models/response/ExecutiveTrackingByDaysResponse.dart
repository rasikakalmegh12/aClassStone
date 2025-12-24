class ExecutiveTrackingByDaysResponse {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  ExecutiveTrackingByDaysResponse(
      {this.status, this.message, this.statusCode, this.data});

  ExecutiveTrackingByDaysResponse.fromJson(Map<String, dynamic> json) {
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
  String? dateDisplay;
  List<Sessions>? sessions;
  List<Pings>? pings;
  PunchedInLocation? lastKnownLocation;
  int? totalPingCount;
  String? firstPingAt;
  String? lastPingAt;
  String? firstPingAtDisplay;
  String? lastPingAtDisplay;

  Data(
      {this.date,
        this.dateDisplay,
        this.sessions,
        this.pings,
        this.lastKnownLocation,
        this.totalPingCount,
        this.firstPingAt,
        this.lastPingAt,
        this.firstPingAtDisplay,
        this.lastPingAtDisplay});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    dateDisplay = json['dateDisplay'];
    if (json['sessions'] != null) {
      sessions = <Sessions>[];
      json['sessions'].forEach((v) {
        sessions!.add(new Sessions.fromJson(v));
      });
    }
    if (json['pings'] != null) {
      pings = <Pings>[];
      json['pings'].forEach((v) {
        pings!.add(new Pings.fromJson(v));
      });
    }
    lastKnownLocation = json['lastKnownLocation'] != null
        ? new PunchedInLocation.fromJson(json['lastKnownLocation'])
        : null;
    totalPingCount = json['totalPingCount'];
    firstPingAt = json['firstPingAt'];
    lastPingAt = json['lastPingAt'];
    firstPingAtDisplay = json['firstPingAtDisplay'];
    lastPingAtDisplay = json['lastPingAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['dateDisplay'] = this.dateDisplay;
    if (this.sessions != null) {
      data['sessions'] = this.sessions!.map((v) => v.toJson()).toList();
    }
    if (this.pings != null) {
      data['pings'] = this.pings!.map((v) => v.toJson()).toList();
    }
    if (this.lastKnownLocation != null) {
      data['lastKnownLocation'] = this.lastKnownLocation!.toJson();
    }
    data['totalPingCount'] = this.totalPingCount;
    data['firstPingAt'] = this.firstPingAt;
    data['lastPingAt'] = this.lastPingAt;
    data['firstPingAtDisplay'] = this.firstPingAtDisplay;
    data['lastPingAtDisplay'] = this.lastPingAtDisplay;
    return data;
  }
}

class Sessions {
  String? sessionId;
  String? status;
  String? punchedInAt;
  Null? punchedOutAt;
  String? punchedInAtDisplay;
  Null? punchedOutAtDisplay;
  PunchedInLocation? punchedInLocation;
  Null? punchedOutLocation;
  int? pingCount;
  Null? workMinutes;

  Sessions(
      {this.sessionId,
        this.status,
        this.punchedInAt,
        this.punchedOutAt,
        this.punchedInAtDisplay,
        this.punchedOutAtDisplay,
        this.punchedInLocation,
        this.punchedOutLocation,
        this.pingCount,
        this.workMinutes});

  Sessions.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    status = json['status'];
    punchedInAt = json['punchedInAt'];
    punchedOutAt = json['punchedOutAt'];
    punchedInAtDisplay = json['punchedInAtDisplay'];
    punchedOutAtDisplay = json['punchedOutAtDisplay'];
    punchedInLocation = json['punchedInLocation'] != null
        ? new PunchedInLocation.fromJson(json['punchedInLocation'])
        : null;
    punchedOutLocation = json['punchedOutLocation'];
    pingCount = json['pingCount'];
    workMinutes = json['workMinutes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['status'] = this.status;
    data['punchedInAt'] = this.punchedInAt;
    data['punchedOutAt'] = this.punchedOutAt;
    data['punchedInAtDisplay'] = this.punchedInAtDisplay;
    data['punchedOutAtDisplay'] = this.punchedOutAtDisplay;
    if (this.punchedInLocation != null) {
      data['punchedInLocation'] = this.punchedInLocation!.toJson();
    }
    data['punchedOutLocation'] = this.punchedOutLocation;
    data['pingCount'] = this.pingCount;
    data['workMinutes'] = this.workMinutes;
    return data;
  }
}

class PunchedInLocation {
  double? lat;
  double? lng;
  int? accuracyM;
  String? capturedAt;
  String? capturedAtDisplay;

  PunchedInLocation(
      {this.lat,
        this.lng,
        this.accuracyM,
        this.capturedAt,
        this.capturedAtDisplay});

  PunchedInLocation.fromJson(Map<String, dynamic> json) {
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

class Pings {
  String? sessionId;
  double? lat;
  double? lng;
  int? accuracyM;
  String? capturedAt;
  String? capturedAtDisplay;

  Pings(
      {this.sessionId,
        this.lat,
        this.lng,
        this.accuracyM,
        this.capturedAt,
        this.capturedAtDisplay});

  Pings.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    lat = json['lat'];
    lng = json['lng'];
    accuracyM = json['accuracyM'];
    capturedAt = json['capturedAt'];
    capturedAtDisplay = json['capturedAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['accuracyM'] = this.accuracyM;
    data['capturedAt'] = this.capturedAt;
    data['capturedAtDisplay'] = this.capturedAtDisplay;
    return data;
  }
}
