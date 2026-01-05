class GetClientIdDetailsResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetClientIdDetailsResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetClientIdDetailsResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? clientCode;
  String? clientTypeCode;
  String? firmName;
  String? gstn;
  String? traderName;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  String? createdByUserId;
  String? createdAt;
  String? updatedAt;
  String? createdAtDisplay;
  String? updatedAtDisplay;
  List<Locations>? locations;

  Data(
      {this.id,
        this.clientCode,
        this.clientTypeCode,
        this.firmName,
        this.gstn,
        this.traderName,
        this.facebookUrl,
        this.instagramUrl,
        this.twitterUrl,
        this.createdByUserId,
        this.createdAt,
        this.updatedAt,
        this.createdAtDisplay,
        this.updatedAtDisplay,
        this.locations});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientCode = json['clientCode'];
    clientTypeCode = json['clientTypeCode'];
    firmName = json['firmName'];
    gstn = json['gstn'];
    traderName = json['traderName'];
    facebookUrl = json['facebookUrl'];
    instagramUrl = json['instagramUrl'];
    twitterUrl = json['twitterUrl'];
    createdByUserId = json['createdByUserId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdAtDisplay = json['createdAtDisplay'];
    updatedAtDisplay = json['updatedAtDisplay'];
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(new Locations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientCode'] = this.clientCode;
    data['clientTypeCode'] = this.clientTypeCode;
    data['firmName'] = this.firmName;
    data['gstn'] = this.gstn;
    data['traderName'] = this.traderName;
    data['facebookUrl'] = this.facebookUrl;
    data['instagramUrl'] = this.instagramUrl;
    data['twitterUrl'] = this.twitterUrl;
    data['createdByUserId'] = this.createdByUserId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdAtDisplay'] = this.createdAtDisplay;
    data['updatedAtDisplay'] = this.updatedAtDisplay;
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Locations {
  String? id;
  String? clientId;
  bool? isPrimary;
  String? locationName;
  String? state;
  String? city;
  double? gpsLat;
  double? gpsLng;
  List<Contacts>? contacts;

  Locations(
      {this.id,
        this.clientId,
        this.isPrimary,
        this.locationName,
        this.state,
        this.city,
        this.gpsLat,
        this.gpsLng,
        this.contacts});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['clientId'];
    isPrimary = json['isPrimary'];
    locationName = json['locationName'];
    state = json['state'];
    city = json['city'];
    gpsLat = json['gpsLat']?.toDouble();
    gpsLng = json['gpsLng']?.toDouble();
    if (json['contacts'] != null) {
      contacts = <Contacts>[];
      json['contacts'].forEach((v) {
        contacts!.add(new Contacts.fromJson(v));
      });
    }
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
    if (this.contacts != null) {
      data['contacts'] = this.contacts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Contacts {
  String? id;
  String? clientId;
  String? locationId;
  String? contactRole;
  String? name;
  String? phone;
  String? email;
  bool? isPrimary;

  Contacts(
      {this.id,
        this.clientId,
        this.locationId,
        this.contactRole,
        this.name,
        this.phone,
        this.email,
        this.isPrimary});

  Contacts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['clientId'];
    locationId = json['locationId'];
    contactRole = json['contactRole'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    isPrimary = json['isPrimary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientId'] = this.clientId;
    data['locationId'] = this.locationId;
    data['contactRole'] = this.contactRole;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['isPrimary'] = this.isPrimary;
    return data;
  }
}
