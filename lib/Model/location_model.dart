class LocationModel {
  bool? status;
  String? message;
  List<LocationData>? data;

  LocationModel({this.status, this.message, this.data});

  LocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <LocationData>[];
      json['data'].forEach((v) {
        data!.add(new LocationData.fromJson(v));
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

class LocationData {
  String? id;
  String? adminId;
  String? location;
  String? latitude;
  String? longitude;
  String? radius;
  String? createdAt;
  String? updatedAt;

  LocationData(
      {this.id,
        this.adminId,
        this.location,
        this.latitude,
        this.longitude,
        this.radius,
        this.createdAt,
        this.updatedAt});

  LocationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adminId = json['admin_id'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['admin_id'] = this.adminId;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['radius'] = this.radius;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
