class ChangeRoleRequestBody {
  String? role;
  String? appCode;

  ChangeRoleRequestBody({this.role, this.appCode});

  ChangeRoleRequestBody.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    appCode = json['appCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['appCode'] = appCode;
    return data;
  }
}

