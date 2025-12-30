class ProductEntryRequestBody {
  String? productCode;
  String? name;
  String? description;
  String? productTypeId;
  int? pricePerSqft;
  bool? isActive;
  int? sortOrder;

  ProductEntryRequestBody(
      {this.productCode,
        this.name,
        this.description,
        this.productTypeId,
        this.pricePerSqft,
        this.isActive,
        this.sortOrder});

  ProductEntryRequestBody.fromJson(Map<String, dynamic> json) {
    productCode = json['productCode'];
    name = json['name'];
    description = json['description'];
    productTypeId = json['productTypeId'];
    pricePerSqft = json['pricePerSqft'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productCode'] = this.productCode;
    data['name'] = this.name;
    data['description'] = this.description;
    data['productTypeId'] = this.productTypeId;
    data['pricePerSqft'] = this.pricePerSqft;
    data['isActive'] = this.isActive;
    data['sortOrder'] = this.sortOrder;
    return data;
  }
}
