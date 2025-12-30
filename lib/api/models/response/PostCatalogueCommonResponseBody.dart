class PostCatalogueCommonResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostCatalogueCommonResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostCatalogueCommonResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? code;
  String? name;
  int? sortOrder;
  bool? isActive;

  Data({this.id, this.code, this.name, this.sortOrder, this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    sortOrder = json['sortOrder'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['sortOrder'] = this.sortOrder;
    data['isActive'] = this.isActive;
    return data;
  }
}
