class PunchInOutRequestBody {
  double? lat;
  double? lng;
  int? accuracyM;
  String? deviceId;
  String? deviceModel;
  String? capturedAt;

  PunchInOutRequestBody(
      {this.lat,
        this.lng,
        this.accuracyM,
        this.deviceId,
        this.deviceModel,
        this.capturedAt});

  PunchInOutRequestBody.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    accuracyM = json['accuracyM'];
    deviceId = json['deviceId'];
    deviceModel = json['deviceModel'];
    capturedAt = json['capturedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['accuracyM'] = this.accuracyM;
    data['deviceId'] = this.deviceId;
    data['deviceModel'] = this.deviceModel;
    data['capturedAt'] = this.capturedAt;
    return data;
  }
}
