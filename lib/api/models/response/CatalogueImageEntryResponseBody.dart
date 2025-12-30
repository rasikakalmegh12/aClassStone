class CatalogueImageEntryResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  CatalogueImageEntryResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  CatalogueImageEntryResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? imageId;
  String? productId;
  String? url;
  bool? isPrimary;
  int? sortOrder;

  Data(
      {this.imageId, this.productId, this.url, this.isPrimary, this.sortOrder});

  Data.fromJson(Map<String, dynamic> json) {
    imageId = json['imageId'];
    productId = json['productId'];
    url = json['url'];
    isPrimary = json['isPrimary'];
    sortOrder = json['sortOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageId'] = this.imageId;
    data['productId'] = this.productId;
    data['url'] = this.url;
    data['isPrimary'] = this.isPrimary;
    data['sortOrder'] = this.sortOrder;
    return data;
  }
}
