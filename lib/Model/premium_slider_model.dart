class PremiumSliderModel {
  bool? status;
  String? message;
  List<PremiumSliderData>? data;

  PremiumSliderModel({this.status, this.message, this.data});

  PremiumSliderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PremiumSliderData>[];
      json['data'].forEach((v) {
        data!.add(new PremiumSliderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PremiumSliderData {
  String? id;
  String? title;
  String? description;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;

  PremiumSliderData(
      {this.id,
        this.title,
        this.description,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt});

  PremiumSliderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
