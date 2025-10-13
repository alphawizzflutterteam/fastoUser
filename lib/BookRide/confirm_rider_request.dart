import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';

import '../Model/driver_model.dart';
import '../Model/promo_code.dart';
import '../Model/rides_model.dart';
import '../utils/ApiBaseHelper.dart';
import '../utils/Session.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/new_utils/ui.dart';
import '../utils/widget.dart';
import 'finding_ride_page.dart';

class ConfirmRiderRequest extends StatefulWidget {
  LatLng source, destination;
  double gst = 0.0;
  double surge = 0.0;
  List<RidesModel> rideList = [];
  List<PromoModel> promoList = [];
  List<DriverModel> driverList = [];
  int currentCar = 0;
  String surgePer = '0';
  String type;
  String paymentType = "Cash";
  String promoDiscount = "0";
  String pickAddress;
  String dropAddress;
  String returnDate;
  String shareType;
  String time;
  double? partPayment;
  DateTime? bookingDate;
  int? bookingId;

  String? vendorId,
      vehicleId,
      unitPrice,
      tollTax,
      parking,
      stateCharge,
      nightCharge;
  ConfirmRiderRequest({
    required this.gst,
    required this.surge,
    required this.rideList,
    required this.currentCar,
    required this.surgePer,
    required this.type,
    required this.paymentType,
    required this.promoDiscount,
    required this.pickAddress,
    this.partPayment,
    required this.dropAddress,
    required this.promoList,
    required this.vendorId,
    required this.vehicleId,
    required this.unitPrice,
    required this.tollTax,
    required this.parking,
    required this.stateCharge,
    required this.nightCharge,
    required this.bookingDate,
    required this.source,
    required this.destination,
    required this.driverList,
    required this.bookingId,
    required this.returnDate,
    required this.shareType,
    required this.time,
  });

  @override
  State<ConfirmRiderRequest> createState() => _ConfirmRiderRequestState();
}

class _ConfirmRiderRequestState extends State<ConfirmRiderRequest> {
  TextEditingController promoCon = new TextEditingController();

