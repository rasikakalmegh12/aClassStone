class PostCatalogueCommonRequestBody {
  String? code;
  String? name;
  int? sortOrder;
  bool? isActive;

  PostCatalogueCommonRequestBody(
      {this.code, this.name, this.sortOrder, this.isActive});

  PostCatalogueCommonRequestBody.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    sortOrder = json['sortOrder'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['sortOrder'] = this.sortOrder;
    data['isActive'] = this.isActive;
    return data;
  }
}
