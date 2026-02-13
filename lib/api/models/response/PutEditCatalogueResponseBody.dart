class PutEditCatalogueResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PutEditCatalogueResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PutEditCatalogueResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? productCode;
  bool? isActive;

  Data({this.id, this.productCode, this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productCode = json['productCode'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productCode'] = this.productCode;
    data['isActive'] = this.isActive;
    return data;
  }
}
