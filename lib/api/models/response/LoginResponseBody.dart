class LoginResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  LoginResponseBody({this.status, this.message, this.statusCode, this.data});

  LoginResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? accessToken;
  String? refreshToken;
  String? accessTokenExpiresAt;
  String? refreshTokenExpiresAt;
  String? userId;
  String? fullName;
  String? role;

  Data(
      {this.accessToken,
        this.refreshToken,
        this.accessTokenExpiresAt,
        this.refreshTokenExpiresAt,
        this.userId,
        this.fullName,
        this.role});

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    accessTokenExpiresAt = json['accessTokenExpiresAt'];
    refreshTokenExpiresAt = json['refreshTokenExpiresAt'];
    userId = json['userId'];
    fullName = json['fullName'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['accessTokenExpiresAt'] = this.accessTokenExpiresAt;
    data['refreshTokenExpiresAt'] = this.refreshTokenExpiresAt;
    data['userId'] = this.userId;
    data['fullName'] = this.fullName;
    data['role'] = this.role;
    return data;
  }
}
