class LogoutResponseBody {
  bool? status;
  String? statusCode;
  List<dynamic>? entity;
  String? message;

  LogoutResponseBody({this.status, this.statusCode, this.entity, this.message});

  LogoutResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    // Handle entity as a dynamic list since it's an empty array in the response
    if (json['entity'] != null && json['entity'] is List) {
      entity = json['entity'] as List<dynamic>;
    } else {
      entity = [];
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['entity'] = entity ?? [];
    data['message'] = message;
    return data;
  }
}
