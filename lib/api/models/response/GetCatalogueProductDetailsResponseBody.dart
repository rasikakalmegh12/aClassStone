class GetCatalogueProductDetailsResponseBody {
  GetCatalogueProductDetailsResponseBody({
    required this.status,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  final bool? status;
  final String? message;
  final int? statusCode;
  final Data? data;

  factory GetCatalogueProductDetailsResponseBody.fromJson(Map<String, dynamic> json){
    return GetCatalogueProductDetailsResponseBody(
      status: json["status"],
      message: json["message"],
      statusCode: json["statusCode"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

}

class Data {
  Data({
    required this.id,
    required this.productCode,
    required this.name,
    required this.description,
    required this.pricePerSqft,
    required this.productTypeId,
    required this.productTypeName,
    required this.colours,
    required this.finishes,
    required this.textures,
    required this.naturalColours,
    required this.utilities,
    required this.origins,
    required this.stateCountries,
    required this.processingNatures,
    required this.materialNaturalities,
    required this.handicraftTypes,
    required this.synonyms,
    required this.imageUrls,
    required this.primaryImageUrl,
  });

  final String? id;
  final String? productCode;
  final String? name;
  final String? description;
  final int? pricePerSqft;
  final String? productTypeId;
  final String? productTypeName;
  final List<Colour> colours;
  final List<Colour> finishes;
  final List<Colour> textures;
  final List<Colour> naturalColours;
  final List<Colour> utilities;
  final List<Colour> origins;
  final List<Colour> stateCountries;
  final List<Colour> processingNatures;
  final List<Colour> materialNaturalities;
  final List<Colour> handicraftTypes;
  final List<String> synonyms;
  final List<String> imageUrls;
  final String? primaryImageUrl;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["id"],
      productCode: json["productCode"],
      name: json["name"],
      description: json["description"],
      pricePerSqft: json["pricePerSqft"],
      productTypeId: json["productTypeId"],
      productTypeName: json["productTypeName"],
      colours: json["colours"] == null ? [] : List<Colour>.from(json["colours"]!.map((x) => Colour.fromJson(x))),
      finishes: json["finishes"] == null ? [] : List<Colour>.from(json["finishes"]!.map((x) => Colour.fromJson(x))),
      textures: json["textures"] == null ? [] : List<Colour>.from(json["textures"]!.map((x) => Colour.fromJson(x))),
      naturalColours: json["naturalColours"] == null ? [] : List<Colour>.from(json["naturalColours"]!.map((x) => Colour.fromJson(x))),
      utilities: json["utilities"] == null ? [] : List<Colour>.from(json["utilities"]!.map((x) => Colour.fromJson(x))),
      origins: json["origins"] == null ? [] : List<Colour>.from(json["origins"]!.map((x) => Colour.fromJson(x))),
      stateCountries: json["stateCountries"] == null ? [] : List<Colour>.from(json["stateCountries"]!.map((x) => Colour.fromJson(x))),
      processingNatures: json["processingNatures"] == null ? [] : List<Colour>.from(json["processingNatures"]!.map((x) => Colour.fromJson(x))),
      materialNaturalities: json["materialNaturalities"] == null ? [] : List<Colour>.from(json["materialNaturalities"]!.map((x) => Colour.fromJson(x))),
      handicraftTypes: json["handicraftTypes"] == null ? [] : List<Colour>.from(json["handicraftTypes"]!.map((x) => Colour.fromJson(x))),
      synonyms: json["synonyms"] == null ? [] : List<String>.from(json["synonyms"]!.map((x) => x)),
      imageUrls: json["imageUrls"] == null ? [] : List<String>.from(json["imageUrls"]!.map((x) => x)),
      primaryImageUrl: json["primaryImageUrl"],
    );
  }

}

class Colour {
  Colour({
    required this.id,
    required this.code,
    required this.name,
  });

  final String? id;
  final String? code;
  final String? name;

  factory Colour.fromJson(Map<String, dynamic> json){
    return Colour(
      id: json["id"],
      code: json["code"],
      name: json["name"],
    );
  }

}
