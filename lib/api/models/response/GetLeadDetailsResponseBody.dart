class GetLeadDetailsResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  GetLeadDetailsResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetLeadDetailsResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? leadNo;
  String? clientId;
  String? executiveUserId;
  bool? isFromMom;
  String? momId;
  String? notes;
  String? deadlineDate;
  String? assignedToUserId;
  String? status;
  String? closedAt;
  String? closedByUserId;
  String? closedByName;
  String? closedRemarks;
  double? transportAmount;
  double? otherChargesAmount;
  double? taxAmount;
  double? materialsTotal;
  double? grandTotal;
  String? pricingRuleVersion;
  String? createdAt;
  List<Items>? items;

  Data(
      {this.id,
        this.leadNo,
        this.clientId,
        this.executiveUserId,
        this.isFromMom,
        this.momId,
        this.notes,
        this.deadlineDate,
        this.assignedToUserId,
        this.status,
        this.closedAt,
        this.closedByUserId,
        this.closedByName,
        this.closedRemarks,
        this.transportAmount,
        this.otherChargesAmount,
        this.taxAmount,
        this.materialsTotal,
        this.grandTotal,
        this.pricingRuleVersion,
        this.createdAt,
        this.items});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leadNo = json['leadNo'];
    clientId = json['clientId'];
    executiveUserId = json['executiveUserId'];
    isFromMom = json['isFromMom'];
    momId = json['momId'];
    notes = json['notes'];
    deadlineDate = json['deadlineDate'];
    assignedToUserId = json['assignedToUserId'];
    status = json['status'];
    closedAt = json['closedAt'];
    closedByUserId = json['closedByUserId'];
    closedByName = json['closedByName'];
    closedRemarks = json['closedRemarks'];
    transportAmount = json['transportAmount'];
    otherChargesAmount = json['otherChargesAmount'];
    taxAmount = json['taxAmount'];
    materialsTotal = json['materialsTotal'];
    grandTotal = json['grandTotal'];
    pricingRuleVersion = json['pricingRuleVersion'];
    createdAt = json['createdAt'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['leadNo'] = this.leadNo;
    data['clientId'] = this.clientId;
    data['executiveUserId'] = this.executiveUserId;
    data['isFromMom'] = this.isFromMom;
    data['momId'] = this.momId;
    data['notes'] = this.notes;
    data['deadlineDate'] = this.deadlineDate;
    data['assignedToUserId'] = this.assignedToUserId;
    data['transportAmount'] = this.transportAmount;
    data['otherChargesAmount'] = this.otherChargesAmount;
    data['taxAmount'] = this.taxAmount;
    data['materialsTotal'] = this.materialsTotal;
    data['grandTotal'] = this.grandTotal;
    data['pricingRuleVersion'] = this.pricingRuleVersion;
    data['createdAt'] = this.createdAt;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? id;
  String? productId;
  int? qtySqft;
  int? thicknessMm;
  String? selectedPriceCode;
  int? selectedRatePerSqft;
  int? baseAmount;
  int? slab1Percent;
  int? slab1Amount;
  int? slab2PerMmPercent;
  int? extraMm;
  int? slab2Amount;
  int? lineTotal;
  String? productCode;
  String? productName;
  String? productProcess;
  String? productRemarks;

  Items(
      {this.id,
        this.productId,
        this.qtySqft,
        this.thicknessMm,
        this.selectedPriceCode,
        this.selectedRatePerSqft,
        this.baseAmount,
        this.slab1Percent,
        this.slab1Amount,
        this.slab2PerMmPercent,
        this.extraMm,
        this.slab2Amount,
        this.lineTotal,
        this.productCode,
        this.productName,
        this.productProcess,
        this.productRemarks});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    qtySqft = json['qtySqft']?.toInt();
    thicknessMm = json['thicknessMm']?.toInt();
    selectedPriceCode = json['selectedPriceCode'];
    selectedRatePerSqft = json['selectedRatePerSqft']?.toInt();
    baseAmount = json['baseAmount']?.toInt();
    slab1Percent = json['slab1Percent']?.toInt();
    slab1Amount = json['slab1Amount']?.toInt();
    slab2PerMmPercent = json['slab2PerMmPercent']?.toInt();
    extraMm = json['extraMm'];
    slab2Amount = json['slab2Amount']?.toInt();
    lineTotal = json['lineTotal']?.toInt();
    productCode = json['productCode'];
    productName = json['productName'];
    productProcess = json['productProcess'];
    productRemarks = json['productRemarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['productId'] = this.productId;
    data['qtySqft'] = this.qtySqft;
    data['thicknessMm'] = this.thicknessMm;
    data['selectedPriceCode'] = this.selectedPriceCode;
    data['selectedRatePerSqft'] = this.selectedRatePerSqft;
    data['baseAmount'] = this.baseAmount;
    data['slab1Percent'] = this.slab1Percent;
    data['slab1Amount'] = this.slab1Amount;
    data['slab2PerMmPercent'] = this.slab2PerMmPercent;
    data['extraMm'] = this.extraMm;
    data['slab2Amount'] = this.slab2Amount;
    data['lineTotal'] = this.lineTotal;
    data['productCode'] = this.productCode;
    data['productName'] = this.productName;
    data['productProcess'] = this.productProcess;
    data['productRemarks'] = this.productRemarks;
    return data;
  }
}





