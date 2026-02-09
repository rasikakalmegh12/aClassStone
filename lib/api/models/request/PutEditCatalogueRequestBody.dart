class PutEditCatalogueRequestBody {
  String? name;
  String? description;
  String? productTypeId;
  String? priceRangeId;
  String? mineId;
  bool? isActive;
  int? sortOrder;
  int? priceSqftArchitectGradeA;
  int? priceSqftArchitectGradeB;
  int? priceSqftArchitectGradeC;
  int? priceSqftTraderGradeA;
  int? priceSqftTraderGradeB;
  int? priceSqftTraderGradeC;
  String? marketingOneLiner;

  PutEditCatalogueRequestBody(
      {this.name,
        this.description,
        this.productTypeId,
        this.priceRangeId,
        this.mineId,
        this.isActive,
        this.sortOrder,
        this.priceSqftArchitectGradeA,
        this.priceSqftArchitectGradeB,
        this.priceSqftArchitectGradeC,
        this.priceSqftTraderGradeA,
        this.priceSqftTraderGradeB,
        this.priceSqftTraderGradeC,
        this.marketingOneLiner});

  PutEditCatalogueRequestBody.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    productTypeId = json['productTypeId'];
    priceRangeId = json['priceRangeId'];
    mineId = json['mineId'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    priceSqftArchitectGradeA = json['priceSqftArchitectGradeA'];
    priceSqftArchitectGradeB = json['priceSqftArchitectGradeB'];
    priceSqftArchitectGradeC = json['priceSqftArchitectGradeC'];
    priceSqftTraderGradeA = json['priceSqftTraderGradeA'];
    priceSqftTraderGradeB = json['priceSqftTraderGradeB'];
    priceSqftTraderGradeC = json['priceSqftTraderGradeC'];
    marketingOneLiner = json['marketingOneLiner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['productTypeId'] = this.productTypeId;
    data['priceRangeId'] = this.priceRangeId;
    data['mineId'] = this.mineId;
    data['isActive'] = this.isActive;
    data['sortOrder'] = this.sortOrder;
    data['priceSqftArchitectGradeA'] = this.priceSqftArchitectGradeA;
    data['priceSqftArchitectGradeB'] = this.priceSqftArchitectGradeB;
    data['priceSqftArchitectGradeC'] = this.priceSqftArchitectGradeC;
    data['priceSqftTraderGradeA'] = this.priceSqftTraderGradeA;
    data['priceSqftTraderGradeB'] = this.priceSqftTraderGradeB;
    data['priceSqftTraderGradeC'] = this.priceSqftTraderGradeC;
    data['marketingOneLiner'] = this.marketingOneLiner;
    return data;
  }
}
