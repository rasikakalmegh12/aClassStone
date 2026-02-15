class PostNewLeadRequestBody {
  String? clientId;
  String? momId;
  String? notes;
  String? deadlineDate;
  String? assignedToUserId;
  int? transportAmount;
  int? otherChargesAmount;
  int? taxAmount;
  int? materialsTotal;
  int? grandTotal;
  String? pricingRuleVersion;
  List<Items>? items;

  PostNewLeadRequestBody(
      {this.clientId,
        this.momId,
        this.notes,
        this.deadlineDate,
        this.assignedToUserId,
        this.transportAmount,
        this.otherChargesAmount,
        this.taxAmount,
        this.materialsTotal,
        this.grandTotal,
        this.pricingRuleVersion,
        this.items});

  PostNewLeadRequestBody.fromJson(Map<String, dynamic> json) {
    clientId = json['clientId'];
    momId = json['momId'];
    notes = json['notes'];
    deadlineDate = json['deadlineDate'];
    assignedToUserId = json['assignedToUserId'];
    transportAmount = json['transportAmount'];
    otherChargesAmount = json['otherChargesAmount'];
    taxAmount = json['taxAmount'];
    materialsTotal = json['materialsTotal'];
    grandTotal = json['grandTotal'];
    pricingRuleVersion = json['pricingRuleVersion'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientId'] = this.clientId;
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
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
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
  int? extraChargeAmount;
  String? productCode;
  String? productName;
  String? productProcess;
  String? productRemarks;

  Items(
      {this.productId,
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
        this.extraChargeAmount,
        this.productCode,
        this.productName,
        this.productProcess,
        this.productRemarks});

  Items.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    qtySqft = json['qtySqft'];
    thicknessMm = json['thicknessMm'];
    selectedPriceCode = json['selectedPriceCode'];
    selectedRatePerSqft = json['selectedRatePerSqft'];
    baseAmount = json['baseAmount'];
    slab1Percent = json['slab1Percent'];
    slab1Amount = json['slab1Amount'];
    slab2PerMmPercent = json['slab2PerMmPercent'];
    extraMm = json['extraMm'];
    slab2Amount = json['slab2Amount'];
    lineTotal = json['lineTotal'];
    extraChargeAmount = json['extraChargeAmount'];
    productCode = json['productCode'];
    productName = json['productName'];
    productProcess = json['productProcess'];
    productRemarks = json['productRemarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['extraChargeAmount'] = this.extraChargeAmount;
    data['productCode'] = this.productCode;
    data['productName'] = this.productName;
    data['productProcess'] = this.productProcess;
    data['productRemarks'] = this.productRemarks;
    return data;
  }
}
