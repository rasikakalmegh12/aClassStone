class GetCatalogueProductResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetCatalogueProductResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetCatalogueProductResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message']?.toString();
    statusCode = json['statusCode'] != null ? (json['statusCode'] as num).toInt() : null;
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
  int? page;
  int? pageSize;
  int? total;
  List<Items>? items;

  Data({this.page, this.pageSize, this.total, this.items});

  Data.fromJson(Map<String, dynamic> json) {
    page = json['page'] != null ? (json['page'] as num).toInt() : null;
    pageSize = json['pageSize'] != null ? (json['pageSize'] as num).toInt() : null;
    total = json['total'] != null ? (json['total'] as num).toInt() : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    data['total'] = this.total;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? id;
  String? productCode;
  String? name;
  int? pricePerSqft;
  String? productTypeId;
  String? productTypeName;
  String? primaryImageUrl;

  Items(
      {this.id,
        this.productCode,
        this.name,
        this.pricePerSqft,
        this.productTypeId,
        this.productTypeName,
        this.primaryImageUrl});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    productCode = json['productCode']?.toString();
    name = json['name']?.toString();
    pricePerSqft = json['pricePerSqft'] != null ? (json['pricePerSqft'] as num).toInt() : null;
    productTypeId = json['productTypeId']?.toString();
    productTypeName = json['productTypeName']?.toString();
    primaryImageUrl = json['primaryImageUrl']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productCode'] = this.productCode;
    data['name'] = this.name;
    data['pricePerSqft'] = this.pricePerSqft;
    data['productTypeId'] = this.productTypeId;
    data['productTypeName'] = this.productTypeName;
    data['primaryImageUrl'] = this.primaryImageUrl;
    return data;
  }
}
