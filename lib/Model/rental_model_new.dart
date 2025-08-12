class RentalModel {
  String? id;
  String? carCategories;
  String? hours;
  String? fixedRate;
  String? ratePerHour;
  String? cartype;
  String? status;
  String? cancellationCharges;
  String? ratePerKm;
  String? taxes;
  List<HoursData>? hoursData;
  String? adminCommission;
  String? carTypeId;
  String? carImage;
  String? carModel;
  String? cabId;
  String? carName;
  int? selectedIndex;
  RentalModel(
      {this.id,
      this.carCategories,
      this.selectedIndex,
      this.hours,
      this.fixedRate,
      this.ratePerHour,
      this.cartype,
      this.status,
      this.cancellationCharges,
      this.ratePerKm,
      this.taxes,
      this.hoursData,
      this.adminCommission,
      this.carTypeId,
      this.carImage,
      this.carModel,
      this.cabId,
      this.carName});

  RentalModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    carCategories = json['car_categories'];
    hours = json['hours'];
    selectedIndex = 0;
    fixedRate = json['fixed_rate'];
    ratePerHour = json['rate_per_hour'];
    cartype = json['cartype'];
    status = json['status'];
    cancellationCharges = json['cancellation_charges'];
    ratePerKm = json['rate_per_km'];
    taxes = json['taxes'];
    if (json['hours_data'] != String) {
      hoursData = <HoursData>[];
      json['hours_data'].forEach((v) {
        hoursData!.add(new HoursData.fromJson(v));
      });
    }
    adminCommission = json['admin_commission'];
    carTypeId = json['car_type_id'];
    carImage = json['car_image'];
    carModel = json['car_model'];
    cabId = json['cab_id'];
    carName = json['car_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['car_categories'] = this.carCategories;
    data['hours'] = this.hours;
    data['fixed_rate'] = this.fixedRate;
    data['rate_per_hour'] = this.ratePerHour;
    data['cartype'] = this.cartype;
    data['status'] = this.status;
    data['cancellation_charges'] = this.cancellationCharges;
    data['rate_per_km'] = this.ratePerKm;
    data['taxes'] = this.taxes;
    if (this.hoursData != String) {
      data['hours_data'] = this.hoursData!.map((v) => v.toJson()).toList();
    }
    data['admin_commission'] = this.adminCommission;
    data['car_type_id'] = this.carTypeId;
    data['car_image'] = this.carImage;
    data['car_model'] = this.carModel;
    data['cab_id'] = this.cabId;
    data['car_name'] = this.carName;
    return data;
  }
}

class HoursData {
  String? hours;
  String? fixedAmount;
  String? fixedKm;

  HoursData({this.hours, this.fixedAmount, this.fixedKm});

  HoursData.fromJson(Map<String, dynamic> json) {
    hours = json['hours'];
    fixedAmount = json['fixed_amount'];
    fixedKm = json['fixed_km'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hours'] = this.hours;
    data['fixed_amount'] = this.fixedAmount;
    data['fixed_km'] = this.fixedKm;
    return data;
  }
}
