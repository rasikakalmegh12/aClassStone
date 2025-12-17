class ApproveRequestBody {
  String? role;
  String? appCode;

  ApproveRequestBody({this.role, this.appCode});

  ApproveRequestBody.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    appCode = json['appCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role'] = this.role;
    data['appCode'] = this.appCode;
    return data;
  }
}
