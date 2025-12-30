class GetStateCountriesResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  List<Data>? data;

  GetStateCountriesResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  GetStateCountriesResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? code;
  String? name;
  String? type;
  int? sortOrder;
  bool? isActive;

  Data(
      {this.id,
        this.code,
        this.name,
        this.type,
        this.sortOrder,
        this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    type = json['type'];
    sortOrder = json['sortOrder'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['type'] = this.type;
    data['sortOrder'] = this.sortOrder;
    data['isActive'] = this.isActive;
    return data;
  }
}
