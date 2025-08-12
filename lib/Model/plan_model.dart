class PlanModel {
  String? id;
  String? title;
  String? description;
  String? type;
  String? image;
  String? price;
  String? status;
  String? createdAt;
  String? updatedAt;

  PlanModel(
      {this.id,
        this.title,
        this.description,
        this.type,
        this.image,
        this.price,
        this.status,
        this.createdAt,
        this.updatedAt});

  PlanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    image = json['image'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['type'] = this.type;
    data['image'] = this.image;
    data['price'] = this.price;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
class MyPlanModel {
  String? userId;
  String? startDate;
  String? endDate;
  String? id;
  String? title;
  String? description;
  String? type;
  String? userType;
  String? price;
  String? discount;
  String? createdAt;
  String? updatedAt;
  String? image;
  String? status;

  MyPlanModel(
      {this.userId,
        this.startDate,
        this.endDate,
        this.id,
        this.title,
        this.description,
        this.type,
        this.userType,
        this.price,
        this.discount,
        this.createdAt,
        this.updatedAt,
        this.image,
        this.status});

  MyPlanModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    id = json['id'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    userType = json['user_type'];
    price = json['price'];
    discount = json['discount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    image = json['image'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['type'] = this.type;
    data['user_type'] = this.userType;
    data['price'] = this.price;
    data['discount'] = this.discount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['image'] = this.image;
    data['status'] = this.status;
    return data;
  }
}
