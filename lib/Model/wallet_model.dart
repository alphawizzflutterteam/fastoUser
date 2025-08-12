/// status : true
/// message : "Successfull"
/// data : {"payble_list":[{"id":"76","user_id":"92","transaction_id":null,"amount":"500.00","created_at":"2024-10-16 16:21:32","modified_at":null,"sign":"+"}],"wallet_request_list":[{"id":"23","user_id":"92","amount":"100","remark":"Test","status":"0","approval_date":null,"valid_date":null,"payble_amount":"115.00","payble_status":"0","convenience_charge":"15.00","created_at":"2024-10-16 15:58:57","updated_at":null}],"payble_amount":"115.00","total_payble_amount":null,"wallet":"3703"}

class WalletModel {
  WalletModel({
    bool? status,
    String? message,
    RequestMoneyModel? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  WalletModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data =
        json['data'] != null ? RequestMoneyModel.fromJson(json['data']) : null;
  }
  bool? _status;
  String? _message;
  RequestMoneyModel? _data;
  WalletModel copyWith({
    bool? status,
    String? message,
    RequestMoneyModel? data,
  }) =>
      WalletModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  RequestMoneyModel? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

/// payble_list : [{"id":"76","user_id":"92","transaction_id":null,"amount":"500.00","created_at":"2024-10-16 16:21:32","modified_at":null,"sign":"+"}]
/// wallet_request_list : [{"id":"23","user_id":"92","amount":"100","remark":"Test","status":"0","approval_date":null,"valid_date":null,"payble_amount":"115.00","payble_status":"0","convenience_charge":"15.00","created_at":"2024-10-16 15:58:57","updated_at":null}]
/// payble_amount : "115.00"
/// total_payble_amount : null
/// wallet : "3703"

class RequestMoneyModel {
  RequestMoneyModel({
    List<PaybleList>? paybleList,
    List<WalletRequestList>? walletRequestList,
    String? paybleAmount,
    dynamic totalPaybleAmount,
    String? wallet,
  }) {
    _paybleList = paybleList;
    _walletRequestList = walletRequestList;
    _paybleAmount = paybleAmount;
    _totalPaybleAmount = totalPaybleAmount;
    _wallet = wallet;
  }

  RequestMoneyModel.fromJson(dynamic json) {
    if (json['payble_list'] != null) {
      _paybleList = [];
      json['payble_list'].forEach((v) {
        _paybleList?.add(PaybleList.fromJson(v));
      });
    }
    if (json['wallet_request_list'] != null) {
      _walletRequestList = [];
      json['wallet_request_list'].forEach((v) {
        _walletRequestList?.add(WalletRequestList.fromJson(v));
      });
    }
    _paybleAmount = json['payble_amount'];
    _totalPaybleAmount = json['total_payble_amount'];
    _wallet = json['wallet'];
  }
  List<PaybleList>? _paybleList;
  List<WalletRequestList>? _walletRequestList;
  String? _paybleAmount;
  dynamic _totalPaybleAmount;
  String? _wallet;
  RequestMoneyModel copyWith({
    List<PaybleList>? paybleList,
    List<WalletRequestList>? walletRequestList,
    String? paybleAmount,
    dynamic totalPaybleAmount,
    String? wallet,
  }) =>
      RequestMoneyModel(
        paybleList: paybleList ?? _paybleList,
        walletRequestList: walletRequestList ?? _walletRequestList,
        paybleAmount: paybleAmount ?? _paybleAmount,
        totalPaybleAmount: totalPaybleAmount ?? _totalPaybleAmount,
        wallet: wallet ?? _wallet,
      );
  List<PaybleList>? get paybleList => _paybleList;
  List<WalletRequestList>? get walletRequestList => _walletRequestList;
  String? get paybleAmount => _paybleAmount;
  dynamic get totalPaybleAmount => _totalPaybleAmount;
  String? get wallet => _wallet;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_paybleList != null) {
      map['payble_list'] = _paybleList?.map((v) => v.toJson()).toList();
    }
    if (_walletRequestList != null) {
      map['wallet_request_list'] =
          _walletRequestList?.map((v) => v.toJson()).toList();
    }
    map['payble_amount'] = _paybleAmount;
    map['total_payble_amount'] = _totalPaybleAmount;
    map['wallet'] = _wallet;
    return map;
  }
}

/// id : "23"
/// user_id : "92"
/// amount : "100"
/// remark : "Test"
/// status : "0"
/// approval_date : null
/// valid_date : null
/// payble_amount : "115.00"
/// payble_status : "0"
/// convenience_charge : "15.00"
/// created_at : "2024-10-16 15:58:57"
/// updated_at : null

