class PostClientAddLocationResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostClientAddLocationResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostClientAddLocationResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? clientId;
  bool? isPrimary;
  String? locationName;
  String? state;
  String? city;
  double? gpsLat;
  double? gpsLng;


  Data(
      {this.id,
        this.clientId,
        this.isPrimary,
        this.locationName,
        this.state,
        this.city,
        this.gpsLat,
        this.gpsLng,
        });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['clientId'];
    isPrimary = json['isPrimary'];
    locationName = json['locationName'];
    state = json['state'];
    city = json['city'];
    gpsLat = json['gpsLat']?.toDouble();
    gpsLng = json['gpsLng']?.toDouble();

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientId'] = this.clientId;
    data['isPrimary'] = this.isPrimary;
    data['locationName'] = this.locationName;
    data['state'] = this.state;
    data['city'] = this.city;
    data['gpsLat'] = this.gpsLat;
    data['gpsLng'] = this.gpsLng;

    return data;
  }
}
