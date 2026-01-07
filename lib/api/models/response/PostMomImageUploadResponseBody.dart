class PostMomImageUploadResponseBody {
  bool? status;
  String? message;
  int? statusCode;
  Data? data;

  PostMomImageUploadResponseBody(
      {this.status, this.message, this.statusCode, this.data});

  PostMomImageUploadResponseBody.fromJson(Map<String, dynamic> json) {
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
  String? imageId;
  String? momId;
  String? url;
  String? caption;
  int? sortOrder;

  Data({this.imageId, this.momId, this.url, this.caption, this.sortOrder});

  Data.fromJson(Map<String, dynamic> json) {
    imageId = json['imageId'];
    momId = json['momId'];
    url = json['url'];
    caption = json['caption'];
    sortOrder = json['sortOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageId'] = this.imageId;
    data['momId'] = this.momId;
    data['url'] = this.url;
    data['caption'] = this.caption;
    data['sortOrder'] = this.sortOrder;
    return data;
  }
}
