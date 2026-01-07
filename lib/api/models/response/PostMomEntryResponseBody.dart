class PostMomEntryResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostMomEntryResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostMomEntryResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? clientContactId;
  String? meetingType;
  String? meetingAt;

  Data(
      {this.id,
        this.momId,
        this.clientId,
        this.clientContactId,
        this.meetingType,
        this.meetingAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    momId = json['momId'];
    clientId = json['clientId'];
    clientContactId = json['clientContactId'];
    meetingType = json['meetingType'];
    meetingAt = json['meetingAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['momId'] = this.momId;
    data['clientId'] = this.clientId;
    data['clientContactId'] = this.clientContactId;
    data['meetingType'] = this.meetingType;
    data['meetingAt'] = this.meetingAt;
    return data;
  }
}
