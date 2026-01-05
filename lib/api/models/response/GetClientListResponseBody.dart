class GetClientListResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  List<Data>? data;

  GetClientListResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetClientListResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? clientCode;
  String? clientTypeCode;
  String? firmName;
  String? city;

  Data(
      {this.id,
        this.clientCode,
        this.clientTypeCode,
        this.firmName,
        this.city});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientCode = json['clientCode'];
    clientTypeCode = json['clientTypeCode'];
    firmName = json['firmName'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientCode'] = this.clientCode;
    data['clientTypeCode'] = this.clientTypeCode;
    data['firmName'] = this.firmName;
    data['city'] = this.city;
    return data;
  }
}
