class ProductEntryResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  ProductEntryResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  ProductEntryResponseBody.fromJson(Map<String, dynamic> json) {
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

  Data({this.id, this.productCode});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productCode = json['productCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productCode'] = this.productCode;
    return data;
  }
}
