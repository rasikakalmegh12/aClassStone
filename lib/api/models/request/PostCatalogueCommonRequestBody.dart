class PostCatalogueCommonRequestBody {
  String? code;
  String? name;
  String? type;
  int? sortOrder;
  bool? isActive;

  PostCatalogueCommonRequestBody(
      {this.code, this.name,this.type, this.sortOrder, this.isActive});

  PostCatalogueCommonRequestBody.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    type = json['type'];
    sortOrder = json['sortOrder'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['type'] = this.type;
    data['sortOrder'] = this.sortOrder;
    data['isActive'] = this.isActive;
    return data;
  }
}
