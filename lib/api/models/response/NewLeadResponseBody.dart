class NewLeadResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  NewLeadResponseBody({this.status, this.message, this.statusCode, this.data});

  NewLeadResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? leadNo;

  Data({this.id, this.leadNo});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leadNo = json['leadNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['leadNo'] = this.leadNo;
    return data;
  }
}
