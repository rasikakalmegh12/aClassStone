class ActiveSessionResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  ActiveSessionResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  ActiveSessionResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? sessionId;
  String? status;
  String? punchedInAt;
  Null? punchedOutAt;
  String? punchedInAtDisplay;
  Null? punchedOutAtDisplay;
  LastKnownLocation? lastKnownLocation;

  Data(
      {this.sessionId,
        this.status,
        this.punchedInAt,
        this.punchedOutAt,
        this.punchedInAtDisplay,
        this.punchedOutAtDisplay,
        this.lastKnownLocation});

  Data.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    status = json['status'];
    punchedInAt = json['punchedInAt'];
    punchedOutAt = json['punchedOutAt'];
    punchedInAtDisplay = json['punchedInAtDisplay'];
    punchedOutAtDisplay = json['punchedOutAtDisplay'];
    lastKnownLocation = json['lastKnownLocation'] != null
        ? new LastKnownLocation.fromJson(json['lastKnownLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['status'] = this.status;
    data['punchedInAt'] = this.punchedInAt;
    data['punchedOutAt'] = this.punchedOutAt;
    data['punchedInAtDisplay'] = this.punchedInAtDisplay;
    data['punchedOutAtDisplay'] = this.punchedOutAtDisplay;
    if (this.lastKnownLocation != null) {
      data['lastKnownLocation'] = this.lastKnownLocation!.toJson();
    }
    return data;
  }
}

class LastKnownLocation {
  double? lat;
  double? lng;
  int? accuracyM;
  String? capturedAt;
  String? capturedAtDisplay;

  LastKnownLocation(
      {this.lat,
        this.lng,
        this.accuracyM,
        this.capturedAt,
        this.capturedAtDisplay});

  LastKnownLocation.fromJson(Map<String, dynamic> json) {
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
