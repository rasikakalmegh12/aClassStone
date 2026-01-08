class PostMomEntryRequestBody {
  String? momId;
  String? clientId;
  String? clientContactId;
  String? meetingType;
  double ? gpsLat;
  double? gpsLng;
  int? gpsAccuracyM;
  String? detailedNotes;
  List<ChecklistItems>? checklistItems;
  bool? followUpRequired;

  PostMomEntryRequestBody(
      {this.momId,
        this.clientId,
        this.clientContactId,
        this.meetingType,
        this.gpsLat,
        this.gpsLng,
        this.gpsAccuracyM,
        this.detailedNotes,
        this.checklistItems,
        this.followUpRequired});

  PostMomEntryRequestBody.fromJson(Map<String, dynamic> json) {
    momId = json['momId'];
    clientId = json['clientId'];
    clientContactId = json['clientContactId'];
    meetingType = json['meetingType'];
    gpsLat = json['gpsLat']?.toDouble();
    gpsLng = json['gpsLng']?.toDouble;
    gpsAccuracyM = json['gpsAccuracyM'];
    detailedNotes = json['detailedNotes'];
    if (json['checklistItems'] != null) {
      checklistItems = <ChecklistItems>[];
      json['checklistItems'].forEach((v) {
        checklistItems!.add(new ChecklistItems.fromJson(v));
      });
    }
    followUpRequired = json['followUpRequired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['momId'] = this.momId;
    data['clientId'] = this.clientId;
    data['clientContactId'] = this.clientContactId;
    data['meetingType'] = this.meetingType;
    data['gpsLat'] = this.gpsLat;
    data['gpsLng'] = this.gpsLng;
    data['gpsAccuracyM'] = this.gpsAccuracyM;
    data['detailedNotes'] = this.detailedNotes;
    if (this.checklistItems != null) {
      data['checklistItems'] =
          this.checklistItems!.map((v) => v.toJson()).toList();
    }
    data['followUpRequired'] = this.followUpRequired;
    return data;
  }
}

class ChecklistItems {
  String? itemKey;
  String? notes;

  ChecklistItems({this.itemKey, this.notes});

  ChecklistItems.fromJson(Map<String, dynamic> json) {
    itemKey = json['itemKey'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemKey'] = this.itemKey;
    data['notes'] = this.notes;
    return data;
  }
}
