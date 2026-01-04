class PostMinesEntryRequestBody {
  String? name;
  String? location;
  String? ownerName;
  String? contactPhone;
  String? contactEmail;
  bool? blocksAvailable;
  String? websiteUrl;
  String? instagramUrl;
  String? youtubeUrl;
  String? pinterestUrl;
  bool? isActive;

  PostMinesEntryRequestBody(
      {this.name,
        this.location,
        this.ownerName,
        this.contactPhone,
        this.contactEmail,
        this.blocksAvailable,
        this.websiteUrl,
        this.instagramUrl,
        this.youtubeUrl,
        this.pinterestUrl,
        this.isActive});

  PostMinesEntryRequestBody.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    location = json['location'];
    ownerName = json['ownerName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    blocksAvailable = json['blocksAvailable'];
    websiteUrl = json['websiteUrl'];
    instagramUrl = json['instagramUrl'];
    youtubeUrl = json['youtubeUrl'];
    pinterestUrl = json['pinterestUrl'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['location'] = this.location;
    data['ownerName'] = this.ownerName;
    data['contactPhone'] = this.contactPhone;
    data['contactEmail'] = this.contactEmail;
    data['blocksAvailable'] = this.blocksAvailable;
    data['websiteUrl'] = this.websiteUrl;
    data['instagramUrl'] = this.instagramUrl;
    data['youtubeUrl'] = this.youtubeUrl;
    data['pinterestUrl'] = this.pinterestUrl;
    data['isActive'] = this.isActive;
    return data;
  }
}
