class RegistrationRequestBody {
  String? fullName;
  String? email;
  String? phone;
  String? password;
  String? appCode;

  RegistrationRequestBody(
      {this.fullName, this.email, this.phone, this.password, this.appCode});

  RegistrationRequestBody.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    email = json['email'];
    phone = json['phone'];
    password = json['password'];
    appCode = json['appCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['password'] = this.password;
    data['appCode'] = this.appCode;
    return data;
  }
}
