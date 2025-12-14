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

  Data(
      {this.accessToken,
        this.refreshToken,
        this.accessTokenExpiresAt,
        this.refreshTokenExpiresAt});

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    accessTokenExpiresAt = json['accessTokenExpiresAt'];
    refreshTokenExpiresAt = json['refreshTokenExpiresAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['accessTokenExpiresAt'] = this.accessTokenExpiresAt;
    data['refreshTokenExpiresAt'] = this.refreshTokenExpiresAt;
    return data;
  }
}