  bool isSelectedCoin = false;
  double myAmount = 0;
  String _paymentMethod = "Cash";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("inthis request ${widget.rideList.length}");
    getPromo();
  }

  String? tranId;

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    tranId = response.paymentId.toString();
    Fluttertoast.showToast(msg: "Payment successfully");
    addScheduleRides();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment cancelled by user");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Razorpay? _razorpay;

  int? pricerazorpayy;
  void openCheckout(amount) async {
    print("razorpay");
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

  String promoDiscount = "0";

  String minRideAmount = '';
  getJoiningBonus() async {
    try {
      setState(() {
        driveStatus = true;
      });
      // Map params = {
      //   "lat": widget.source.latitude.toString(),
      //   "lang": widget.source.longitude.toString(),
      // };
      https: //productsalphawizz.com/taxi/api/Payment/get_promo_code
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "Payment/joining_bonus_user"),
      );

      if (response['status']) {
        minRideAmount = response['data']['min_booking'];
        String promoAmount = response['data']['amount'];
        print("this is joining bonus amount $minRideAmount and $promoAmount");
        setState(() {
          driveStatus = false;
        });
        if (isFirstUser == "0") {
          if (double.parse(widget.rideList[widget.currentCar].intailrate) >
              double.parse(minRideAmount)) {
            setState(() {
              promoDiscount = promoAmount;
            });
          }
        }
        print("this is promoDiscount $promoDiscount");
      } else {
        setState(() {
          driveStatus = false;
        });
        //UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        driveStatus = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    myAmount = (
        // surge + gst +
        double.parse(widget.rideList[widget.currentCar].rate_per_km) -
            double.parse(promoDiscount) -
            (isSelectedCoin ? double.parse(points.toString()) : 0));
    widget.surge = 0;
    widget.gst = 0;
    if (widget.rideList[widget.currentCar].gst != null &&
        widget.rideList[widget.currentCar].gst != "") {
      widget.gst = ((double.parse(widget.rideList[widget.currentCar].gst) *
                  double.parse(widget.rideList[widget.currentCar].intailrate)) /
              100)
          .roundToDouble();
    }
    // if(isFirstUser != "1"){
    // }
    if (widget.type != "schedule" &&
        !widget.rideList[widget.currentCar].serge.contains("Not") &&
        widget.rideList[widget.currentCar].surge_charge.length > 0) {
      if (widget.rideList[widget.currentCar].surge_charge[0]['time_on_off']
              .toString() !=
          "CLOSED") {
        widget.surge = ((double.parse(widget
                        .rideList[widget.currentCar].surge_charge[0]['amount']
                        .toString()) *
                    (double.parse(
                            widget.rideList[widget.currentCar].intailrate) +
                        widget.gst)) /
                100)
            .roundToDouble();
        widget.surgePer = widget
            .rideList[widget.currentCar].surge_charge[0]['amount']
            .toString();
      } else {
        widget.surge = 0;
      }
    }
    print(widget.gst);
    print(widget.surge);

    if (widget.paymentType == "Wallet" &&
        walletAmount <
            widget.surge +
                widget.gst +
                double.parse(widget.rideList[widget.currentCar].intailrate)) {
      UI.setSnackBar("Insufficient Balance", context);
      // return;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
          'Confirm Request',
          style: TextStyle(
            fontSize: 19,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MyColorName.greyBorder)),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: widget.rideList[widget.currentCar].cartype !=
                    //                 "Auto"
                    //             ? Image.network(
                    //                 widget.rideList[widget.currentCar].image,
                    //                 width: 80,
                    //               )
                    //             : Image.asset(
                    //                 widget.rideList[widget.currentCar]
                    //                                 .cartype !=
                    //                             "" &&
                    //                         widget.rideList[widget.currentCar]
                    //                                 .cartype !=
                    //                             "Auto"
                    //                     ? "assets/cars/car2.png"
                    //                     : "assets/cars/car1.png",
                    //                 height: 30,
                    //                 width: 30,
                    //               ),
                    //       ),
                    //       boxWidth(10),
                    //       Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             'Car Type',
                    //             style: TextStyle(fontWeight: FontWeight.bold),
                    //           ),
                    //           // SizedBox(
                    //           //   height: 5,
                    //           // ),
                    //           // Text(
                    //           //   '#4523534',
                    //           //   style:
                    //           //       TextStyle(color: MyColorName.detailsColor),
                    //           // ),
                    //           SizedBox(
                    //             height: 5,
                    //           ),
                    //           Container(
                    //             decoration: BoxDecoration(
                    //                 color:
                    //                     MyColorName.primaryLite.withOpacity(.2),
                    //                 borderRadius: BorderRadius.circular(6)),
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(6.0),
                    //               child: Text(
                    //                 widget.rideList[widget.currentCar].cartype
                    //                     .toString(),
                    //                 style: TextStyle(
                    //                     color: MyColorName.primaryLite),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // boxHeight(10),
                    // Divider(
                    //   color: MyColorName.greyBorder,
                    // ),
                    // boxHeight(4),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     SizedBox(
                    //       width: 10,
                    //     ),
                    //     Text(
                    //       'Pickup & Drop',
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold, fontSize: 18),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Location',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text(widget.pickAddress,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800))
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Drop Location',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text(widget.dropAddress,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800))
                            ],
                          ),
                        )
                      ],
                    ),
                    boxHeight(10),
                  ],
                ),
              ),
              // Divider(),
              boxHeight(10),
              /*Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text("${getTranslated(context, "PAYMENT_MODE")} : ",
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black),
                          text(paymentType,
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black),
                        ],
                      ),*/

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MyColorName.greyBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('User Detail',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      boxHeight(4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      // boxHeight(5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(mobile != "" ? mobile.toString() : "",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Divider(),
              // widget.promoList.length > 0 && isFirstUser != "1"
              //     ? Container(
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Container(
              //               child: TextField(
              //                 controller: promoCon,
              //                 decoration: InputDecoration(
              //                   enabledBorder: OutlineInputBorder(),
              //                   focusedBorder: OutlineInputBorder(),
              //                   hintText:
              //                       getTranslated(context, "PROMO_CODE1")!,
              //                   suffixIcon: IconButton(
              //                     onPressed: () async {
              //                       await getPromo();
              //                       // Navigator.pop(context);
              //                       applyCode(promoCon.text);
              //                       print("sddddsds ${promoCon.text}");
              //                     },
              //                     icon: Icon(
              //                       Icons.send,
              //                       color: MyColorName.primaryLite,
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             // boxHeight(5),
              //             // ListView.builder(
              //             //     itemCount: promoList.length,
              //             //     shrinkWrap: true,
              //             //     physics: NeverScrollableScrollPhysics(),
              //             //     itemBuilder: (context, index) {
              //             //       return Container(
              //             //         margin: EdgeInsets.all(getWidth(10)),
              //             //         decoration: boxDecoration(
              //             //           showShadow: true,
              //             //         ),
              //             //         child: ListTile(
              //             //           title: text(
              //             //             "${getTranslated(context, "PROMO_CODE1")} : ${promoList[index].promocode}",
              //             //             fontSize: 12.sp,
              //             //             fontFamily: fontMedium,
              //             //             textColor: MyColorName.colorTextPrimary,
              //             //           ),
              //             //           subtitle: text(
              //             //             "${promoList[index].message}",
              //             //             fontSize: 12.sp,
              //             //             fontFamily: fontMedium,
              //             //             textColor: MyColorName.colorTextPrimary,
              //             //           ),
              //             //           trailing: InkWell(
              //             //             onTap: () {
              //             //               if (promoCon.text !=
              //             //                   promoList[index]
              //             //                       .promocode
              //             //                       .toString()) {
              //             //                 setState(() {
              //             //                   promoCon.text = promoList[index]
              //             //                       .promocode
              //             //                       .toString();
              //             //                 });
              //             //                 Navigator.pop(context);
              //             //                 applyCode(promoList[index].promocode);
              //             //               } else {
              //             //                 UI.setSnackBar(
              //             //                     "Promo code already applied",
              //             //                     context);
              //             //               }
              //             //             },
              //             //             child: Container(
              //             //               width: 20.w,
              //             //               height: 4.h,
              //             //               decoration: boxDecoration(
              //             //                   radius: 5,
              //             //                   bgColor: promoCon.text ==
              //             //                           promoList[index]
              //             //                               .promocode
              //             //                               .toString()
              //             //                       ? Colors.grey
              //             //                       : Theme.of(context)
              //             //                           .primaryColor),
              //             //               child: Center(
              //             //                   child: text(
              //             //                       promoCon.text ==
              //             //                               promoList[index]
              //             //                                   .promocode
              //             //                                   .toString()
              //             //                           ? "Applied"
              //             //                           : getTranslated(
              //             //                               context, "APPLY")!,
              //             //                       fontFamily: fontMedium,
              //             //                       fontSize: 10.sp,
              //             //                       isCentered: true,
              //             //                       textColor: Colors.white)),
              //             //             ),
              //             //           ),
              //             //         ),
              //             //       );
              //             //     }),
              //           ],
              //         ),
              //       )
              //     : SizedBox(),
              SizedBox(
                height: 15,
              ),
              // promoList.length > 0 && isFirstUser != "0"
              //     ? Container(
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Container(
              //               child: TextFormField(
              //                 controller: promoCon,
              //                 readOnly: true,
              //                 onTap: () async {
              //                   await showPromoCodeBottomSheet(context);
              //                   setState(() {});
              //                 },
              //                 decoration: InputDecoration(
              //                   labelText: "Have a Promo Code?",
              //                   suffixIcon: promoCon.text.isNotEmpty
              //                       ? InkWell(
              //                           onTap: () async {
              //                             await applyCode(promoCon.text);
              //                             setState(() {});
              //                           },
              //                           child: Icon(Icons.send,
              //                               color: Colors.green),
              //                         )
              //                       : null,
              //                 ),
              //               ),
              //               // TextField(
              //               //   controller: promoCon,
              //               //   decoration: InputDecoration(
              //               //     enabledBorder: OutlineInputBorder(),
              //               //     focusedBorder: OutlineInputBorder(),
              //               //     hintText: getTranslated(
              //               //         context, "PROMO_CODE1")!,
              //               //     suffixIcon: IconButton(
              //               //       onPressed: () async {
              //               //         showPromoCodeBottomSheet(context);
              //               //         // await applyCode(promoCon.text);
              //               //         setStateDialog(() {});
              //               //       },
              //               //       icon: Icon(Icons.send,
              //               //           color: Colors.black),
              //               //     ),
              //               //   ),
              //               // ),
              //             ),
              //             // ElevatedButton(
              //             //   onPressed: isPromoSelected
              //             //       ? () {
              //             //           applyCode(promoCon.text);
              //             //         }
              //             //       : null,
              //             //   child: Text("Apply"),
              //             // ),
              //             // boxHeight(5),
              //             // ListView.builder(
              //             //     itemCount: promoList.length,
              //             //     shrinkWrap: true,
              //             //     physics: NeverScrollableScrollPhysics(),
              //             //     itemBuilder: (context, index) {
              //             //       return Container(
              //             //         margin: EdgeInsets.all(getWidth(10)),
              //             //         decoration: boxDecoration(
              //             //           showShadow: true,
              //             //         ),
              //             //         child: ListTile(
              //             //           title: text(
              //             //             "${getTranslated(context, "PROMO_CODE1")} : ${promoList[index].promocode}",
              //             //             fontSize: 12.sp,
              //             //             fontFamily: fontMedium,
              //             //             textColor:
              //             //                 MyColorName.colorTextPrimary,
              //             //           ),
              //             //           subtitle: text(
              //             //             "${promoList[index].message}",
              //             //             fontSize: 12.sp,
              //             //             fontFamily: fontMedium,
              //             //             textColor:
              //             //                 MyColorName.colorTextPrimary,
              //             //           ),
              //             //           trailing: InkWell(
              //             //             onTap: () {
              //             //               if (promoCon.text !=
              //             //                   promoList[index]
              //             //                       .promocode
              //             //                       .toString()) {
              //             //                 setState(() {
              //             //                   promoCon.text =
              //             //                       promoList[index]
              //             //                           .promocode
              //             //                           .toString();
              //             //                 });
              //             //                 Navigator.pop(context);
              //             //                 applyCode(promoList[index]
              //             //                     .promocode);
              //             //               } else {
              //             //                 UI.setSnackBar(
              //             //                     "Promo code already applied",
              //             //                     context);
              //             //               }
              //             //             },
              //             //             child: Container(
              //             //               width: 20.w,
              //             //               height: 4.h,
              //             //               decoration: boxDecoration(
              //             //                   radius: 5,
              //             //                   bgColor: promoCon.text ==
              //             //                           promoList[index]
              //             //                               .promocode
              //             //                               .toString()
              //             //                       ? Colors.grey
              //             //                       : Theme.of(context)
              //             //                           .primaryColor),
              //             //               child: Center(
              //             //                   child: text(
              //             //                       promoCon.text ==
              //             //                               promoList[index]
              //             //                                   .promocode
              //             //                                   .toString()
              //             //                           ? "Applied"
              //             //                           : getTranslated(
              //             //                               context,
              //             //                               "APPLY")!,
              //             //                       fontFamily: fontMedium,
              //             //                       fontSize: 10.sp,
              //             //                       isCentered: true,
              //             //                       textColor:
              //             //                           Colors.white)),
              //             //             ),
              //             //           ),
              //             //         ),
              //             //       );
              //             //     }),
              //           ],
              //         ),
              //       )
              //     : SizedBox(),
              // boxHeight(15),
              // Divider(),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MyColorName.greyBorder)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Payment'),
                        ],
                      ),
                      boxHeight(5),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // widget.time == 0 || widget.time.length == 0 ?
                      //     text("${"Toll Tax"}",
                      //         // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     // : text("${widget.time}:",
                      //     //     fontSize: 10.sp,
                      //     //     fontFamily: fontMedium,
                      //     //     textColor: Colors.black),
                      //     text("${widget.tollTax}",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),
                      //
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // widget.time == 0 || widget.time.length == 0 ?
                      //     text("${"State Tax"}",
                      //         // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     // : text("${widget.time}:",
                      //     //     fontSize: 10.sp,
                      //     //     fontFamily: fontMedium,
                      //     //     textColor: Colors.black),
                      //     text("${widget.stateCharge}",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // widget.time == 0 || widget.time.length == 0 ?
                      //     text("${"Parking"}",
                      //         // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     // : text("${widget.time}:",
                      //     //     fontSize: 10.sp,
                      //     //     fontFamily: fontMedium,
                      //     //     textColor: Colors.black),
                      //     text("${widget.parking}",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),
                      //
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     // widget.time == 0 || widget.time.length == 0 ?
                      //     text("${"Night Charge"}",
                      //         // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     // : text("${widget.time}:",
                      //     //     fontSize: 10.sp,
                      //     //     fontFamily: fontMedium,
                      //     //     textColor: Colors.black),
                      //     text("${widget.nightCharge}",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text("${getTranslated(context, "DISTANCE")} : ",
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: MyColorName.detailsColor),
                          text(
                              widget.rideList[widget.currentCar].distance +
                                  " Km",
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black),
                        ],
                      ),
                      // double.parse(rideList[currentCar].base_fare) >= 1
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           text("${getTranslated(context, "BASE_FARE")} : ",
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //           text(
                      //               double.parse(distance) >= 1
                      //                   ? "₹" + rideList[currentCar].base_fare
                      //                   : "₹" + rideList[currentCar].minFare,
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //         ],
                      //       )
                      //     : SizedBox(),
                      // double.parse(rideList[currentCar].main_rate_per_km) >
                      //         double.parse(rideList[currentCar].rate_per_km)
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           text(
                      //               "$distance ${getTranslated(context, "KILOMETERS")} : ",
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //           text("₹" + rideList[currentCar].main_rate_per_km,
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.red),
                      //         ],
                      //       )
                      //     : SizedBox(),
                      if (double.parse(widget
                              .rideList[widget.currentCar].main_rate_per_km) >
                          double.parse(
                              widget.rideList[widget.currentCar].rate_per_km))
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            "After Discounted",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      double.parse(widget
                                  .rideList[widget.currentCar].base_fare) >=
                              1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // widget.time == 0 || widget.time.length == 0 ?
                                text("${"Base Fare"}",
                                    // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: MyColorName.detailsColor),
                                // : text("${widget.time}:",
                                //     fontSize: 10.sp,
                                //     fontFamily: fontMedium,
                                //     textColor: Colors.black),
                                text(
                                    "${double.parse(widget.rideList[widget.currentCar].base_fare).toStringAsFixed(2)}",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: Colors.black),
                              ],
                            )
                          : SizedBox(),

                      // double.parse(rideList[currentCar].time_cahrge) > 0
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           text(
                      //               "$totalTime ${getTranslated(context, "MINUTES")} : ",
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //           text("₹" + rideList[currentCar].time_cahrge,
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //         ],
                      //       )
                      //     : SizedBox(),
                      double.parse(widget
                                  .rideList[widget.currentCar].tax_amount) >=
                              1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text("${getTranslated(context, "TAXES")}  ",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: MyColorName.detailsColor),
                                text(
                                    "₹" +
                                        double.parse(widget
                                                .rideList[widget.currentCar]
                                                .tax_amount)
                                            .toStringAsFixed(2),
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: Colors.black),
                                // text("₹" + gst.toStringAsFixed(2),
                                //     fontSize: 10.sp,
                                //     fontFamily: fontMedium,
                                //     textColor: Colors.black),
                              ],
                            )
                          : SizedBox(),

                      double.parse(widget.rideList[widget.currentCar]
                                  .cancellation_charges) >
                              0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text("Last ride cancellation  Charge  ",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: MyColorName.detailsColor),
                                text(
                                    "₹" +
                                        double.parse(widget
                                                .rideList[widget.currentCar]
                                                .cancellation_charges)
                                            .toStringAsFixed(2),
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: Colors.black),
                                // text("₹" + gst.toStringAsFixed(2),
                                //     fontSize: 10.sp,
                                //     fontFamily: fontMedium,
                                //     textColor: Colors.black),
                              ],
                            )
                          : SizedBox(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     text("Service Charge ",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     text(
                      //         "₹" +
                      //             double.parse(widget
                      //                     .rideList[widget.currentCar]
                      //                     .service_charge)
                      //                 .toStringAsFixed(2),
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),
                      widget.surge > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text("${getTranslated(context, "SURGE")}  ",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: Colors.black),
                                text("₹" + widget.surge.toStringAsFixed(2),
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: MyColorName.detailsColor),
                              ],
                            )
                          : SizedBox(),
                      double.parse(widget
                                  .rideList[widget.currentCar].rate_per_km) >
                              0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text("${getTranslated(context, "SUB_TOTAL")} ",
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: MyColorName.detailsColor),
                                text(
                                    "₹" +
                                        (
                                                // surge + gst +
                                                double.parse(widget
                                                    .rideList[widget.currentCar]
                                                    .rate_per_km))
                                            .toStringAsFixed(2),
                                    fontSize: 10.sp,
                                    fontFamily: fontMedium,
                                    textColor: Colors.black),
                              ],
                            )
                          : SizedBox(),
                      // promoDiscount != "0"
                      //     ?
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     text("${getTranslated(context, "PROMO")}  ",
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: MyColorName.detailsColor),
                      //     text("-₹" + double.parse(promoDiscount).toString(),
                      //         fontSize: 10.sp,
                      //         fontFamily: fontMedium,
                      //         textColor: Colors.black),
                      //   ],
                      // ),
                      // : SizedBox(),
                      // isSelectedCoin
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           text("Coins Used",
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: MyColorName.detailsColor),
                      //           text("-₹ ${points}",
                      //               fontSize: 10.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //         ],
                      //       )
                      //     : SizedBox(),
                      Divider(
                        color: MyColorName.greyBorder,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(
                              // "${getTranslated(context, "TOTAL")} : ",
                              "Total Amount",
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              fontWeight: FontWeight.bold,
                              textColor: Colors.black),
                          text(
                              "₹" +
                                  ( // surge + gst +
                                          double.parse(widget
                                                  .rideList[widget.currentCar]
                                                  .rate_per_km) -
                                              double.parse(promoDiscount) -
                                              (isSelectedCoin
                                                  ? double.parse(
                                                      points.toString())
                                                  : 0))
                                      .toStringAsFixed(2),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontMedium,
                              textColor: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // rideList[currentCar].cancellation_charges != null
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           text(
              //               "${getTranslated(context, "CANCEL_CHARGE")} : ",
              //               fontSize: 10.sp,
              //               fontFamily: fontMedium,
              //               textColor: Colors.black),
              //           text(
              //               "₹" +
              //                   rideList[currentCar]
              //                       .cancellation_charges
              //                       .toString(),
              //               fontSize: 10.sp,
              //               fontFamily: fontMedium,
              //               textColor: Colors.black),
              //         ],
              //       )
              //     : SizedBox(),
              // widget.shareType != ""
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           text("${getTranslated(context, "RIDE_TYPE")} : ",
              //               fontSize: 10.sp,
              //               fontFamily: fontMedium,
              //               textColor: Colors.black),
              //           text(widget.shareType,
              //               fontSize: 10.sp,
              //               fontFamily: fontMedium,
              //               textColor: Colors.black),
              //         ],
              //       )
              //     : SizedBox(),
              boxHeight(10),
              // widget.type != "now"
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           text("${getTranslated(context, "BOOKING_DATE")}: ",
              //               fontSize: 10.sp,
              //               fontWeight: FontWeight.w600,
              //               fontFamily: fontMedium,
              //               textColor: Colors.black),
              //           Expanded(
              //             child: text(getDate(widget.bookingDate),
              //                 fontSize: 10.sp,
              //                 fontWeight: FontWeight.w600,
              //                 fontFamily: fontMedium,
              //                 textColor: Colors.black),
              //           ),
              //         ],
              //       )
              //     : SizedBox(),
              // SizedBox(
              //   height: 10,
              // ),
              // Row(
              //   children: [
              //     // Checkbox(
              //     //   checkColor: Colors.white, // Color of the check icon
              //     //   fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              //     //     if (states.contains(MaterialState.selected)) {
              //     //       return Colors.blue; // Color when checkbox is selected
              //     //     }
              //     //     return Colors.grey; // Default color
              //     //   }),
              //     //   value: isChecked,
              //     //   onChanged: (bool? value) {
              //     //     setState(() {
              //     //       isChecked = value!;
              //     //     });
              //     //   },
              //     // ),
              //     // InkWell(
              //     //   onTap: () {
              //     //     _launchURL();
              //     //   },
              //     //   child: Text(
              //     //     "Read Before You ---->",
              //     //     style: TextStyle(
              //     //       fontSize: 15,
              //     //       color: Colors.green,
              //     //     ),
              //     //   ),
              //     // ),
              //     // Icon(Icons.arrow_forward_ios_outlined, color: Colors.green,)
              //   ],
              // ),
              // boxHeight(10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // InkWell(
              //     //   onTap: () {
              //     //     Navigator.pop(context1);
              //     //     // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
              //     //   },
              //     //   child: Container(
              //     //     width: 30.w,
              //     //     height: 5.h,
              //     //     decoration:
              //     //         boxDecoration(radius: 5, bgColor: Colors.grey),
              //     //     child: Center(
              //     //         child: text(getTranslated(context, "CANCEL")!,
              //     //             fontFamily: fontMedium,
              //     //             fontSize: 10.sp,
              //     //             isCentered: true,
              //     //             textColor: Colors.white)),
              //     //   ),
              //     // ),
              //   ],
              // ),
              // SizedBox(
              //   height: 50,
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // const SizedBox(height: 10),
                  ListTile(
                    leading: Radio<String>(
                      value: "Cash",
                      groupValue: _paymentMethod,
                      activeColor: Color(0xff7DBF04),
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    title: const Text("Cash"),
                  ),
                  ListTile(
                    leading: Radio<String>(
                      value: "Online",
                      groupValue: _paymentMethod,
                      activeColor: Color(0xff7DBF04),
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    title: const Text("Online Payment"),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.black))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (_paymentMethod == "Online") {
                              openCheckout(
                                (double.parse(widget.rideList[widget.currentCar]
                                        .rate_per_km) -
                                    double.parse(promoDiscount)),
                              );
                            } else if (_paymentMethod == "Cash") {
                              // Cash booking ka logic
                              paymentCalculate(
                                (double.parse(widget.rideList[widget.currentCar]
                                        .rate_per_km) -
                                    double.parse(promoDiscount)),
                              );
                              addScheduleRides();
                            }
                          },
                          child: Container(
                            width: 90.w,
                            height: 6.h,
                            decoration: boxDecoration(
                              radius: 5,
                              bgColor: Color(0xff7DBF04),
                            ),
                            child: Center(
                              child: text(
                                "BOOK RIDE",
                                fontFamily: fontMedium,
                                fontWeight: FontWeight.w500,
                                fontSize: 13.sp,
                                isCentered: true,
                                textColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              boxHeight(10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // InkWell(
              //     //   onTap: () {
              //     //     Navigator.pop(context1);
              //     //     // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
              //     //   },
              //     //   child: Container(
              //     //     width: 30.w,
              //     //     height: 5.h,
              //     //     decoration:
              //     //         boxDecoration(radius: 5, bgColor: Colors.grey),
              //     //     child: Center(
              //     //         child: text(getTranslated(context, "CANCEL")!,
              //     //             fontFamily: fontMedium,
              //     //             fontSize: 10.sp,
              //     //             isCentered: true,
              //     //             textColor: Colors.white)),
              //     //   ),
              //     // ),
              //     InkWell(
              //       onTap: () {
              //         Navigator.pop(context1);
              //         readBeforeDialog(context);
              //         // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
              //       },
              //       child: Container(
              //         width: 69.w,
              //         height: 6.h,
              //         decoration: boxDecoration(
              //             radius: 5, bgColor: MyColorName.secondary),
              //         child: Center(
              //           child: text(
              //               // getTranslated(context, "CONFIRM")!,
              //               "Read Before You",
              //               fontFamily: fontMedium,
              //               fontWeight: FontWeight.w500,
              //               fontSize: 13.sp,
              //               isCentered: true,
              //               textColor: Colors.white),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  List<PromoModel> promoList = [];

  getPromo() async {
    try {
      setState(() {
        driveStatus = true;
        promoList.clear();
      });
      Map<String, String> headers = {
        'Cookie': 'ci_session=af8562a0e8522666d9116d66e0a43684ac5e35f7',
        'Content-Type': 'application/json',
      };
      Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "Payment/get_promo_code"),
        headers,
      );
      if (response['status']) {
        for (var v in response['data']) {
          setState(() {
            promoList.add(new PromoModel.fromJson(v));
          });
        }
        setState(() {
          driveStatus = false;
        });
      } else {
        setState(() {
          driveStatus = false;
        });
        //UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        driveStatus = true;
      });
    }
  }

  late Future<List<Map<String, dynamic>>> futurePromoList;
  String? selectedPromo;

  Future<void> showPromoCodeBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              builder: (context, scrollController) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: promoList.length,
                  padding: EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final promo = promoList[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: boxDecoration(showShadow: true),
                      child: ListTile(
                        title: text(
                          "${getTranslated(context, "PROMO_CODE1")} : ${promo.promocode}",
                          fontSize: 12.sp,
                          fontFamily: fontMedium,
                          textColor: MyColorName.colorTextPrimary,
                        ),
                        subtitle: text(
                          "${promo.message}",
                          fontSize: 12.sp,
                          fontFamily: fontMedium,
                          textColor: MyColorName.colorTextPrimary,
                        ),
                        onTap: () async {
                          promoCon.text = promo.promocode.toString();
                          setStateBottomSheet(() {});
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  double? partPayment, amounFinal;
  paymentCalculate(double? amount) {
    partPayment = double.parse(amount.toString()) * 0.30;
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool saveStatus = true;
  bool driveStatus = true;
  bool isLoading = false;

  addScheduleRides() async {
    try {
      setState(() {
        isLoading = true;
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId,
        "username": name,
        "pickup_address": widget.pickAddress,
        "latitude": widget.source.latitude.toString(),
        "longitude": widget.source.longitude.toString(),
        "drop_address":
            widget.dropAddress == '' ? 'Indore' : widget.dropAddress,
        "drop_latitude": widget.destination.latitude.toString(),
        "drop_longitude": widget.destination.longitude.toString(),
        'unit_price': widget.unitPrice.toString(),
        "amount": widget.rideList[widget.currentCar].rate_per_km,
        // (double.parse(widget.rideList[widget.currentCar].intailrate)
        //             .roundToDouble() -
        //         double.parse(promoDiscount).roundToDouble() +
        //         widget.gst )
        //     .toStringAsFixed(2),
        "paid_amount": '0',
        "gst_amount": widget.rideList[widget.currentCar].tax_amount,
        "total_time": '0',
        "taxi_id": '0',
        "surge_amount": '0',
        "distance": widget.rideList[widget.currentCar].distance,
        "km": widget.rideList[widget.currentCar].distance,
        "admin_commission": '0',
        "taxi_type": widget.rideList[widget.currentCar].catType != ""
            ? widget.rideList[widget.currentCar].catType
            : "Auto",
        "delivery_type": widget.rideList[widget.currentCar].catType != "" &&
                widget.rideList[widget.currentCar].catType != "Auto"
            ? "2"
            : "1",
        "rate_per_km": widget.rideList[widget.currentCar].rate_per_km,
        "base_fare": double.parse(widget.rideList[widget.currentCar].base_fare)
            .toString(),
        "time_amount": widget.rideList[widget.currentCar].time_cahrge,
        "paymenttype": _paymentMethod,
        "transaction": "Wait For Payment",
        "cancel_charge": widget.rideList[widget.currentCar].cancellation_charge,
        "pickup_time": widget.returnDate,
        "pickup_date": widget.bookingDate == null
            ? DateFormat("yyyy-MM-dd").format(DateTime.now())
            : DateFormat("yyyy-MM-dd").format(widget.bookingDate!),
        "sharing_type": widget.shareType,
        "surge_percentage": widget.surgePer,
        'vendor_id': widget.vendorId.toString(),
        'vehicle_id': widget.rideList[widget.currentCar].taxi_id,
        'order_type': widget.bookingDate == null ? 'current' : 'schedule',
        // 'return_date': widget.bookingDate.toString(),
        "is_parking": widget.tollTax.toString(),
        "is_toll_tax": widget.parking.toString(),
        'fuel_type': "${widget.rideList[widget.currentCar].fuel_type}",
        "night_charge": widget.nightCharge.toString(),
        "state_tax": widget.stateCharge.toString(),
        'point_used': isSelectedCoin ? points.toString() : '0',
        'last_cancel_charge':
            widget.rideList[widget.currentCar].cancellation_charges,
        'service_charge': widget.rideList[widget.currentCar].service_charge,

        // 'return_time': widget.returnDate.toString()
      };
      if (promoDiscount != "0") {
        params['promo_discount'] =
            double.parse(promoDiscount).roundToDouble().toString();
        params['promo_code'] = promoCon.text.toString();
      }
      print("schedule ride is $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/shedual_booking_trip"), params);
      setState(() {
        isLoading = false;
        saveStatus = true;
      });
      print('confirm ride booking para ${response}');
      if (response['status']) {
        widget.bookingId = response['booking_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindingRidePage(
                widget.source,
                widget.destination,
                widget.pickAddress,
                widget.dropAddress,
                widget.paymentType,
                response['booking_id'].toString(),
                (
                        // surge + gst +
                        double.parse(widget
                                .rideList[widget.currentCar].rate_per_km) -
                            double.parse(promoDiscount) -
                            (isSelectedCoin
                                ? double.parse(points.toString())
                                : 0))
                    .toStringAsFixed(2),
                // (widget.surge +
                //         widget.gst +
                //         double.parse(widget
                //                 .rideList[widget.currentCar].intailrate)
                //             .roundToDouble() -
                //         double.parse(promoDiscount))
                //     .roundToDouble()
                //     .toStringAsFixed(2),
                // (double.parse(rideList[_currentCar].rate_per_km)+double.parse(rideList[_currentCar].base_fare)-double.parse(promoDiscount)+gst+surge).toStringAsFixed(2),

                widget.rideList[widget.currentCar].distance //distance
                ),
          ),
        );

        // Navigator.pop(context, "yes");
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PaymentScreen(
        //       bookingId: widget.bookingId.toString(),
        //       paymentType: 'Full Payment',
        //       amount:
        //           (double.parse(widget.rideList[widget.currentCar].rate_per_km)
        //                       .roundToDouble() -
        //                   double.parse(promoDiscount).roundToDouble())
        //               .toStringAsFixed(2),
        //       // unitPri: unitPrice.toString(),
        //     ),
        //   ),
        // );
        // UI.setSnackBar("Booking Confirmed", context);
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

  applyCode(code) async {
    try {
      setState(() {
        saveStatus = false;
        widget.driverList.clear();
      });
      double gst = 0;
      if (widget.rideList[widget.currentCar].gst != null &&
          widget.rideList[widget.currentCar].gst != "") {
        gst = ((double.parse(widget.rideList[widget.currentCar].gst) *
                    double.parse(
                        widget.rideList[widget.currentCar].intailrate)) /
                100)
            .roundToDouble();
      }
      print(gst);
      double surge = 0;
      if (widget.bookingDate == null &&
          !widget.rideList[widget.currentCar].serge.contains("Not") &&
          widget.rideList[widget.currentCar].surge_charge.length > 0) {
        if (widget.rideList[widget.currentCar].surge_charge[0]['time_on_off']
                .toString() !=
            "CLOSED") {
          surge = ((double.parse(widget
                          .rideList[widget.currentCar].surge_charge[0]['amount']
                          .toString()) *
                      double.parse(
                          widget.rideList[widget.currentCar].intailrate)) /
                  100)
              .roundToDouble();
        } else {
          surge = 0;
        }
      }
      print(widget.bookingDate);
      print(surge);
      print(widget.rideList[widget.currentCar].intailrate);
      gst += surge +
          double.parse(widget.rideList[widget.currentCar].intailrate)
              .roundToDouble();
      Map params = {
        "final_total": widget.rideList[widget.currentCar].rate_per_km,
        "promo_code": code,
        "user_id": curUserId,
      };
      print("appy promo code ${params}");
      https: //productsalphawizz.com/taxi/api/Payment/get_promo_code
      Map response = await apiBase.postAPICall(
          // Uri.parse(baseUrl1 + "Payment/validate_promo_code5"), params);
          Uri.parse(baseUrl1 + "Payment/apply_promo_code"),
          params);

      if (response['status']) {
        UI.setSnackBar("${response['message']}", context);
        setState(() {
          saveStatus = true;
        });
        if (response['data'] is List &&
            response['data'].length > 0 &&
            response['data'][0]['type'] == 'Percentage') {
          setState(() {
            promoDiscount = response['data'][0]['final_discount'] != null &&
                    response['data'][0]['final_discount'] != ""
                ? (double.parse(
                        response['data'][0]['final_discount'].toString()))
                    .roundToDouble()
                    .toString()
                : "0";
            /*rideList[_currentCar].intailrate =
                (double.parse(rideList[_currentCar].intailrate) -
                        double.parse(promoDiscount))
                    .toStringAsFixed(0);*/
          });
          getJoiningBonus();
        } else {
          if (response['data'] is List && response['data'].length > 0)
            setState(() {
              promoDiscount = response['data'][0]['final_discount'] != null &&
                      response['data'][0]['final_discount'] != ""
                  ? response['data'][0]['final_discount'].toString()
                  : "0";
              // rideList[_currentCar].intailrate = (double.parse(rideList[_currentCar].intailrate) -
              //             double.parse(promoDiscount)).toStringAsFixed(0);
            });
        }
        print("this is promo discount ===>${promoDiscount.toString()}");
      } else {
        UI.setSnackBar("${response['message']}", context);
        setState(() {
          saveStatus = true;
        });
        //UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }
}
