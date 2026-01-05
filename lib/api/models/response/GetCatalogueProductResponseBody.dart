class GetCatalogueProductResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetCatalogueProductResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetCatalogueProductResponseBody.fromJson(Map<String, dynamic> json) {
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
  int? page;
  int? pageSize;
  int? total;
  List<Items>? items;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;

  Data(
      {this.page,
        this.pageSize,
        this.total,
        this.items,
        this.totalPages,
        this.hasNext,
        this.hasPrev});

  Data.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
    hasNext = json['hasNext'];
    hasPrev = json['hasPrev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    data['total'] = this.total;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = this.totalPages;
    data['hasNext'] = this.hasNext;
    data['hasPrev'] = this.hasPrev;
    return data;
  }
}

class Items {
  String? id;
  String? productCode;
  String? name;
  String? productTypeId;
  String? productTypeName;
  String? priceRangeId;
  String? priceRangeName;
  int? lowestPricePerSqft;
  String? primaryImageUrl;

  Items(
      {this.id,
        this.productCode,
        this.name,
        this.productTypeId,
        this.productTypeName,
        this.priceRangeId,
        this.priceRangeName,
        this.lowestPricePerSqft,
        this.primaryImageUrl});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productCode = json['productCode'];
    name = json['name'];
    productTypeId = json['productTypeId'];
    productTypeName = json['productTypeName'];
    priceRangeId = json['priceRangeId'];
    priceRangeName = json['priceRangeName'];
    lowestPricePerSqft = json['lowestPricePerSqft'];
    primaryImageUrl = json['primaryImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productCode'] = this.productCode;
    data['name'] = this.name;
    data['productTypeId'] = this.productTypeId;
    data['productTypeName'] = this.productTypeName;
    data['priceRangeId'] = this.priceRangeId;
    data['priceRangeName'] = this.priceRangeName;
    data['lowestPricePerSqft'] = this.lowestPricePerSqft;
    data['primaryImageUrl'] = this.primaryImageUrl;
    return data;
  }
}
