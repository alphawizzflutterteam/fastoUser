class FavoriteLocationModel {
  bool? status;
  String? message;
  List<FavoriteLocationData>? data;

  FavoriteLocationModel({this.status, this.message, this.data});

  FavoriteLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <FavoriteLocationData>[];
      json['data'].forEach((v) {
        data!.add(new FavoriteLocationData.fromJson(v));
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

class FavoriteLocationData {
  String? id;
  String? address;
  String? latitude;
  String? longitude;
  String? type;
  String? userId;
  String? createdAt;
  String? updatedAt;

  FavoriteLocationData(
      {this.id,
        this.address,
        this.latitude,
        this.longitude,
        this.type,
        this.userId,
        this.createdAt,
        this.updatedAt});

  FavoriteLocationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    type = json['type'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['type'] = this.type;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
