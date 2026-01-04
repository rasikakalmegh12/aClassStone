class ProductEntryRequestBody {
  String? productCode;
  String? name;
  String? description;
  String? productTypeId;
  int? pricePerSqft;
  bool? isActive;
  int? sortOrder;
  int? priceSqftArchitectGradeA;
  int? priceSqftArchitectGradeB;
  int? priceSqftArchitectGradeC;
  int? priceSqftTraderGradeA;
  int? priceSqftTraderGradeB;
  int? priceSqftTraderGradeC;
  String? priceRangeId;
  String? mineId;
  String? marketingOneLiner;

  ProductEntryRequestBody(
      {this.productCode,
        this.name,
        this.description,
        this.productTypeId,
        this.pricePerSqft,
        this.isActive,
        this.sortOrder,
        this.priceSqftArchitectGradeA,
        this.priceSqftArchitectGradeB,
        this.priceSqftArchitectGradeC,
        this.priceSqftTraderGradeA,
        this.priceSqftTraderGradeB,
        this.priceSqftTraderGradeC,
        this.priceRangeId,
        this.mineId,
        this.marketingOneLiner});

  ProductEntryRequestBody.fromJson(Map<String, dynamic> json) {
    productCode = json['productCode'];
    name = json['name'];
    description = json['description'];
    productTypeId = json['productTypeId'];
    pricePerSqft = json['pricePerSqft'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    priceSqftArchitectGradeA = json['priceSqftArchitectGradeA'];
    priceSqftArchitectGradeB = json['priceSqftArchitectGradeB'];
    priceSqftArchitectGradeC = json['priceSqftArchitectGradeC'];
    priceSqftTraderGradeA = json['priceSqftTraderGradeA'];
    priceSqftTraderGradeB = json['priceSqftTraderGradeB'];
    priceSqftTraderGradeC = json['priceSqftTraderGradeC'];
    priceRangeId = json['priceRangeId'];
    mineId = json['mineId'];
    marketingOneLiner = json['marketingOneLiner'];
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
    data['priceSqftArchitectGradeA'] = this.priceSqftArchitectGradeA;
    data['priceSqftArchitectGradeB'] = this.priceSqftArchitectGradeB;
    data['priceSqftArchitectGradeC'] = this.priceSqftArchitectGradeC;
    data['priceSqftTraderGradeA'] = this.priceSqftTraderGradeA;
    data['priceSqftTraderGradeB'] = this.priceSqftTraderGradeB;
    data['priceSqftTraderGradeC'] = this.priceSqftTraderGradeC;
    data['priceRangeId'] = this.priceRangeId;
    data['mineId'] = this.mineId;
    data['marketingOneLiner'] = this.marketingOneLiner;
    return data;
  }
}
