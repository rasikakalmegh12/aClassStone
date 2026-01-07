class GetMomIdDetailsResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetMomIdDetailsResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetMomIdDetailsResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? momId;
  String? clientId;
  String? clientCode;
  String? clientName;
  String? clientContactId;
  String? contactName;
  String? contactPhone;
  String? executiveUserId;
  String? executiveFullName;
  String? meetingType;
  String? meetingAt;
  String? meetingAtDisplay;
  int? gpsLat;
  int? gpsLng;
  int? gpsAccuracyM;
  String? detailedNotes;
  List<ChecklistItems>? checklistItems;
  List<Photos>? photos;

  Data(
      {this.id,
        this.momId,
        this.clientId,
        this.clientCode,
        this.clientName,
        this.clientContactId,
        this.contactName,
        this.contactPhone,
        this.executiveUserId,
        this.executiveFullName,
        this.meetingType,
        this.meetingAt,
        this.meetingAtDisplay,
        this.gpsLat,
        this.gpsLng,
        this.gpsAccuracyM,
        this.detailedNotes,
        this.checklistItems,
        this.photos});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    momId = json['momId'];
    clientId = json['clientId'];
    clientCode = json['clientCode'];
    clientName = json['clientName'];
    clientContactId = json['clientContactId'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    executiveUserId = json['executiveUserId'];
    executiveFullName = json['executiveFullName'];
    meetingType = json['meetingType'];
    meetingAt = json['meetingAt'];
    meetingAtDisplay = json['meetingAtDisplay'];
    gpsLat = json['gpsLat'];
    gpsLng = json['gpsLng'];
    gpsAccuracyM = json['gpsAccuracyM'];
    detailedNotes = json['detailedNotes'];
    if (json['checklistItems'] != null) {
      checklistItems = <ChecklistItems>[];
      json['checklistItems'].forEach((v) {
        checklistItems!.add(new ChecklistItems.fromJson(v));
      });
    }
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(new Photos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['momId'] = this.momId;
    data['clientId'] = this.clientId;
    data['clientCode'] = this.clientCode;
    data['clientName'] = this.clientName;
    data['clientContactId'] = this.clientContactId;
    data['contactName'] = this.contactName;
    data['contactPhone'] = this.contactPhone;
    data['executiveUserId'] = this.executiveUserId;
    data['executiveFullName'] = this.executiveFullName;
    data['meetingType'] = this.meetingType;
    data['meetingAt'] = this.meetingAt;
    data['meetingAtDisplay'] = this.meetingAtDisplay;
    data['gpsLat'] = this.gpsLat;
    data['gpsLng'] = this.gpsLng;
    data['gpsAccuracyM'] = this.gpsAccuracyM;
    data['detailedNotes'] = this.detailedNotes;
    if (this.checklistItems != null) {
      data['checklistItems'] =
          this.checklistItems!.map((v) => v.toJson()).toList();
    }
    if (this.photos != null) {
      data['photos'] = this.photos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChecklistItems {
  String? id;
  String? itemKey;
  String? notes;
  String? createdAt;
  String? createdAtDisplay;

  ChecklistItems(
      {this.id,
        this.itemKey,
        this.notes,
        this.createdAt,
        this.createdAtDisplay});

  ChecklistItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemKey = json['itemKey'];
    notes = json['notes'];
    createdAt = json['createdAt'];
    createdAtDisplay = json['createdAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['itemKey'] = this.itemKey;
    data['notes'] = this.notes;
    data['createdAt'] = this.createdAt;
    data['createdAtDisplay'] = this.createdAtDisplay;
    return data;
  }
}

class Photos {
  String? id;
  String? url;
  String? caption;
  int? sortOrder;
  String? createdAt;
  String? createdAtDisplay;

  Photos(
      {this.id,
        this.url,
        this.caption,
        this.sortOrder,
        this.createdAt,
        this.createdAtDisplay});

  Photos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    caption = json['caption'];
    sortOrder = json['sortOrder'];
    createdAt = json['createdAt'];
    createdAtDisplay = json['createdAtDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['caption'] = this.caption;
    data['sortOrder'] = this.sortOrder;
    data['createdAt'] = this.createdAt;
    data['createdAtDisplay'] = this.createdAtDisplay;
    return data;
  }
}