class WalletRequestList {
  WalletRequestList({
    String? id,
    String? userId,
    String? amount,
    String? remark,
    String? status,
    dynamic approvalDate,
    dynamic validDate,
    String? paybleAmount,
    String? paybleStatus,
    String? convenienceCharge,
    String? createdAt,
    dynamic updatedAt,
  }) {
    _id = id;
    _userId = userId;
    _amount = amount;
    _remark = remark;
    _status = status;
    _approvalDate = approvalDate;
    _validDate = validDate;
    _paybleAmount = paybleAmount;
    _paybleStatus = paybleStatus;
    _convenienceCharge = convenienceCharge;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  WalletRequestList.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _amount = json['amount'];
    _remark = json['remark'];
    _status = json['status'];
    _approvalDate = json['approval_date'];
    _validDate = json['valid_date'];
    _paybleAmount = json['payble_amount'];
    _paybleStatus = json['payble_status'];
    _convenienceCharge = json['convenience_charge'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _id;
  String? _userId;
  String? _amount;
  String? _remark;
  String? _status;
  dynamic _approvalDate;
  dynamic _validDate;
  String? _paybleAmount;
  String? _paybleStatus;
  String? _convenienceCharge;
  String? _createdAt;
  dynamic _updatedAt;
  WalletRequestList copyWith({
    String? id,
    String? userId,
    String? amount,
    String? remark,
    String? status,
    dynamic approvalDate,
    dynamic validDate,
    String? paybleAmount,
    String? paybleStatus,
    String? convenienceCharge,
    String? createdAt,
    dynamic updatedAt,
  }) =>
      WalletRequestList(
        id: id ?? _id,
        userId: userId ?? _userId,
        amount: amount ?? _amount,
        remark: remark ?? _remark,
        status: status ?? _status,
        approvalDate: approvalDate ?? _approvalDate,
        validDate: validDate ?? _validDate,
        paybleAmount: paybleAmount ?? _paybleAmount,
        paybleStatus: paybleStatus ?? _paybleStatus,
        convenienceCharge: convenienceCharge ?? _convenienceCharge,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  String? get id => _id;
  String? get userId => _userId;
  String? get amount => _amount;
  String? get remark => _remark;
  String? get status => _status;
  dynamic get approvalDate => _approvalDate;
  dynamic get validDate => _validDate;
  String? get paybleAmount => _paybleAmount;
  String? get paybleStatus => _paybleStatus;
  String? get convenienceCharge => _convenienceCharge;
  String? get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['amount'] = _amount;
    map['remark'] = _remark;
    map['status'] = _status;
    map['approval_date'] = _approvalDate;
    map['valid_date'] = _validDate;
    map['payble_amount'] = _paybleAmount;
    map['payble_status'] = _paybleStatus;
    map['convenience_charge'] = _convenienceCharge;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}

/// id : "76"
/// user_id : "92"
/// transaction_id : null
/// amount : "500.00"
/// created_at : "2024-10-16 16:21:32"
/// modified_at : null
/// sign : "+"

class PaybleList {
  PaybleList({
    String? id,
    String? userId,
    dynamic transactionId,
    String? amount,
    String? createdAt,
    dynamic modifiedAt,
    String? sign,
  }) {
    _id = id;
    _userId = userId;
    _transactionId = transactionId;
    _amount = amount;
    _createdAt = createdAt;
    _modifiedAt = modifiedAt;
    _sign = sign;
  }

  PaybleList.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _transactionId = json['transaction_id'];
    _amount = json['amount'];
    _createdAt = json['created_at'];
    _modifiedAt = json['modified_at'];
    _sign = json['sign'];
  }
  String? _id;
  String? _userId;
  dynamic _transactionId;
  String? _amount;
  String? _createdAt;
  dynamic _modifiedAt;
  String? _sign;
  PaybleList copyWith({
    String? id,
    String? userId,
    dynamic transactionId,
    String? amount,
    String? createdAt,
    dynamic modifiedAt,
    String? sign,
  }) =>
      PaybleList(
        id: id ?? _id,
        userId: userId ?? _userId,
        transactionId: transactionId ?? _transactionId,
        amount: amount ?? _amount,
        createdAt: createdAt ?? _createdAt,
        modifiedAt: modifiedAt ?? _modifiedAt,
        sign: sign ?? _sign,
      );
  String? get id => _id;
  String? get userId => _userId;
  dynamic get transactionId => _transactionId;
  String? get amount => _amount;
  String? get createdAt => _createdAt;
  dynamic get modifiedAt => _modifiedAt;
  String? get sign => _sign;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['transaction_id'] = _transactionId;
    map['amount'] = _amount;
    map['created_at'] = _createdAt;
    map['modified_at'] = _modifiedAt;
    map['sign'] = _sign;
    return map;
  }
}
