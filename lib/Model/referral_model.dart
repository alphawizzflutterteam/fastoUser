class ReferralModel {
  bool? status;
  String? message;
  List<ReferralData>? data;

  ReferralModel({this.status, this.message, this.data});

  ReferralModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ReferralData>[];
      json['data'].forEach((v) {
        data!.add(new ReferralData.fromJson(v));
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

class ReferralData {
  String? id;
  String? mobile;
  String? email;
  String? gender;
  String? dob;
  dynamic? anniversaryDate;
  String? password;
  dynamic? pickupadd;
  dynamic? activeId;
  dynamic? userStatus;
  dynamic? resetId;
  String? walletAmount;
  String? deviceId;
  dynamic? type;
  dynamic? rcNumber;
  dynamic? address;
  String? otp;
  String? userGcmCode;
  dynamic? otpStatus;
  String? created;
  String? modified;
  dynamic? userImage;
  String? referralCode;
  String? friendsCode;
  dynamic? latitude;
  dynamic? longnitute;
  String? username;
  String? newPassword;
  String? firstOrder;
  dynamic? startDate;
  dynamic? endDate;
  dynamic? planId;
  dynamic? emergencyName;
  dynamic? emergencyMobile;
  dynamic? emergencyGmail;

  ReferralData(
      {this.id,
        this.mobile,
        this.email,
        this.gender,
        this.dob,
        this.anniversaryDate,
        this.password,
        this.pickupadd,
        this.activeId,
        this.userStatus,
        this.resetId,
        this.walletAmount,
        this.deviceId,
        this.type,
        this.rcNumber,
        this.address,
        this.otp,
        this.userGcmCode,
        this.otpStatus,
        this.created,
        this.modified,
        this.userImage,
        this.referralCode,
        this.friendsCode,
        this.latitude,
        this.longnitute,
        this.username,
        this.newPassword,
        this.firstOrder,
        this.startDate,
        this.endDate,
        this.planId,
        this.emergencyName,
        this.emergencyMobile,
        this.emergencyGmail});

  ReferralData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mobile = json['mobile'];
    email = json['email'];
    gender = json['gender'];
    dob = json['dob'];
    anniversaryDate = json['anniversary_date'];
    password = json['password'];
    pickupadd = json['pickupadd'];
    activeId = json['active_id'];
    userStatus = json['user_status'];
    resetId = json['reset_id'];
    walletAmount = json['wallet_amount'];
    deviceId = json['device_id'];
    type = json['type'];
    rcNumber = json['rc_number'];
    address = json['address'];
    otp = json['otp'];
    userGcmCode = json['user_gcm_code'];
    otpStatus = json['otp_status'];
    created = json['created'];
    modified = json['modified'];
    userImage = json['user_image'];
    referralCode = json['referral_code'];
    friendsCode = json['friends_code'];
    latitude = json['latitude'];
    longnitute = json['longnitute'];
    username = json['username'];
    newPassword = json['new_password'];
    firstOrder = json['first_order'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    planId = json['plan_id'];
    emergencyName = json['emergency_name'];
    emergencyMobile = json['emergency_mobile'];
    emergencyGmail = json['emergency_gmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['anniversary_date'] = this.anniversaryDate;
    data['password'] = this.password;
    data['pickupadd'] = this.pickupadd;
    data['active_id'] = this.activeId;
    data['user_status'] = this.userStatus;
    data['reset_id'] = this.resetId;
    data['wallet_amount'] = this.walletAmount;
    data['device_id'] = this.deviceId;
    data['type'] = this.type;
    data['rc_number'] = this.rcNumber;
    data['address'] = this.address;
    data['otp'] = this.otp;
    data['user_gcm_code'] = this.userGcmCode;
    data['otp_status'] = this.otpStatus;
    data['created'] = this.created;
    data['modified'] = this.modified;
    data['user_image'] = this.userImage;
    data['referral_code'] = this.referralCode;
    data['friends_code'] = this.friendsCode;
    data['latitude'] = this.latitude;
    data['longnitute'] = this.longnitute;
    data['username'] = this.username;
    data['new_password'] = this.newPassword;
    data['first_order'] = this.firstOrder;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['plan_id'] = this.planId;
    data['emergency_name'] = this.emergencyName;
    data['emergency_mobile'] = this.emergencyMobile;
    data['emergency_gmail'] = this.emergencyGmail;
    return data;
  }
}
