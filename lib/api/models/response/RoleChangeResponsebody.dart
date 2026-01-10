class RoleChangeResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  RoleChangeResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  RoleChangeResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? fullName;
  String? appCode;
  String? role;

  Data({this.userId, this.fullName, this.appCode, this.role});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    fullName = json['fullName'];
    appCode = json['appCode'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['fullName'] = this.fullName;
    data['appCode'] = this.appCode;
    data['role'] = this.role;
    return data;
  }
}
