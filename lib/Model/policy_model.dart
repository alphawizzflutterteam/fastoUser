class PolicyModel {
  String? id;
  String? title;
  String? description;
  String? convenienceFee;
  String? paybleMonth;

  PolicyModel(
      {this.id,
        this.title,
        this.description,
        this.convenienceFee,
        this.paybleMonth});

  PolicyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    convenienceFee = json['convenience_fee'];
    paybleMonth = json['payble_month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['convenience_fee'] = this.convenienceFee;
    data['payble_month'] = this.paybleMonth;
    return data;
  }
}
