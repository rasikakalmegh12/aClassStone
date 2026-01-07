class PostClientAddRequestBody {
  String? clientTypeCode;
  String? firmName;
  String? gstn;
  String? traderName;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  InitialLocation? initialLocation;
  OwnerContact? ownerContact;

  PostClientAddRequestBody(
      {this.clientTypeCode,
        this.firmName,
        this.gstn,
        this.traderName,
        this.facebookUrl,
        this.instagramUrl,
        this.twitterUrl,
        this.initialLocation,
        this.ownerContact});

  PostClientAddRequestBody.fromJson(Map<String, dynamic> json) {
    clientTypeCode = json['clientTypeCode'];
    firmName = json['firmName'];
    gstn = json['gstn'];
    traderName = json['traderName'];
    facebookUrl = json['facebookUrl'];
    instagramUrl = json['instagramUrl'];
    twitterUrl = json['twitterUrl'];
    initialLocation = json['initialLocation'] != null
        ? new InitialLocation.fromJson(json['initialLocation'])
        : null;
    ownerContact = json['ownerContact'] != null
        ? new OwnerContact.fromJson(json['ownerContact'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientTypeCode'] = this.clientTypeCode;
    data['firmName'] = this.firmName;
    data['gstn'] = this.gstn;
    data['traderName'] = this.traderName;
    data['facebookUrl'] = this.facebookUrl;
    data['instagramUrl'] = this.instagramUrl;
    data['twitterUrl'] = this.twitterUrl;
    if (this.initialLocation != null) {
      data['initialLocation'] = this.initialLocation!.toJson();
    }
    if (this.ownerContact != null) {
      data['ownerContact'] = this.ownerContact!.toJson();
    }
    return data;
  }
}

class InitialLocation {
  String? locationName;
  String? state;
  String? city;
  double? gpsLat;
  double? gpsLng;

  InitialLocation(
      {this.locationName, this.state, this.city, this.gpsLat, this.gpsLng});

  InitialLocation.fromJson(Map<String, dynamic> json) {
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

class OwnerContact {
  String? name;
  String? phone;
  String? email;

  OwnerContact({this.name, this.phone, this.email});

  OwnerContact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
