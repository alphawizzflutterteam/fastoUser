import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/Model/wallet_model.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

class WalletPage extends StatefulWidget {
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  double totalRequest = 0, totalPay = 0, totalAvailable = 0;
  double minimumBal = 0;
  bool isNetwork = false;
  bool saveStatus = true;
  bool showText = false;
  TextEditingController amount = new TextEditingController();
  TextEditingController remark = new TextEditingController();

  getSetting() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/minimum_balance"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var data = response["data"][0];
        print(data);
        minimumBal = double.parse(data['wallet_amount'].toString());
        amount.text = minimumBal.toString().split(".")[0];
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  List<PaybleList> walletList = [];

  getWallet() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      print("user id $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/get_wallet_request"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var data = response["data"];
        for (var v in data['payble_list']) {
          print(v['Note']);
          setState(() {
            walletList.add(new PaybleList.fromJson(v));
          });
        }
        // for (var v in data['payble_list']) {
        //   setState(() {
        //     paymentList.add(new RequestMoneyModel.fromJson(v));
        //   });
        // }
        print(data);
        totalRequest = double.parse(data['payble_amount'] ?? "0");
        totalAvailable = double.parse(data['wallet'] ?? "0");
        totalPay = double.parse(data['total_payble_amount'] ?? "0");
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  List<RequestMoneyModel> paymentList = [];

  bool loading = false;
  bool showWithdraw = false;

  addWallet() async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
        "amount": amount.text.contains(".")
            ? amount.text.toString().split(".")[0]
            : amount.text.toString(),
        "remark": remark.text.toString(),
        "order_id": DateTime.now().toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/wallet_request"), params);
      setState(() {
        requestMoneyLoading = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        getWallet();
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  addPayment(String orderId, RequestMoneyModel request) async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
        "amount": request.paybleAmount,
        "transaction_id": orderId.toString(),
        // "request_id": request.id,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/pay_request_amount"), params);
      setState(() {
        requestMoneyLoading = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        getWallet();
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWallet();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    //  getWithdraw();
  }

  String? tranId;

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    tranId = response.paymentId.toString();
    Fluttertoast.showToast(msg: "Payment successfully");
    addWallet();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment cancelled by user");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Razorpay? _razorpay;

  int? pricerazorpayy;
  void openCheckout(amount) async {
    double res = double.parse(amount.toString());
    pricerazorpayy = int.parse(res.toStringAsFixed(0)) * 100;
    var options = {
      'key': 'rzp_test_eWu6niIBmIdUFK',
      'amount': "$pricerazorpayy",
      'name': 'Fasto',
      'image': 'assets/images/Group 165.png',
      'description': 'Fasto',
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Future<bool> onWill() {
    Navigator.pop(context, true);
    /* Navigator.popUntil(
      context,
      ModalRoute.withName('/'),
    );*/
    /*Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SearchLocationPage()),
        (route) => false);*/

    return Future.value(true);
  }

  bool requestMoneyLoading = false;
  String requestId = "";

  Future<bool> showRequestDialog() async {
    var theme = Theme.of(context);
    amount.text = "";
    remark.text = "";
    var result = await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    "Request Amount",
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                UI.commonIconButton(
                    message: "Close",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconData: Icons.close,
                    iconColor: MyColorName.primaryDark),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EntryField(
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  controller: amount,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  label: "Amount",
                ),
                SizedBox(
                  height: 10,
                ),
                EntryField(
                  keyboardType: TextInputType.text,
                  controller: remark,
                  label: "Remark",
                ),
              ],
            ),
            actions: [
              Center(
                child: CustomButton(
                  color: MyColorName.secondary,
                  text: "Submit",
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  onTap: () async {
                    openCheckout(amount.text);
                    // if (amount.text == "") {
                    //   UI.setSnackBar("Please Enter Amount", context);
                    //   openCheckout(amount.text);
                    //   return;
                    // }
                    Navigator.pop(context, true);
                  },
                ),
              ),

              // UI.commonButton(
              //   bgColor: MyColorName.secondary,
              //     title: "Submit",
              //     loading: false,
              //     onPressed: () async {
              //       if (amount.text == "") {
              //         UI.setSnackBar(
              //             "Please Enter Amount", context);
              //         return;
              //       }
              //       Navigator.pop(context,true);
              //
              //     }),
            ],
          );
        });
    if (result == null) {
      return false;
    }
    return result;
  }

  Future<bool> showPayDialog() async {
    var theme = Theme.of(context);
    amount.text = totalRequest.toString();
    remark.text = "";
    var result = await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    "Pay Amount",
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                UI.commonIconButton(
                    message: "Close",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconData: Icons.close,
                    iconColor: MyColorName.primaryDark),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EntryField(
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  controller: amount,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  label: "Amount",
                ),
                SizedBox(
                  height: 10,
                ),
                EntryField(
                  keyboardType: TextInputType.text,
                  controller: remark,
                  label: "Remark",
                ),
              ],
            ),
            actions: [
              UI.commonButton(
                  title: "Submit",
                  loading: false,
                  onPressed: () async {
                    if (amount.text == "") {
                      UI.setSnackBar("Please Enter Amount", context);
                      return;
                    }
                    Navigator.pop(context, true);
                  }),
            ],
          );
        });
    if (result == null) {
      return false;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          title: Text(
            getTranslated(context, "WALLET") ?? "Wallet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        // drawer: AppDrawer(false),
        body: RefreshIndicator(
          onRefresh: () async {
            await getWallet();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: saveStatus
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff41C9B5).withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                      height: 73,
                                      width: 56,
                                      child:
                                          Image.asset("assets/walleticon.png")),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Current Balance",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      '\u{20B9}$totalAvailable',
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                CustomButton(
                                  onTap: () async {
                                    var result = await showRequestDialog();
                                    if (result) {
                                      setState(() {
                                        requestMoneyLoading = true;
                                      });
                                      openCheckout(amount);
                                    }
                                  },
                                  color: MyColorName.secondary,
                                  textColor: Colors.white,
                                  text: 'ADD',
                                  padding: EdgeInsets.all(1),
                                  borderRadius: BorderRadius.circular(5),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     Expanded(
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(16.0),
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               "Available Amount",
                        //               style: theme.textTheme.titleMedium,
                        //             ),
                        //             SizedBox(
                        //               height: 8,
                        //             ),
                        //             Text(
                        //               //\u{20B9}
                        //               '\u{20B9}$totalAvailable',
                        //               style: theme.textTheme.titleLarge,
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     // Expanded(
                        //     //   child: showWithdraw?Padding(
                        //     //     padding: const EdgeInsets.all(16.0),
                        //     //     child: Column(
                        //     //       crossAxisAlignment: CrossAxisAlignment.start,
                        //     //       children: [
                        //     //         Text(
                        //     //           "Total Paid Amount",
                        //     //           textAlign: TextAlign.end,
                        //     //           style: theme.textTheme.titleMedium,
                        //     //         ),
                        //     //         SizedBox(height: 8,),
                        //     //         Text(
                        //     //           //\u{20B9}
                        //     //           '\u{20B9}$totalPay',
                        //     //           textAlign: TextAlign.end,
                        //     //           style: theme.textTheme.titleLarge,
                        //     //         ),
                        //     //       ],
                        //     //     ),
                        //     //   ):Padding(
                        //     //     padding: const EdgeInsets.all(16.0),
                        //     //     child: Column(
                        //     //       crossAxisAlignment: CrossAxisAlignment.start,
                        //     //       children: [
                        //     //         Text(
                        //     //           "Requested Amount",
                        //     //           textAlign: TextAlign.end,
                        //     //           style: theme.textTheme.titleMedium,
                        //     //         ),
                        //     //         SizedBox(height: 8,),
                        //     //         Text(
                        //     //           //\u{20B9}
                        //     //           '\u{20B9}$totalRequest',
                        //     //           textAlign: TextAlign.end,
                        //     //           style: theme.textTheme.titleLarge,
                        //     //         ),
                        //     //       ],
                        //     //     ),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        // SizedBox(height: 24),
                        // TextButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => WalletPolicy()));
                        //     },
                        //     child: Text(
                        //       "Wallet Request Policy",
                        //       style: TextStyle(
                        //           decoration: TextDecoration.underline),
                        //     )),
                        // SizedBox(height: 8),
                        // Container(
                        //   width: getWidth(330),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Expanded(
                        //         child: UI.commonButton(
                        //             title: "Request Money",
                        //             bgColor: Colors.transparent,
                        //             borderColor: MyColorName.primaryLite,
                        //             fontColor: Colors.black,
                        //             loading: requestMoneyLoading,
                        //             onPressed: () async {
                        //               var result = await showRequestDialog();
                        //               if (result) {
                        //                 setState(() {
                        //                   requestMoneyLoading = true;
                        //                 });
                        //                 addWallet("");
                        //               }
                        //             }),
                        //       ),
                        //       SizedBox(
                        //         width: 10,
                        //       ),
                        //       Expanded(
                        //         child: UI.commonButton(
                        //             title: showWithdraw
                        //                 ? "Request History"
                        //                 : "Due History",
                        //             loading: false,
                        //             onPressed: () async {
                        //               setState(() {
                        //                 showWithdraw = !showWithdraw;
                        //               });
                        //             }),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // boxHeight(10),
                        /*  Container(
                      width: getWidth(330),
                      child: text(totalRequest<500?"Note-You need to add minimum \u{20B9}${minimumBal} to get booking request.":"Note-Please maintain \u{20B9}${minimumBal} minimum balance to take rides.",
                      fontSize: 10.sp,
                        fontFamily: fontMedium,
                        textColor: Colors.red
                      ),
                    ),*/
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "History",
                                  style: theme.textTheme.titleLarge!
                                      .copyWith(color: theme.hintColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        !showWithdraw
                            ? saveStatus
                                ? walletList.length > 0
                                    ? ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: walletList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) =>
                                            Container(
                                          margin: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.2))),
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              UI.rowItem(
                                                  title:
                                                      "${walletList[index].transactionId.toString()}",
                                                  fontWeight: FontWeight.w600,
                                                  content:
                                                      "\u20B9${walletList[index].amount ?? '0'}"),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              UI.rowItem(
                                                title:
                                                    "${walletList[index].createdAt}",
                                                fontWeight: FontWeight.w600,
                                                content:
                                                    "${walletList[index].sign}",
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              // UI.rowItem(
                                              //   title: "Convenience Fee",
                                              //   fontWeight: FontWeight.w600,
                                              //   content:
                                              //       "\u20B9${walletList[index].convenienceCharge ?? '0'}",
                                              // ),
                                              // SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Divider(),
                                              // SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Row(
                                              //   children: [
                                              //     Expanded(
                                              //       child: Column(
                                              //         crossAxisAlignment:
                                              //             CrossAxisAlignment
                                              //                 .start,
                                              //         children: [
                                              //           Text("Remark"),
                                              //           SizedBox(
                                              //             height: 5,
                                              //           ),
                                              //           Text(
                                              //             walletList[index]
                                              //                     .remark ??
                                              //                 "",
                                              //             style: TextStyle(
                                              //                 fontSize: 14.0,
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .w400),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //     SizedBox(
                                              //       width: 10,
                                              //     ),
                                              //     if (walletList[index]
                                              //             .status ==
                                              //         "1")
                                              //       UI.commonButton(
                                              //           title:
                                              //               "Pay \u20B9${walletList[index].paybleAmount ?? '0'}",
                                              //           loading: requestId ==
                                              //               walletList[index]
                                              //                   .id,
                                              //           // bgColor: Colors.white,
                                              //           //  fontColor: MyColorName.mainColor,
                                              //           onPressed: () async {
                                              //             RazorPayHelper
                                              //                 razorPay =
                                              //                 new RazorPayHelper(
                                              //                     walletList[index]
                                              //                             .paybleAmount ??
                                              //                         '0',
                                              //                     context,
                                              //                     (result) {
                                              //               if (result !=
                                              //                   "error") {
                                              //                 addPayment(
                                              //                     result,
                                              //                     walletList[
                                              //                         index]);
                                              //               } else {
                                              //                 setState(() {
                                              //                   requestId = "";
                                              //                 });
                                              //               }
                                              //             });
                                              //             setState(() {
                                              //               requestId =
                                              //                   walletList[index]
                                              //                           .id ??
                                              //                       '';
                                              //             });
                                              //             razorPay.init();
                                              //             /*var result = await showPayDialog();
                                              //           if(result){
                                              //
                                              //           }*/
                                              //           }),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: text(
                                            getTranslated(context,
                                                    "NO_TRANSACTION") ??
                                                "",
                                            fontFamily: fontMedium,
                                            fontSize: 12.sp,
                                            textColor: Colors.black),
                                      )
                                : Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.black))
                            // : saveStatus ? paymentList.length > 0
                            //         ? ListView.builder(
                            //             physics: NeverScrollableScrollPhysics(),
                            //             itemCount: paymentList.length,
                            //             shrinkWrap: true,
                            //             itemBuilder: (context, index) =>
                            //                 Container(
                            //               margin: EdgeInsets.all(5.0),
                            //               decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   borderRadius:
                            //                       BorderRadius.circular(8.0),
                            //                   border: Border.all(
                            //                       color: Colors.grey
                            //                           .withOpacity(0.2))),
                            //               padding: EdgeInsets.all(10),
                            //               child: Column(
                            //                 children: [
                            //                   UI.rowItem(
                            //                     title: "Paid Status",
                            //                     fontWeight: FontWeight.w600,
                            //                     color: paymentList[index]
                            //                                 .paybleStatus ==
                            //                             "0"
                            //                         ? Colors.orange
                            //                         : paymentList[index]
                            //                                     .paybleStatus ==
                            //                                 "1"
                            //                             ? Colors.green
                            //                             : Colors.red,
                            //                     content: paymentList[index]
                            //                                 .paybleStatus ==
                            //                             "0"
                            //                         ? "Pending"
                            //                         : paymentList[index]
                            //                                     .paybleStatus ==
                            //                                 "1"
                            //                             ? "Approved"
                            //                             : "Rejected",
                            //                   ),
                            //                   SizedBox(
                            //                     height: 8,
                            //                   ),
                            //                   UI.rowItem(
                            //                     title: "Last Due Date",
                            //                     fontWeight: FontWeight.w600,
                            //                     content:
                            //                         "${DateFormat("dd MMM yy").format(DateTime.parse(paymentList[index].validDate ?? '0000-00-00'))}",
                            //                   ),
                            //                   SizedBox(
                            //                     height: 8,
                            //                   ),
                            //                   UI.rowItem(
                            //                     title: "Approved Date",
                            //                     fontWeight: FontWeight.w600,
                            //                     content:
                            //                         "${DateFormat("dd MMM yy").format(DateTime.parse(paymentList[index].approvalDate ?? '0000-00-00'))}",
                            //                   ),
                            //                   SizedBox(
                            //                     height: 8,
                            //                   ),
                            //                   UI.rowItem(
                            //                     title: "Due Amount",
                            //                     fontWeight: FontWeight.w600,
                            //                     content:
                            //                         "\u20B9${paymentList[index].amount ?? '0'}",
                            //                   ),
                            //                   SizedBox(
                            //                     height: 8,
                            //                   ),
                            //                   UI.rowItem(
                            //                     title: "Convenience Fee",
                            //                     fontWeight: FontWeight.w600,
                            //                     content:
                            //                         "\u20B9${paymentList[index].convenienceCharge ?? '0'}",
                            //                   ),
                            //                   SizedBox(
                            //                     height: 5,
                            //                   ),
                            //                   Divider(),
                            //                   SizedBox(
                            //                     height: 5,
                            //                   ),
                            //                   Row(
                            //                     children: [
                            //                       Expanded(
                            //                         child: Column(
                            //                           crossAxisAlignment:
                            //                               CrossAxisAlignment
                            //                                   .start,
                            //                           children: [
                            //                             Text("Remark"),
                            //                             SizedBox(
                            //                               height: 5,
                            //                             ),
                            //                             Text(
                            //                               paymentList[index]
                            //                                       .remark ??
                            //                                   "",
                            //                               style: TextStyle(
                            //                                   fontSize: 12.0,
                            //                                   fontWeight:
                            //                                       FontWeight
                            //                                           .w400),
                            //                             ),
                            //                           ],
                            //                         ),
                            //                       ),
                            //                       SizedBox(
                            //                         width: 10,
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           )
                            //         : Center(
                            //             child: text(
                            //                 getTranslated(context,
                            //                         "NO_TRANSACTION") ??
                            //                     "",
                            //                 fontFamily: fontMedium,
                            //                 fontSize: 12.sp,
                            //                 textColor: Colors.black),
                            //           )
                            : Center(
                                child: CircularProgressIndicator(
                                    color: Colors.black))
                      ],
                    ),
                  )
                : Center(child: CircularProgressIndicator(color: Colors.black)),
          ),
        ),
      ),
    );
  }
}

class WithdrawModel {
  String id, amount, status, added_date;

  WithdrawModel(this.id, this.amount, this.status, this.added_date);
}
