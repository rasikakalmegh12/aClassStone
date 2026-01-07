class PostClientAddLocationRequestBody {
  String? locationName;
  String? state;
  String? city;
  double? gpsLat;
  double? gpsLng;

  PostClientAddLocationRequestBody(
      {this.locationName, this.state, this.city, this.gpsLat, this.gpsLng});

  PostClientAddLocationRequestBody.fromJson(Map<String, dynamic> json) {
    locationName = json['locationName'];
    state = json['state'];
    city = json['city'];
    gpsLat = json['gpsLat']?.toDouble();
    gpsLng = json['gpsLng']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationName'] = this.locationName;
    data['state'] = this.state;
    data['city'] = this.city;
    data['gpsLat'] = this.gpsLat;
    data['gpsLng'] = this.gpsLng;
    return data;
  }
}
