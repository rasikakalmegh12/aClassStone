class PostClientAddContactResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostClientAddContactResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostClientAddContactResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? locationId;
  String? contactRole;
  String? name;
  String? phone;
  String? email;
  bool? isPrimary;

  Data(
      {this.id,
        this.clientId,
        this.locationId,
        this.contactRole,
        this.name,
        this.phone,
        this.email,
        this.isPrimary});

  Data.fromJson(Map<String, dynamic> json) {
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
