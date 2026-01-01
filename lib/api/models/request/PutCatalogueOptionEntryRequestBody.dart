class PutCatalogueOptionEntryRequestBody {
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
  List<String>? synonyms;

  PutCatalogueOptionEntryRequestBody(
      {this.colourOptionIds,
        this.finishOptionIds,
        this.textureOptionIds,
        this.naturalColourOptionIds,
        this.utilityIds,
        this.originOptionIds,
        this.stateCountryOptionIds,
        this.processingNatureOptionIds,
        this.materialNaturalityOptionIds,
        this.handicraftTypeOptionIds,
        this.synonyms});

  PutCatalogueOptionEntryRequestBody.fromJson(Map<String, dynamic> json) {
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
    synonyms = json['synonyms'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['synonyms'] = this.synonyms;
    return data;
  }
}
