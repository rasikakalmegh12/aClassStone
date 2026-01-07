class PostClientAddContactRequestBody {
  String? contactRole;
  String? name;
  String? phone;
  String? email;

  PostClientAddContactRequestBody(
      {this.contactRole, this.name, this.phone, this.email});

  PostClientAddContactRequestBody.fromJson(Map<String, dynamic> json) {
    contactRole = json['contactRole'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contactRole'] = this.contactRole;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
