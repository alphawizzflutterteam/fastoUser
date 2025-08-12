class SupportModel {
  bool? status;
  String? message;
  List<SupportData>? data;

  SupportModel({this.status, this.message, this.data});

  SupportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SupportData>[];
      json['data'].forEach((v) {
        data!.add(new SupportData.fromJson(v));
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

class SupportData {
  String? id;
  String? driverId;
  String? userId;
  String? name;
  String? email;
  String? mobile;
  String? description;
  String? replyMessage;
  String? status;
  String? createdAt;
  String? updatedAt;

  SupportData(
      {this.id,
        this.driverId,
        this.userId,
        this.name,
        this.email,
        this.mobile,
        this.description,
        this.replyMessage,
        this.status,
        this.createdAt,
        this.updatedAt});

  SupportData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driverId = json['driver_id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    description = json['description'];
    replyMessage = json['reply_message'] ?? '';
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['driver_id'] = this.driverId;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['description'] = this.description;
    data['reply_message'] = this.replyMessage;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

