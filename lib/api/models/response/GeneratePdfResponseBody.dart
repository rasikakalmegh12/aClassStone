class GeneratePdfResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GeneratePdfResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GeneratePdfResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? productId;
  String? fileName;
  String? relativeUrl;
  String? fullUrl;

  Data({this.productId, this.fileName, this.relativeUrl, this.fullUrl});

  Data.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    fileName = json['fileName'];
    relativeUrl = json['relativeUrl'];
    fullUrl = json['fullUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['fileName'] = fileName;
    data['relativeUrl'] = relativeUrl;
    data['fullUrl'] = fullUrl;
    return data;
  }
}

