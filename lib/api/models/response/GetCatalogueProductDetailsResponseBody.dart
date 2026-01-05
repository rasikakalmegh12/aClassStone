// class GetCatalogueProductDetailsResponseBody {
//   GetCatalogueProductDetailsResponseBody({
//     required this.status,
//     required this.message,
//     required this.statusCode,
//     required this.data,
//   });
//
//   final bool? status;
//   final String? message;
//   final int? statusCode;
//   final Data? data;
//
//   factory GetCatalogueProductDetailsResponseBody.fromJson(Map<String, dynamic> json){
//     return GetCatalogueProductDetailsResponseBody(
//       status: json["status"],
//       message: json["message"],
//       statusCode: json["statusCode"],
//       data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );
//   }
//
// }
//
// class Data {
//   Data({
//     required this.id,
//     required this.productCode,
//     required this.name,
//     required this.description,
//     required this.pricePerSqft,
//     required this.productTypeId,
//     required this.productTypeName,
//     this.priceSqftArchitectGradeA,
//     this.priceSqftArchitectGradeB, this.priceSqftArchitectGradeC,
//     this.priceSqftTraderGradeA, this.priceSqftTraderGradeB, this.priceSqftTraderGradeC,
//     this.priceRangeId, this.priceRangeName, this.priceRangeMinPrice, this.priceRangeMaxPrice,
//     this.marketingOneLiner, this.mineId, this.mineName, this.mineOwnerName,
//     this.mineLocation, this.mineContactPhone, this.mineContactEmail,
//     required this.colours,
//     required this.finishes,
//     required this.textures,
//     required this.naturalColours,
//     required this.utilities,
//     required this.origins,
//     required this.stateCountries,
//     required this.processingNatures,
//     required this.materialNaturalities,
//     required this.handicraftTypes,
//     required this.synonyms,
//     required this.imageUrls,
//     required this.primaryImageUrl,
//   });
//
//   final String? id;
//   final String? productCode;
//   final String? name;
//   final String? description;
//   final int? pricePerSqft;
//   final String? productTypeId;
//   final String? productTypeName;
//   final int? priceSqftArchitectGradeA;
//   final int? priceSqftArchitectGradeB;
//   final int? priceSqftArchitectGradeC;
//   final int? priceSqftTraderGradeA;
//   final int? priceSqftTraderGradeB;
//   final  int? priceSqftTraderGradeC;
//   final String? priceRangeId;
//   final String? priceRangeName;
//   final int? priceRangeMinPrice;
//   final int? priceRangeMaxPrice;
//   final String? marketingOneLiner;
//   final String? mineId;
//   final String? mineName;
//   final String? mineOwnerName;
//   final String? mineLocation;
//   final String? mineContactPhone;
//   final  String? mineContactEmail;
//   final List<Colour> colours;
//   final List<Colour> finishes;
//   final List<Colour> textures;
//   final List<Colour> naturalColours;
//   final List<Colour> utilities;
//   final List<Colour> origins;
//   final List<Colour> stateCountries;
//   final List<Colour> processingNatures;
//   final List<Colour> materialNaturalities;
//   final List<Colour> handicraftTypes;
//   final List<String> synonyms;
//   final List<String> imageUrls;
//   final String? primaryImageUrl;
//
//   factory Data.fromJson(Map<String, dynamic> json){
//     return Data(
//       id: json["id"],
//       productCode: json["productCode"],
//       name: json["name"],
//       description: json["description"],
//       pricePerSqft: json["pricePerSqft"],
//       productTypeId: json["productTypeId"],
//       productTypeName: json["productTypeName"],
//
//
//         priceSqftArchitectGradeA = json["priceSqftArchitectGradeA"],
//         priceSqftArchitectGradeB = json["priceSqftArchitectGradeB"],
//         priceSqftArchitectGradeC = json['priceSqftArchitectGradeC'],
//     priceSqftTraderGradeA = json['priceSqftTraderGradeA'],
//     priceSqftTraderGradeB = json['priceSqftTraderGradeB'],
//     priceSqftTraderGradeC = json['priceSqftTraderGradeC'],
//     priceRangeId = json['priceRangeId']?.toString(),
//     priceRangeName = json['priceRangeName']?.toString(),
//     priceRangeMinPrice = json['priceRangeMinPrice'],
//     priceRangeMaxPrice = json['priceRangeMaxPrice'],
//     marketingOneLiner = json['marketingOneLiner']?.toString(),
//     mineId = json['mineId']?.toString(),
//     mineName = json['mineName']?.toString(),
//     mineOwnerName = json['mineOwnerName']?.toString(),
//     mineLocation = json['mineLocation']?.toString(),
//     mineContactPhone = json['mineContactPhone']?.toString(),
//     mineContactEmail = json['mineContactEmail']?.toString(),
//       colours: json["colours"] == null ? [] : List<Colour>.from(json["colours"]!.map((x) => Colour.fromJson(x))),
//       finishes: json["finishes"] == null ? [] : List<Colour>.from(json["finishes"]!.map((x) => Colour.fromJson(x))),
//       textures: json["textures"] == null ? [] : List<Colour>.from(json["textures"]!.map((x) => Colour.fromJson(x))),
//       naturalColours: json["naturalColours"] == null ? [] : List<Colour>.from(json["naturalColours"]!.map((x) => Colour.fromJson(x))),
//       utilities: json["utilities"] == null ? [] : List<Colour>.from(json["utilities"]!.map((x) => Colour.fromJson(x))),
//       origins: json["origins"] == null ? [] : List<Colour>.from(json["origins"]!.map((x) => Colour.fromJson(x))),
//       stateCountries: json["stateCountries"] == null ? [] : List<Colour>.from(json["stateCountries"]!.map((x) => Colour.fromJson(x))),
//       processingNatures: json["processingNatures"] == null ? [] : List<Colour>.from(json["processingNatures"]!.map((x) => Colour.fromJson(x))),
//       materialNaturalities: json["materialNaturalities"] == null ? [] : List<Colour>.from(json["materialNaturalities"]!.map((x) => Colour.fromJson(x))),
//       handicraftTypes: json["handicraftTypes"] == null ? [] : List<Colour>.from(json["handicraftTypes"]!.map((x) => Colour.fromJson(x))),
//       synonyms: json["synonyms"] == null ? [] : List<String>.from(json["synonyms"]!.map((x) => x)),
//       imageUrls: json["imageUrls"] == null ? [] : List<String>.from(json["imageUrls"]!.map((x) => x)),
//       primaryImageUrl: json["primaryImageUrl"],
//     );
//   }
//
// }
//
// class Colour {
//   Colour({
//     required this.id,
//     required this.code,
//     required this.name,
//   });
//
//   final String? id;
//   final String? code;
//   final String? name;
//
//   factory Colour.fromJson(Map<String, dynamic> json){
//     return Colour(
//       id: json["id"],
//       code: json["code"],
//       name: json["name"],
//     );
//   }
//
// }


class GetCatalogueProductDetailsResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetCatalogueProductDetailsResponseBody({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  GetCatalogueProductDetailsResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message']?.toString();
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
  String? id;
  String? productCode;
  String? name;
  String? description;
  String? pricePerSqft;
  String? productTypeId;
  String? productTypeName;
  int? priceSqftArchitectGradeA;
  int? priceSqftArchitectGradeB;
  int? priceSqftArchitectGradeC;
  int? priceSqftTraderGradeA;
  int? priceSqftTraderGradeB;
  int? priceSqftTraderGradeC;
  String? priceRangeId;
  String? priceRangeName;
  double? priceRangeMinPrice;
  double? priceRangeMaxPrice;
  String? marketingOneLiner;
  String? mineId;
  String? mineName;
  String? mineOwnerName;
  String? mineLocation;
  String? mineContactPhone;
  String? mineContactEmail;
  List<Colours>? colours;
  List<Finishes>? finishes;
  List<Textures>? textures;
  List<NaturalColours>? naturalColours;
  List<Utilities>? utilities;
  List<Origins>? origins;
  List<StateCountries>? stateCountries;
  List<ProcessingNatures>? processingNatures;
  List<MaterialNaturalities>? materialNaturalities;
  List<HandicraftTypes>? handicraftTypes;
  List<String>? synonyms;
  List<String>? imageUrls;
  String? primaryImageUrl;

  Data({
    this.id, this.productCode, this.name, this.description, this.pricePerSqft,
    this.productTypeId, this.productTypeName, this.priceSqftArchitectGradeA,
    this.priceSqftArchitectGradeB, this.priceSqftArchitectGradeC,
    this.priceSqftTraderGradeA, this.priceSqftTraderGradeB, this.priceSqftTraderGradeC,
    this.priceRangeId, this.priceRangeName, this.priceRangeMinPrice, this.priceRangeMaxPrice,
    this.marketingOneLiner, this.mineId, this.mineName, this.mineOwnerName,
    this.mineLocation, this.mineContactPhone, this.mineContactEmail,
    this.colours, this.finishes, this.textures, this.naturalColours,
    this.utilities, this.origins, this.stateCountries, this.processingNatures,
    this.materialNaturalities, this.handicraftTypes, this.synonyms,
    this.imageUrls, this.primaryImageUrl,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    productCode = json['productCode']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    pricePerSqft = json['pricePerSqft']?.toString();
    productTypeId = json['productTypeId']?.toString();
    productTypeName = json['productTypeName']?.toString();
    priceSqftArchitectGradeA = json['priceSqftArchitectGradeA'];
    priceSqftArchitectGradeB = json['priceSqftArchitectGradeB'];
    priceSqftArchitectGradeC = json['priceSqftArchitectGradeC'];
    priceSqftTraderGradeA = json['priceSqftTraderGradeA'];
    priceSqftTraderGradeB = json['priceSqftTraderGradeB'];
    priceSqftTraderGradeC = json['priceSqftTraderGradeC'];
    priceRangeId = json['priceRangeId']?.toString();
    priceRangeName = json['priceRangeName']?.toString();
    priceRangeMinPrice = json['priceRangeMinPrice'];
    priceRangeMaxPrice = json['priceRangeMaxPrice'];
    marketingOneLiner = json['marketingOneLiner']?.toString();
    mineId = json['mineId']?.toString();
    mineName = json['mineName']?.toString();
    mineOwnerName = json['mineOwnerName']?.toString();
    mineLocation = json['mineLocation']?.toString();
    mineContactPhone = json['mineContactPhone']?.toString();
    mineContactEmail = json['mineContactEmail']?.toString();

    // Safe parsing for all lists
    colours = _parseList<Colours>(json['colours']);
    finishes = _parseList<Finishes>(json['finishes']);
    textures = _parseList<Textures>(json['textures']);
    naturalColours = _parseList<NaturalColours>(json['naturalColours']);
    utilities = _parseList<Utilities>(json['utilities']);
    origins = _parseList<Origins>(json['origins']);
    stateCountries = _parseList<StateCountries>(json['stateCountries']);
    processingNatures = _parseList<ProcessingNatures>(json['processingNatures']);
    materialNaturalities = _parseList<MaterialNaturalities>(json['materialNaturalities']);
    handicraftTypes = _parseList<HandicraftTypes>(json['handicraftTypes']);

    synonyms = json['synonyms'] != null
        ? List<String>.from(json['synonyms'] ?? [])
        : <String>[];
    imageUrls = json['imageUrls'] != null
        ? List<String>.from(json['imageUrls'] ?? [])
        : <String>[];
    primaryImageUrl = json['primaryImageUrl']?.toString();
  }

  List<T> _parseList<T>(dynamic jsonList) {
    if (jsonList == null || jsonList is! List || jsonList.isEmpty) {
      return <T>[];
    }
    return (jsonList as List).map((v) => _createFromJson<T>(v)).whereType<T>().toList();
  }

  T? _createFromJson<T>(Map<String, dynamic> json) {
    switch (T) {
      case Colours: return Colours.fromJson(json) as T?;
      case Finishes: return Finishes.fromJson(json) as T?;
      case Textures: return Textures.fromJson(json) as T?;
      case NaturalColours: return NaturalColours.fromJson(json) as T?;
      case Utilities: return Utilities.fromJson(json) as T?;
      case Origins: return Origins.fromJson(json) as T?;
      case StateCountries: return StateCountries.fromJson(json) as T?;
      case ProcessingNatures: return ProcessingNatures.fromJson(json) as T?;
      case MaterialNaturalities: return MaterialNaturalities.fromJson(json) as T?;
      case HandicraftTypes: return HandicraftTypes.fromJson(json) as T?;
      default: return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productCode'] = productCode;
    data['name'] = name;
    data['description'] = description;
    data['pricePerSqft'] = pricePerSqft;
    data['productTypeId'] = productTypeId;
    data['productTypeName'] = productTypeName;
    data['priceSqftArchitectGradeA'] = priceSqftArchitectGradeA;
    data['priceSqftArchitectGradeB'] = priceSqftArchitectGradeB;
    data['priceSqftArchitectGradeC'] = priceSqftArchitectGradeC;
    data['priceSqftTraderGradeA'] = priceSqftTraderGradeA;
    data['priceSqftTraderGradeB'] = priceSqftTraderGradeB;
    data['priceSqftTraderGradeC'] = priceSqftTraderGradeC;
    data['priceRangeId'] = priceRangeId;
    data['priceRangeName'] = priceRangeName;
    data['priceRangeMinPrice'] = priceRangeMinPrice;
    data['priceRangeMaxPrice'] = priceRangeMaxPrice;
    data['marketingOneLiner'] = marketingOneLiner;
    data['mineId'] = mineId;
    data['mineName'] = mineName;
    data['mineOwnerName'] = mineOwnerName;
    data['mineLocation'] = mineLocation;
    data['mineContactPhone'] = mineContactPhone;
    data['mineContactEmail'] = mineContactEmail;
    if (colours != null) data['colours'] = colours!.map((v) => v.toJson()).toList();
    if (finishes != null) data['finishes'] = finishes!.map((v) => v.toJson()).toList();
    if (textures != null) data['textures'] = textures!.map((v) => v.toJson()).toList();
    if (naturalColours != null) data['naturalColours'] = naturalColours!.map((v) => v.toJson()).toList();
    if (utilities != null) data['utilities'] = utilities!.map((v) => v.toJson()).toList();
    if (origins != null) data['origins'] = origins!.map((v) => v.toJson()).toList();
    if (stateCountries != null) data['stateCountries'] = stateCountries!.map((v) => v.toJson()).toList();
    if (processingNatures != null) data['processingNatures'] = processingNatures!.map((v) => v.toJson()).toList();
    if (materialNaturalities != null) data['materialNaturalities'] = materialNaturalities!.map((v) => v.toJson()).toList();
    if (handicraftTypes != null) data['handicraftTypes'] = handicraftTypes!.map((v) => v.toJson()).toList();
    data['synonyms'] = synonyms;
    data['imageUrls'] = imageUrls;
    data['primaryImageUrl'] = primaryImageUrl;
    return data;
  }
}

// All sub-classes with null-safe fromJson
class Colours {
  String? id;
  String? code;
  String? name;

  Colours({this.id, this.code, this.name});

  Colours.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class Finishes {
  String? id;
  String? code;
  String? name;

  Finishes({this.id, this.code, this.name});

  Finishes.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class Textures {
  String? id;
  String? code;
  String? name;

  Textures({this.id, this.code, this.name});

  Textures.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class NaturalColours {
  String? id;
  String? code;
  String? name;

  NaturalColours({this.id, this.code, this.name});

  NaturalColours.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class Utilities {
  String? id;
  String? code;
  String? name;

  Utilities({this.id, this.code, this.name});

  Utilities.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class Origins {
  String? id;
  String? code;
  String? name;

  Origins({this.id, this.code, this.name});

  Origins.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class StateCountries {
  String? id;
  String? code;
  String? name;

  StateCountries({this.id, this.code, this.name});

  StateCountries.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class ProcessingNatures {
  String? id;
  String? code;
  String? name;

  ProcessingNatures({this.id, this.code, this.name});

  ProcessingNatures.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class MaterialNaturalities {
  String? id;
  String? code;
  String? name;

  MaterialNaturalities({this.id, this.code, this.name});

  MaterialNaturalities.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

class HandicraftTypes {
  String? id;
  String? code;
  String? name;

  HandicraftTypes({this.id, this.code, this.name});

  HandicraftTypes.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    code = json['code']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}
