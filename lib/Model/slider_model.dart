class SliderModel {
  bool? status;
  String? message;
  List<SliderData>? data;

  SliderModel({this.status, this.message, this.data});

  SliderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SliderData>[];
      json['data'].forEach((v) {
        data!.add(new SliderData.fromJson(v));
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

class SliderData {
  String? id;
  String? image;
  String? status;
  String? url;
  String? createdAt;
  String? updatedAt;

  SliderData({this.id, this.image, this.status, this.createdAt, this.updatedAt});

  SliderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    image = json['image'];
    url = json['url'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['status'] = this.status;
    data['url'] = this.url;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
