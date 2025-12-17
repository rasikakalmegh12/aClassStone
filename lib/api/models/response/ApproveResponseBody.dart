class ApproveResponseBody {
  bool? status;
  String? message;
  int? statusCode;

  ApproveResponseBody({this.status, this.message, this.statusCode});

  ApproveResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
