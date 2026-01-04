class PostSearchRequestBody {
  int? page;
  int? pageSize;
  String? search;
  int? sort;
  List<String>? productTypeIds;
  List<String>? colourOptionIds;
  List<String>? finishOptionIds;
  List<String>? textureOptionIds;
  List<String>? naturalColourOptionIds;
  List<String>? utilityIds;
  List<String>? originOptionIds;
  List<String>? stateCountryOptionIds;
  List<String>? processingNatureOptionIds;
  List<String>? materialNaturalityOptionIds;
  List<String>? handicraftTypeOptionIds;
  List<String>? priceRangeIds;
  // int? minPricePerSqft;
  // int? maxPricePerSqft;

  PostSearchRequestBody(
      {this.page,
        this.pageSize,
        this.search,
        this.sort,
        this.productTypeIds,
        this.colourOptionIds,
        this.finishOptionIds,
        this.textureOptionIds,
        this.naturalColourOptionIds,
        this.utilityIds,
        this.originOptionIds,
        this.stateCountryOptionIds,
        this.processingNatureOptionIds,
        this.materialNaturalityOptionIds,
        this.handicraftTypeOptionIds,
        this.priceRangeIds,
        // this.minPricePerSqft,
        // this.maxPricePerSqft
      });

  PostSearchRequestBody.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    search = json['search'];
    sort = json['sort'];
    productTypeIds = json['productTypeIds'].cast<String>();
    colourOptionIds = json['colourOptionIds'].cast<String>();
    finishOptionIds = json['finishOptionIds'].cast<String>();
    textureOptionIds = json['textureOptionIds'].cast<String>();
    naturalColourOptionIds = json['naturalColourOptionIds'].cast<String>();
    utilityIds = json['utilityIds'].cast<String>();
    originOptionIds = json['originOptionIds'].cast<String>();
    stateCountryOptionIds = json['stateCountryOptionIds'].cast<String>();
    processingNatureOptionIds =
        json['processingNatureOptionIds'].cast<String>();
    materialNaturalityOptionIds =
        json['materialNaturalityOptionIds'].cast<String>();
    handicraftTypeOptionIds = json['handicraftTypeOptionIds'].cast<String>();
    priceRangeIds = json['priceRangeIds'].cast<String>();
    // minPricePerSqft = json['minPricePerSqft'];
    // maxPricePerSqft = json['maxPricePerSqft'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['pageSize'] = this.pageSize;
    data['search'] = this.search;
    data['sort'] = this.sort;
    data['productTypeIds'] = this.productTypeIds;
    data['colourOptionIds'] = this.colourOptionIds;
    data['finishOptionIds'] = this.finishOptionIds;
    data['textureOptionIds'] = this.textureOptionIds;
    data['naturalColourOptionIds'] = this.naturalColourOptionIds;
    data['utilityIds'] = this.utilityIds;
    data['originOptionIds'] = this.originOptionIds;
    data['stateCountryOptionIds'] = this.stateCountryOptionIds;
    data['processingNatureOptionIds'] = this.processingNatureOptionIds;
    data['materialNaturalityOptionIds'] = this.materialNaturalityOptionIds;
    data['handicraftTypeOptionIds'] = this.handicraftTypeOptionIds;
    data['priceRangeIds'] = this.priceRangeIds;
    // data['minPricePerSqft'] = this.minPricePerSqft;
    // data['maxPricePerSqft'] = this.maxPricePerSqft;
    return data;
  }
}
