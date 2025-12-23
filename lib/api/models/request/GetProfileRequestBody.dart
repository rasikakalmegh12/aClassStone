class GetProfileRequestBody {
  String? fullName;
  String? phone;

  GetProfileRequestBody({this.fullName, this.phone});

  GetProfileRequestBody.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['phone'] = this.phone;
    return data;
  }
}
