import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pristine_andaman/BookRide/rate_ride_dialog.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/PushNotificationService.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class RideInfoPage extends StatefulWidget {
  MyRideModel model;
  String? check;
  RideInfoPage(this.model, {this.check});

  @override
  State<RideInfoPage> createState() => _RideInfoPageState();
}

class _RideInfoPageState extends State<RideInfoPage> {
  bool showMore = false;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool acceptStatus = false;
  String totalTime = "0".toString();
  bool change = false;

  getTime1(lat1, lon1, lat2, lon2) async {
    if (lat1 != "" &&
        lat1 != null &&
        lon1 != "" &&
        lon1 != null &&
        lat2 != "" &&
        lat2 != null &&
        lon2 != "" &&
        lon2 != null) {
      print("check1");
      http.Response response = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"));
      print(response.body);
      Map res = jsonDecode(response.body);
      List<dynamic> data = res['rows'][0]['elements'];
      //  String totalTime = "0 Mins".toString();
      if (response.body.contains("text")) {
        totalTime = (int.parse(data[0]['duration']['value'].toString()) / 60)
            .round()
            .toString();
      }
      print(totalTime);
      updateLocation(widget.model.bookingId.toString());
    } else {}
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    try {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    } on Exception catch (exception) {
      return 0; // only executed if error is of type Exception
    } catch (error) {
      return 0; // executed for errors of all types other than Exception
    }
  }

  updateLocation(
    String bookingId,
  ) async {
    await App.init();

    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
          "drop_address": widget.model.dropAddress,
          "booking_id": bookingId,
          "distance": calculateDistance(
                  double.parse(widget.model.latitude.toString()),
                  double.parse(widget.model.longitude.toString()),
                  double.parse(widget.model.dropLatitude.toString()),
                  double.parse(widget.model.dropLongitude.toString()))
              .toStringAsFixed(2),
          "drop_latitude": widget.model.dropLatitude,
          "drop_longitude": widget.model.dropLongitude,
          "taxi_id": widget.model.taxiId,
          "time": totalTime,
          "surge_amount": widget.model.surgeAmount,
        };
        print("this is our updated request **** ${data.toString()}");
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "Payment/update_change_location"), data);
        print(
            "this is new updated response &&&&& ^^^^^^ ${response.toString()}");
        print(response);
        setState(() {
          acceptStatus = false;
        });
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          Navigator.pop(context, true);
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.check != null) {
      showMore = true;
    }
    PushNotificationService pushNotificationService =
        new PushNotificationService(
            context: context,
            onResult: (result) {
              //if(mounted&&result=="yes")
              print("result" + result);
              if (result == "com" || result == "cancel") {
                if (result == "com") {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => RateRideDialog(widget.model),
                  );
                }
              } else {
                Navigator.pop(context, true);
              }
            });
    pushNotificationService.initialise();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "asdsdadsssssssssadada ${(double.parse(widget.model.finalAmount ?? '0') - double.parse(widget.model.paidAmount ?? '0')).toStringAsFixed(2)}");
    var theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 4, // controls shadow height
          shadowColor: Colors.black.withOpacity(0.2),
          backgroundColor: MyColorName.colorBg1,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: MyColorName.secondary,
            ),
          ),
          title: Text(
            // getTranslated(context, "MY_RIDES")??"My Rides",
            "Booking Detail",
            style: TextStyle(
                fontSize: 22,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w500,
                color: MyColorName.secondary
            ),
          ),
          centerTitle: true,
        ),

        /* floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: (){

            },
            child: Icon(Icons.share,color: Colors.white,),
          ),*/
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            // height: widget.check != null
            //     ? MediaQuery.of(context).size.height - 80
            //     : null,
            child: Column(
              mainAxisSize:
                  widget.check != null ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: widget.check != null
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                /*  widget.model.promo_discount!=null&&widget.model.promo_discount!=""&&widget.model.promo_discount!="0"?AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        "Promo Discount - \u{20B9}${widget.model.promo_discount}",
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                    ],
                    pause: Duration(milliseconds: 100),
                    isRepeatingAnimation: true,
                    totalRepeatCount: 100,
                    onTap: () {
                      print("Tap Event");
                    },
                  ):SizedBox(),*/
                // widget.model.acceptReject != "3"
                //     ? Container(
                //         padding: EdgeInsets.all(getWidth(10)),
                //         color: Colors.white,
                //         child: AnimatedTextKit(
                //           animatedTexts: [
                //             ColorizeAnimatedText(
                //               "Cancellation Charge ₹${widget.model.cancel_charge} will be deducted from the wallet.",
                //               textStyle: colorizeTextStyle,
                //               colors: colorizeColors,
                //             ),
                //           ],
                //           pause: Duration(milliseconds: 100),
                //           isRepeatingAnimation: true,
                //           totalRepeatCount: 100,
                //           onTap: () {
                //             print("Tap Event");
                //           },
                //         ),
                //       )
                //     : SizedBox(),
                // Text(
                //   widget.model.acceptReject == "6"
                //       ? "Trip End OTP : ${widget.model.bookingOtp}"
                //       : "Start OTP : ${widget.model.bookingOtp}",
                // ),
                boxHeight(2.h),
                // Text("OTP : ${widget.model.otp.toString()}"),
                // showMore ?
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      // margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: MyColorName.colorBg1,
                        border: Border.all(color: MyColorName.greyBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   height: 60,
                          //   padding: EdgeInsets.symmetric(horizontal: 12),
                          //   decoration: BoxDecoration(
                          //     color: theme.colorScheme.background,
                          //     borderRadius: BorderRadius.circular(16),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       // widget.model.driverName != null ?
                          //       Container(
                          //         height: 52,
                          //         width: 52,
                          //         child: ClipRRect(
                          //           borderRadius: BorderRadius.circular(12),
                          //           child: Image.network(
                          //             widget.model.vImage.toString(),
                          //             height: 62,
                          //             width: 62,
                          //           ),
                          //         ),
                          //       ),
                          //       // : SizedBox(),
                          //       SizedBox(width: 10),
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.start,
                          //             // mainAxisAlignment:
                          //             //     MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               // widget.model.driverName != null
                          //               //     ? Text(
                          //               //         '${widget.model.driverName}',
                          //               //         style: theme
                          //               //             .textTheme.headline6!
                          //               //             .copyWith(
                          //               //                 fontSize: 18,
                          //               //                 letterSpacing: 1.2),
                          //               //       )
                          //               //     : SizedBox(),
                          //               // boxWidth(12.w),
                          //               Row(
                          //                 children: [
                          //                   Text(
                          //                       '${getTranslated(context, "TRIP_ID")}',
                          //                       style: TextStyle(
                          //                           fontWeight:
                          //                               FontWeight.bold)),
                          //                   Text(
                          //                     ' - ${widget.model.uneaqueId.toString()}',
                          //                     style: theme.textTheme.bodyMedium,
                          //                   ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ),
                          //           Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               /* Text(
                          //     '${widget.model.taxiType}',
                          //     style:
                          //     theme.textTheme.caption!.copyWith(fontSize: 12),
                          //   ),*/
                          //               // Text(
                          //               //   getTranslated(context, "CAR_TYPE")!,
                          //               //   style: theme.textTheme.caption,
                          //               // ),
                          //               // Spacer(),
                          //               Text(
                          //                 '${widget.model.taxiType}',
                          //                 style: theme.textTheme.bodyMedium!
                          //                     .copyWith(fontSize: 14),
                          //                 overflow: TextOverflow.ellipsis,
                          //               ),
                          //               Column(
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.end,
                          //                 children: [
                          //                   widget.model.rating.toString() !=
                          //                           "null"
                          //                       ? Container(
                          //                           padding:
                          //                               EdgeInsets.symmetric(
                          //                                   horizontal: 6,
                          //                                   vertical: 2),
                          //                           decoration: BoxDecoration(
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                     30),
                          //                             color:
                          //                                 AppTheme.ratingsColor,
                          //                           ),
                          //                           child: Row(
                          //                             mainAxisSize:
                          //                                 MainAxisSize.min,
                          //                             children: [
                          //                               Text(
                          //                                 '${widget.model.rating}',
                          //                                 style: theme.textTheme
                          //                                     .bodyMedium!
                          //                                     .copyWith(
                          //                                         fontSize: 12),
                          //                               ),
                          //                               SizedBox(width: 4),
                          //                               Icon(
                          //                                 Icons.star,
                          //                                 color: AppTheme
                          //                                     .starColor,
                          //                                 size: 10,
                          //                               )
                          //                             ],
                          //                           ),
                          //                         )
                          //                       : SizedBox(),
                          //                   // Text(
                          //                   //   getTranslated(context, 'BOOKED_ON')!,
                          //                   //   style: theme.textTheme.caption,
                          //                   // ),
                          //                   // Spacer(),
                          //                   Text(
                          //                     '${getDate(widget.model.dateAdded)}',
                          //                     style: theme.textTheme.bodyMedium!
                          //                         .copyWith(fontSize: 15),
                          //                     overflow: TextOverflow.ellipsis,
                          //                   ),
                          //                 ],
                          //               ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 10, right: 10),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         widget.model.vehicleCategory.toString(),
                          //         style: theme.textTheme.bodyMedium,
                          //       ),
                          //       // Text(
                          //       //   "${widget.model.seatingCapacity.toString()} Seats",
                          //       //   style: theme.textTheme.bodyText1,
                          //       // ),
                          //       Text(
                          //         "${widget.model.distance.toString()} Kms",
                          //         style: theme.textTheme.bodyMedium,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: 5),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     left: 10,
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     children: [
                          //       Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             // Text(
                          //             //   "Fuel Type",
                          //             //   style: theme.textTheme.bodyText1,
                          //             // ),
                          //             widget.model.extraKmPrice == null ||
                          //                     widget.model.extraKmPrice ==
                          //                         '0.00'
                          //                 ? SizedBox()
                          //                 : Text(
                          //                     "Extra km fare",
                          //                     style: theme.textTheme.bodyMedium,
                          //                   ),
                          //             // Text(
                          //             //   "Luggage Carrier",
                          //             //   style: theme.textTheme.bodyText1,
                          //             // ),
                          //             widget.model.luggageCapacity == null
                          //                 ? SizedBox()
                          //                 : Text(
                          //                     "Luggage Capacity",
                          //                     style: theme.textTheme.bodyMedium,
                          //                   ),
                          //             // Text("Insurance Expiry",
                          //             //     style: Theme.of(context)
                          //             //         .textTheme
                          //             //         .bodyText2!
                          //             //         .copyWith(
                          //             //         fontSize: 12,
                          //             //         fontWeight:
                          //             //         FontWeight.bold)),
                          //             // Text("Pollution Expiry",
                          //             //     style: Theme.of(context)
                          //             //         .textTheme
                          //             //         .bodyText2!
                          //             //         .copyWith(
                          //             //         fontSize: 12,
                          //             //         fontWeight:
                          //             //         FontWeight.bold)),
                          //           ]),
                          //       SizedBox(
                          //         width: 80,
                          //       ),
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           // Text(
                          //           //   widget.model.fuelType.toString(),
                          //           //   style: Theme.of(context)
                          //           //       .textTheme
                          //           //       .bodyText2!
                          //           //       .copyWith(
                          //           //           // fontSize: 12,
                          //           //           fontWeight: FontWeight.w500),
                          //           // ),
                          //           widget.model.extraKmPrice == null ||
                          //                   widget.model.extraKmPrice == '0.00'
                          //               ? SizedBox()
                          //               : Text(
                          //                   widget.model.extraKmPrice
                          //                       .toString(),
                          //                   style: Theme.of(context)
                          //                       .textTheme
                          //                       .bodyMedium!
                          //                       .copyWith(
                          //                           // fontSize: 12,
                          //                           fontWeight:
                          //                               FontWeight.w500),
                          //                 ),
                          //           // Text(
                          //           //   widget.model.luggageCarrier.toString(),
                          //           //   style: Theme.of(context)
                          //           //       .textTheme
                          //           //       .bodyText2!
                          //           //       .copyWith(
                          //           //           // fontSize: 12,
                          //           //           fontWeight: FontWeight.w500),
                          //           // ),
                          //           widget.model.luggageCapacity == null
                          //               ? SizedBox()
                          //               : Text(
                          //                   widget.model.luggageCapacity
                          //                       .toString(),
                          //                   style: Theme.of(context)
                          //                       .textTheme
                          //                       .bodyMedium!
                          //                       .copyWith(
                          //                           // fontSize: 12,
                          //                           fontWeight:
                          //                               FontWeight.w500),
                          //                 ),
                          //           // Text(
                          //           //   rideList[index].vehicle_no.toString(),
                          //           //   style: Theme.of(context)
                          //           //       .textTheme
                          //           //       .bodyText2!
                          //           //       .copyWith(
                          //           //       fontSize: 14,
                          //           //       fontWeight:
                          //           //       FontWeight.w500),
                          //           // ),
                          //           // Text(
                          //           //   rideList[index].insurance_expiry.toString(),
                          //           //   style: Theme.of(context)
                          //           //       .textTheme
                          //           //       .bodyText2!
                          //           //       .copyWith(
                          //           //       fontSize: 12,
                          //           //       fontWeight:
                          //           //       FontWeight.w500),
                          //           // ),
                          //           // Text(
                          //           //   rideList[index].pollution_expiry.toString(),
                          //           //   style: Theme.of(context)
                          //           //       .textTheme
                          //           //       .bodyText2!
                          //           //       .copyWith(
                          //           //       fontSize: 12,
                          //           //       fontWeight:
                          //           //       FontWeight.w500),
                          //           // ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Divider(color: MyColorName.greyDivider),

                          ///rideinfo KM
                          // ListTile(
                          //   title: Text(
                          //     getTranslated(context, 'RIDE_INFO')!,
                          //     style: theme.textTheme.headline6!.copyWith(
                          //         color: theme.hintColor, fontSize: 16.5),
                          //   ),
                          //   trailing: Text('${widget.model.km} km',
                          //       style: theme.textTheme.headline6!
                          //           .copyWith(fontSize: 16.5)),
                          // ),

                          // Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 12.0),
                          //   child: text("Pickup & Drop",
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w700,
                          //       textColor: Colors.black),
                          // ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(Icons.location_on_rounded,
                                color: Colors.green),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text("Pickup Location",
                                    fontSize: 12,
                                    fontFamily: AppTheme.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    textColor: MyColorName.textColor),
                                Text(
                                  '${widget.model.pickupAddress}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: AppTheme.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: MyColorName.textColor1),
                                ),
                              ],
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(Icons.location_on_rounded,
                                color: Colors.red),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text("Drop Location",
                                    fontSize: 12,
                                    fontFamily: AppTheme.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    textColor: MyColorName.textColor),
                                Text(
                                  '${widget.model.dropAddress}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: AppTheme.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: MyColorName.textColor1),
                                ),
                              ],
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),

                          // ListTile(
                          //   horizontalTitleGap: 0,
                          //   leading: Icon(
                          //     Icons.navigation,
                          //     color: theme.primaryColor,
                          //     size: 20,
                          //   ),
                          //   title: Text(
                          //     '${widget.model.dropAddress}',
                          //     style:
                          //         TextStyle(fontWeight: FontWeight.w500),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    ///Payment via
                    /*Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: theme.backgroundColor,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            child: Row(
                              children: [
                                RowItem(
                                    'PAYMENT_VIA',
                                    '${widget.model.transaction}',
                                    Icons.account_balance_wallet),
                                Spacer(),
                                RowItem(
                                    'RIDE_FARE',
                                    '\u{20B9} ${widget.model.amount}',
                                    Icons.account_balance_wallet),
                                Spacer(),
                                RowItem(
                                    'RIDE_TYPE',
                                    '${widget.model.bookingType}',
                                    Icons.drive_eta),
                              ],
                            ),
                          ),*/

                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      // margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColorName.greyBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                  '${getTranslated(context, "TRIP_ID")}',
                                  style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    fontSize: 12,
                                      fontFamily: AppTheme.fontFamily,
                                  color: MyColorName.textColor,
                                  )),
                              Text(
                                ' - ${widget.model.uneaqueId.toString()}',
                                  style:TextStyle(
                                      fontSize: 13,
                                      fontFamily:AppTheme.fontFamily,
                                      fontWeight: FontWeight.w500
                                  ),
                              ),
                              Spacer(),
                              Text(
                                "${widget.model.distance.toString()} Kms",
                                //style: theme.textTheme.bodyMedium,
                                style:TextStyle(
                                  fontSize: 13,
                                  fontFamily:AppTheme.fontFamily,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${getDate(widget.model.dateAdded)}',
                            style:TextStyle(
                              fontSize: 13,
                              fontFamily:AppTheme.fontFamily,
                              fontWeight: FontWeight.w500
                          ),
                            overflow: TextOverflow.ellipsis,
                          ),


                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text('User Detail: ',
                          //       style: TextStyle(fontWeight: FontWeight.bold)),
                          // ),
                          // boxHeight(6),
                          // Row(
                          //   children: [
                          //     Align(
                          //       alignment: Alignment.centerLeft,
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text("Name",
                          //               style: TextStyle(
                          //                   fontWeight: FontWeight.bold)),
                          //           Text(
                          //             name,
                          //             overflow: TextOverflow.ellipsis,
                          //             style: TextStyle(color: Colors.grey),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 100,
                          //     ),
                          //     Align(
                          //       alignment: Alignment.centerLeft,
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text("Number",
                          //               style: TextStyle(
                          //                   fontWeight: FontWeight.bold)),
                          //           Text(
                          //             mobile != "" ? mobile.toString() : "",
                          //             overflow: TextOverflow.ellipsis,
                          //             style: TextStyle(color: Colors.grey),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Convert assignedFor to an integer safely
                    (int.tryParse(widget.model.assignedFor ?? '') != null &&
                            int.parse(widget.model.assignedFor!) > 0)
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: MyColorName.greyBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Driver Detail: ',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.verified_outlined,
                                      color: Colors.green,
                                    )
                                  ],
                                ),
                                boxHeight(6),
                                Row(
                                  children: [
                                    widget.model.driverImage == ''
                                        ? SizedBox()
                                        : Image.network(
                                            widget.model.driverImage ?? '',
                                            width: 35,
                                            height: 35,
                                          ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Driver Name",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${widget.model.driverName}',
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 80),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Driver Number",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${widget.model.driverContact}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedBox(height: 10),
                    SizedBox(
                      height: 10,
                    ),
                    (int.tryParse(widget.model.assignedFor ?? '') != null &&
                            int.parse(widget.model.assignedFor!) > 0)
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: MyColorName.greyBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Vehicle Detail: ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                boxHeight(6),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Vehicle Name",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${widget.model.vehicleName}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 100),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Vehicle Number",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${widget.model.vehicleNo}',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Align(
                                    //       alignment: Alignment.centerLeft,
                                    //       child: Column(
                                    //         children: [
                                    //           Text(
                                    //             "Vehicle Category",
                                    //             style: TextStyle(
                                    //                 fontWeight:
                                    //                     FontWeight.bold),
                                    //           ),
                                    //           Text(
                                    //             '${widget.model.vehicleCategory}',
                                    //             overflow: TextOverflow.ellipsis,
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedBox(height: 10),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      // margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColorName.greyBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text("Payment",
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w500,
                              textColor: MyColorName.textColor1),
                          boxHeight(8),
                          // double.parse(widget.model.baseFare.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "${getTranslated(context, "BASE_FARE")} : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //           text("₹" + widget.model.baseFare.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.km.toString()) >= 2 &&
                          //         double.parse(
                          //                 widget.model.ratePerKm.toString()) >
                          //             0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "${widget.model.km.toString()} ${getTranslated(context, "KILOMETERS")} : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" + widget.model.ratePerKm.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.timeAmount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "${widget.model.totalTime.toString()} ${getTranslated(context, "MINUTES")} : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" +
                          //                   widget.model.timeAmount.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontRegular,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),

                          // double.parse(widget.model.distance.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text("Rate per Km : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text("₹" + widget.model.price.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     text("Toll Tax : ",
                          //         fontSize: 10.sp,
                          //         fontFamily: fontMedium,
                          //         textColor: Colors.black),
                          //     widget.model.tollTax == "1"
                          //         ? text(
                          //             "${widget.model.tollTaxCharge} (Exclude)",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black)
                          //         : text("Include",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     text("State Tax : ",
                          //         fontSize: 10.sp,
                          //         fontFamily: fontMedium,
                          //         textColor: Colors.black),
                          //     widget.model.isStateTax == "1"
                          //         ? text(
                          //             "${widget.model.stateTaxCharge} (Exclude)",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black)
                          //         : text("Include",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     text("Parking: ",
                          //         fontSize: 10.sp,
                          //         fontFamily: fontMedium,
                          //         textColor: Colors.black),
                          //     widget.model.isParking == "1"
                          //         ? text("Exclude",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black)
                          //         : text("Include",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     text("Night Charge : ",
                          //         fontSize: 10.sp,
                          //         fontFamily: fontMedium,
                          //         textColor: Colors.black),
                          //     widget.model.isNightCharge == "1"
                          //         ? text(
                          //             "${widget.model.nightCharge} (Exclude)",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black)
                          //         : text("Include",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black),
                          //   ],
                          // ),
                          double.parse(widget.model.parkingCharge.toString()) >
                                  0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Parking Charge : ",
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    text(
                                        "₹" +
                                            widget.model.parkingCharge
                                                .toString(),
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black),
                                  ],
                                )
                              : SizedBox(),
                          double.parse(widget.model.tollTaxCharge.toString()) >
                                  0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("TollTax Charge : ",
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    text(
                                        "₹" +
                                            widget.model.tollTaxCharge
                                                .toString(),
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black),
                                  ],
                                )
                              : SizedBox(),

                          double.parse(widget.model.railwayAirportEntryCharge
                                      .toString()) >
                                  0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Railway/Airport Entry Charge : ",
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    text(
                                        "₹" +
                                            widget
                                                .model.railwayAirportEntryCharge
                                                .toString(),
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black),
                                  ],
                                )
                              : SizedBox(),
                          widget.model.orderType != "Hourly"
                              ? SizedBox()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Total Time : ",
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    text(
                                        widget.model.totalTime.toString() +
                                            "Hr.",
                                        fontSize: 10.sp,
                                        fontFamily: fontMedium,
                                        textColor: Colors.black),
                                  ],
                                ),
                          // : SizedBox(),

                          widget.model.km != null ||
                                  widget.model.km != "" ||
                                  widget.model.km != "0"
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Distance : ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text(widget.model.km.toString() + "Km",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )

                              : SizedBox(),
                          Divider(color: MyColorName.lineColor,thickness: 1,),
                          double.parse(widget.model.distance.toString()) > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Base fare : ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text(widget.model.subTotal.toString(),
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )
                              : SizedBox(),
                          Divider(color: MyColorName.lineColor,thickness: 1,),
                          double.parse(widget.model.extraKm.toString()) > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Extra Kilometer : ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text("₹" + widget.model.extraKm.toString(),
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )
                              : SizedBox(),
                          double.parse(widget.model.extraKmPrice.toString()) > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Extra Kilometer Price : ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text(
                                        "₹" +
                                            widget.model.extraKmPrice
                                                .toString(),
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )
                              : SizedBox(),
                          double.parse(widget.model.taxAmount.toString()) > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Taxes Fees: ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text(
                                        "₹" + widget.model.taxAmount.toString(),
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )
                              : SizedBox(),
                          Divider(color: MyColorName.lineColor,thickness: 1,),

                          double.parse(widget.model.cancel_charge.toString()) >
                                  0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    text("Last ride cancellation charge ",
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                    text(
                                        "₹" +
                                            widget.model.cancel_charge
                                                .toString(),
                                        fontSize: 13,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        textColor: MyColorName.textColor1),
                                  ],
                                )
                              : SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text("Sub Total: ",
                                  fontSize: 13,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  textColor: MyColorName.textColor1),
                              text("₹" + widget.model.ratePerKm.toString(),
                                  fontSize: 13,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  textColor: MyColorName.textColor1),
                            ],
                          ),
                          Divider(color: MyColorName.lineColor,thickness: 1,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text("Coins Used: ",
                                  fontSize: 13,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  textColor: MyColorName.textColor1),
                              text("-₹" + widget.model.pointUsed.toString(),
                                  fontSize: 13,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  textColor: MyColorName.textColor1),
                            ],
                          ),


                          // double.parse(widget.model.paidAmount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text("Advance Paid : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" +
                          //                   widget.model.paidAmount.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.paidAmount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "Remaining cash Collected By Driver : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text(
                          //             "${(double.parse(widget.model.finalAmount ?? '0') - double.parse(widget.model.paidAmount ?? '0')).toStringAsFixed(2)}",
                          //             fontSize: 10.sp,
                          //             fontFamily: fontMedium,
                          //             textColor: Colors.black,
                          //           ),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.finalAmount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text("Subtotal : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" +
                          //                   widget.model.finalAmount.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.surgeAmount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "${getTranslated(context, "SURGE")} : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" +
                          //                   widget.model.surgeAmount.toString(),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          // double.parse(widget.model.amount.toString()) > 0
                          //     ? Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           text(
                          //               "${getTranslated(context, "SUB_TOTAL")} : ",
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //           text(
                          //               "₹" +
                          //                   (double.parse(widget.model.amount
                          //                               .toString()) +
                          //                           double.parse(widget
                          //                               .model.promo_discount
                          //                               .toString()))
                          //                       .toStringAsFixed(2),
                          //               fontSize: 10.sp,
                          //               fontFamily: fontMedium,
                          //               textColor: Colors.black),
                          //         ],
                          //       )
                          //     : SizedBox(),
                          widget.model.promo_discount.toString() != ''
                              ? double.parse(widget.model.promo_discount
                                          .toString()) >
                                      0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        text(
                                            "${getTranslated(context, "PROMO")} : ",
                                            fontSize: 10.sp,
                                            fontFamily: fontRegular,
                                            textColor: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        text(
                                            "- ₹" +
                                                double.parse(
                                                  widget.model.promo_discount
                                                      .toString(),
                                                ).toStringAsFixed(2),
                                            fontSize: 10.sp,
                                            fontFamily: fontRegular,
                                            textColor: Colors.black),
                                      ],
                                    )
                                  : SizedBox()
                              : SizedBox(),
                          Divider(color: MyColorName.greyDivider),
                          // widget.model.status == "complete" ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              text(
                                  // "${getTranslated(context, "TOTAL")} : ",
                                  "Total Amount",
                                  fontSize: 15,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  textColor: MyColorName.textColor1),
                              text("₹" + "${widget.model.finalAmount}",
                                  fontSize: 15,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  textColor: MyColorName.textColor1),
                            ],
                          ),

                          // : Row(
                          //     mainAxisAlignment:
                          //         MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       text(
                          //           // "${getTranslated(context, "TOTAL")} : ",
                          //           "Total Amount",
                          //           fontSize: 12.sp,
                          //           fontFamily: fontMedium,
                          //           textColor: Colors.black),
                          //       text(
                          //           "₹" +
                          //               "${double.parse(widget.model.amount.toString()).toStringAsFixed(2)}",
                          //           fontSize: 12.sp,
                          //           fontFamily: fontMedium,
                          //           textColor: Colors.black),
                          //     ],
                          //   ),
                          // boxHeight(100),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    widget.model.status == 'complete'
                        ? InkWell(
                            onTap: () async {
                              final Uri uri = Uri.parse(
                                  'https://pristin.pristineandaman.com/api/payment/download_invoice?booking_id=${widget.model.bookingId}');
                              if (!await launchUrl(uri,
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch $uri');
                              }
                            },
                            child: Container(
                              width: 200,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: MyColorName.primaryLite,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                'Download Invoice',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
                // : SizedBox(),
              ],
            ),
          ),
        ),
        // widget.check == null ? SafeArea(
        //         child: widget.model.latitude != null &&
        //                 widget.model.latitude != ""
        //             ? Stack(
        //                 alignment: Alignment.bottomCenter,
        //                 children: [
        //                   MapPage(
        //                     true,
        //                     live: false,
        //                     pick: widget.model.pickupAddress.toString(),
        //                     dest: widget.model.dropAddress.toString(),
        //                     driveList: [],
        //                     SOURCE_LOCATION: LatLng(
        //                         double.parse(widget.model.latitude!),
        //                         double.parse(widget.model.longitude!)),
        //                     DEST_LOCATION: LatLng(
        //                         double.parse(
        //                             widget.model.dropLatitude.toString()),
        //                         double.parse(
        //                             widget.model.dropLongitude.toString())),
        //                   ),
        //                   /*!widget.model.bookingType!.contains("Point") &&
        //                             widget.model.acceptReject != "3" &&
        //                             widget.model.taxiId != null
        //                         ? Align(
        //                             alignment: Alignment.topRight,
        //                             child: InkWell(
        //                               onTap: () {
        //                                 Navigator.push(
        //                                   context,
        //                                   MaterialPageRoute(
        //                                     builder: (context) => PlacePicker(
        //                                       apiKey: Platform.isAndroid
        //                                           ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
        //                                           : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
        //                                       onPlacePicked: (result) {
        //                                         print(result.formattedAddress);
        //                                         setState(() {
        //                                           widget.model.dropAddress =
        //                                               result.formattedAddress
        //                                                   .toString();
        //                                           widget.model.dropLatitude =
        //                                               result
        //                                                   .geometry!.location.lat
        //                                                   .toString();
        //                                           widget.model.dropLongitude =
        //                                               result
        //                                                   .geometry!.location.lng
        //                                                   .toString();
        //                                           change = true;
        //                                         });
        //                                         Navigator.of(context).pop();
        //                                         getTime1(
        //                                             widget.model.latitude,
        //                                             widget.model.longitude,
        //                                             widget.model.dropLatitude,
        //                                             widget.model.dropLongitude);
        //                                       },
        //                                       initialPosition: LatLng(
        //                                           double.parse(widget
        //                                               .model.dropLatitude
        //                                               .toString()),
        //                                           double.parse(widget
        //                                               .model.dropLongitude
        //                                               .toString())),
        //                                       useCurrentLocation: true,
        //                                     ),
        //                                   ),
        //                                 );
        //                               },
        //                               child: Container(
        //                                 width: 40.w,
        //                                 height: 5.h,
        //                                 margin: EdgeInsets.all(getWidth(5)),
        //                                 decoration: boxDecoration(
        //                                     radius: 5,
        //                                     bgColor:
        //                                         Theme.of(context).primaryColor),
        //                                 child: Center(
        //                                     child: !change
        //                                         ? text(
        //                                             getTranslated(
        //                                                 context, "CHANGE_DROP")!,
        //                                             fontFamily: fontMedium,
        //                                             fontSize: 8.sp,
        //                                             isCentered: true,
        //                                             textColor: Colors.white)
        //                                         : CircularProgressIndicator(
        //                                             color: Colors.white,
        //                                           )),
        //                               ),
        //                             ),
        //                           )
        //                         : SizedBox(),*/
        //
        //                   widget.model.acceptReject != "3"
        //                       ? Align(
        //                           alignment: Alignment.topRight,
        //                           child: InkWell(
        //                             onTap: () {
        //                               if (widget.model.acceptReject == "6") {
        //                                 String url =
        //                                     "https://www.google.com/maps/dir/?api=1&origin=${latitude.toString()},${longitude.toString()}&destination=${widget.model.dropLatitude},${widget.model.dropLongitude}&travel_mode=driving&dir_action=navigate";
        //                                 print(url);
        //                                 launch(url);
        //                               } else {
        //                                 String url =
        //                                     "https://www.google.com/maps/dir/?api=1&origin=${latitude.toString()},${longitude.toString()}&destination=${driveLat},${driveLng}&travel_mode=driving&dir_action=navigate";
        //                                 print(url);
        //                                 launch(url);
        //                               }
        //                             },
        //                             child: Container(
        //                               width: 40.w,
        //                               height: 5.h,
        //                               margin: EdgeInsets.all(getWidth(5)),
        //                               decoration: boxDecoration(
        //                                   radius: 5,
        //                                   bgColor:
        //                                       Theme.of(context).primaryColor),
        //                               child: Center(
        //                                   child: !change
        //                                       ? text("Track Location",
        //                                           fontFamily: fontMedium,
        //                                           fontSize: 8.sp,
        //                                           isCentered: true,
        //                                           textColor: Colors.white)
        //                                       : CircularProgressIndicator(
        //                                           color: Colors.white,
        //                                         )),
        //                             ),
        //                           ),
        //                         )
        //                       : SizedBox(),
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       !widget.model.bookingType!.contains("Point") &&
        //                               widget.model.driverId != null
        //                           ? InkWell(
        //                               onTap: () {
        //                                 launch(
        //                                     "tel://${widget.model.driverContact}");
        //                               },
        //                               child: Container(
        //                                 width: 20.w,
        //                                 height: 4.h,
        //                                 margin: EdgeInsets.all(getWidth(5)),
        //                                 decoration: boxDecoration(
        //                                     radius: 5,
        //                                     bgColor:
        //                                         Theme.of(context).primaryColor),
        //                                 child: Center(
        //                                     child: text(
        //                                         getTranslated(context, "CALL")!,
        //                                         fontFamily: fontMedium,
        //                                         fontSize: 8.sp,
        //                                         isCentered: true,
        //                                         textColor: Colors.white)),
        //                               ),
        //                             )
        //                           : SizedBox(),
        //                       boxWidth(20),
        //                       InkWell(
        //                         onTap: () {
        //                           setState(() {
        //                             showMore = !showMore;
        //                           });
        //                         },
        //                         child: Container(
        //                           width: 20.w,
        //                           height: 4.h,
        //                           margin: EdgeInsets.all(getWidth(5)),
        //                           decoration: boxDecoration(
        //                               radius: 5,
        //                               bgColor: Theme.of(context).primaryColor),
        //                           child: Center(
        //                               child: text(
        //                                   !showMore ? "View More" : "View Less",
        //                                   fontFamily: fontMedium,
        //                                   fontSize: 8.sp,
        //                                   isCentered: true,
        //                                   textColor: Colors.white)),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ],
        //               )
        //             : SizedBox(),
        //       ) : SizedBox(),

        // bottomNavigationBar: SingleChildScrollView(
        //   child: Container(
        //     padding: EdgeInsets.all(16),
        //     color: Colors.white,
        //     height: widget.check != null
        //         ? MediaQuery.of(context).size.height - 80
        //         : null,
        //     child: Column(
        //       mainAxisSize:
        //           widget.check != null ? MainAxisSize.max : MainAxisSize.min,
        //       mainAxisAlignment: widget.check != null
        //           ? MainAxisAlignment.start
        //           : MainAxisAlignment.end,
        //       children: [
        //         /*  widget.model.promo_discount!=null&&widget.model.promo_discount!=""&&widget.model.promo_discount!="0"?AnimatedTextKit(
        //             animatedTexts: [
        //               ColorizeAnimatedText(
        //                 "Promo Discount - \u{20B9}${widget.model.promo_discount}",
        //                 textStyle: colorizeTextStyle,
        //                 colors: colorizeColors,
        //               ),
        //             ],
        //             pause: Duration(milliseconds: 100),
        //             isRepeatingAnimation: true,
        //             totalRepeatCount: 100,
        //             onTap: () {
        //               print("Tap Event");
        //             },
        //           ):SizedBox(),*/
        //         widget.model.acceptReject != "3"
        //             ? Container(
        //                 padding: EdgeInsets.all(getWidth(10)),
        //                 color: Colors.white,
        //                 child: AnimatedTextKit(
        //                   animatedTexts: [
        //                     ColorizeAnimatedText(
        //                       "Cancellation Charge ₹${widget.model.cancel_charge} will be deducted from the wallet.",
        //                       textStyle: colorizeTextStyle,
        //                       colors: colorizeColors,
        //                     ),
        //                   ],
        //                   pause: Duration(milliseconds: 100),
        //                   isRepeatingAnimation: true,
        //                   totalRepeatCount: 100,
        //                   onTap: () {
        //                     print("Tap Event");
        //                   },
        //                 ),
        //               )
        //             : SizedBox(),
        //         Text(
        //           widget.model.acceptReject == "6"
        //               ? "Trip End OTP : ${widget.model.bookingOtp}"
        //               : "Start OTP : ${widget.model.bookingOtp}",
        //         ),
        //         boxHeight(2.h),
        //         // Text("OTP : ${widget.model.otp.toString()}"),
        //         showMore
        //             ? Column(
        //                 children: [
        //                   Container(
        //                     padding: EdgeInsets.symmetric(vertical: 16),
        //                     // margin: EdgeInsets.symmetric(horizontal: 16),
        //                     decoration: BoxDecoration(
        //                         color: theme.backgroundColor,
        //                       border: Border.all(color: MyColorName.greyBorder),
        //                       borderRadius: BorderRadius.circular(8),
        //                     ),
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Container(
        //                           height: 60,
        //                           padding: EdgeInsets.symmetric(horizontal: 12),
        //                           decoration: BoxDecoration(
        //                             color: theme.backgroundColor,
        //                             borderRadius: BorderRadius.circular(16),
        //                           ),
        //                           child: Row(
        //                             children: [
        //                               widget.model.driverName != null
        //                                   ? Container(
        //                                 height: 52,
        //                                 width: 52,
        //                                 child: ClipRRect(
        //                                   borderRadius: BorderRadius.circular(12),
        //                                   child: Image.network(
        //                                     imagePath +
        //                                         widget.model.driverImage.toString(),
        //                                     height: 62,
        //                                     width: 62,
        //                                   ),
        //                                 ),
        //                               )
        //                                   : SizedBox(),
        //                               SizedBox(width: 14),
        //                               Column(
        //                                 crossAxisAlignment: CrossAxisAlignment.start,
        //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   Row(
        //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                     children: [
        //                                       widget.model.driverName != null
        //                                           ? Text(
        //                                         '${widget.model.driverName}',
        //                                         style: theme.textTheme.headline6!.copyWith(
        //                                             fontSize: 18, letterSpacing: 1.2),
        //                                       )
        //                                           : SizedBox(),
        //                                       boxWidth(12.w),
        //                                       Text(
        //                                         '${getTranslated(context, "TRIP_ID")} - ${widget.model.uneaqueId.toString()}',
        //                                         style: theme.textTheme.bodyText1,
        //                                       ),
        //                                     ],
        //                                   ),
        //                                   Column(
        //                                     crossAxisAlignment: CrossAxisAlignment.start,
        //                                     children: [
        //                                       /* Text(
        //                       '${widget.model.taxiType}',
        //                       style:
        //                       theme.textTheme.caption!.copyWith(fontSize: 12),
        //                     ),*/
        //                                       // Text(
        //                                       //   getTranslated(context, "CAR_TYPE")!,
        //                                       //   style: theme.textTheme.caption,
        //                                       // ),
        //                                       // Spacer(),
        //                                       Text(
        //                                         '${widget.model.taxiType}(${widget.model.car_no})',
        //                                         style: theme.textTheme.bodyText1!
        //                                             .copyWith(fontSize: 12),
        //                                         overflow: TextOverflow.ellipsis,
        //                                       ),
        //
        //                                       Column(
        //                                         crossAxisAlignment: CrossAxisAlignment.end,
        //                                         children: [
        //                                           widget.model.rating.toString() != "null"
        //                                               ? Container(
        //                                             padding: EdgeInsets.symmetric(
        //                                                 horizontal: 6, vertical: 2),
        //                                             decoration: BoxDecoration(
        //                                               borderRadius: BorderRadius.circular(30),
        //                                               color: AppTheme.ratingsColor,
        //                                             ),
        //                                             child: Row(
        //                                               mainAxisSize: MainAxisSize.min,
        //                                               children: [
        //                                                 Text(
        //                                                   '${widget.model.rating}',
        //                                                   style: theme.textTheme.bodyText1!
        //                                                       .copyWith(fontSize: 12),
        //                                                 ),
        //                                                 SizedBox(width: 4),
        //                                                 Icon(
        //                                                   Icons.star,
        //                                                   color: AppTheme.starColor,
        //                                                   size: 10,
        //                                                 )
        //                                               ],
        //                                             ),
        //                                           )
        //                                               : SizedBox(),
        //                                           // Text(
        //                                           //   getTranslated(context, 'BOOKED_ON')!,
        //                                           //   style: theme.textTheme.caption,
        //                                           // ),
        //                                           // Spacer(),
        //                                           Text(
        //                                             '${getDate(widget.model.dateAdded)}',
        //                                             style: theme.textTheme.bodyText1!
        //                                                 .copyWith(fontSize: 12),
        //                                             overflow: TextOverflow.ellipsis,
        //                                           ),
        //                                         ],
        //                                       ),
        //                                     ],
        //                                   ),
        //                                 ],
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                         Divider(color: MyColorName.greyDivider),
        //
        //                         ///rideinfo KM
        //                         // ListTile(
        //                         //   title: Text(
        //                         //     getTranslated(context, 'RIDE_INFO')!,
        //                         //     style: theme.textTheme.headline6!.copyWith(
        //                         //         color: theme.hintColor, fontSize: 16.5),
        //                         //   ),
        //                         //   trailing: Text('${widget.model.km} km',
        //                         //       style: theme.textTheme.headline6!
        //                         //           .copyWith(fontSize: 16.5)),
        //                         // ),
        //
        //                         Padding(
        //                           padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //                           child: text("Pickup & Drop", fontSize: 16, fontWeight: FontWeight.w700, textColor: Colors.black),
        //                         ),
        //                         ListTile(
        //                           horizontalTitleGap: 0,
        //                           leading: Icon(Icons.location_on_rounded, color: Colors.green),
        //                           title: Column(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             children: [
        //                               text(
        //                                   "Pickup Location",
        //                                   fontSize: 12.sp,
        //                                   fontFamily: fontRegular,
        //                                   textColor: Colors.grey
        //                               ),
        //                               Text(
        //                                 '${widget.model.pickupAddress}',
        //                                 style: TextStyle(
        //                                     fontSize: 12.sp,
        //                                     fontWeight: FontWeight.w500),
        //                               ),
        //                             ],
        //                           ),
        //                           dense: true,
        //                           tileColor: theme.cardColor,
        //                         ),
        //                         ListTile(
        //                           horizontalTitleGap: 0,
        //                           leading: Icon(Icons.location_on_rounded, color: Colors.red),
        //                           title: Column(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             children: [
        //                               text(
        //                                   "Drop Location",
        //                                   fontSize: 12.sp,
        //                                   fontFamily: fontRegular,
        //                                   textColor: Colors.grey
        //                               ),
        //                               Text(
        //                                 '${widget.model.dropAddress}',
        //                                 style: TextStyle(
        //                                     fontSize: 12.sp,
        //                                     fontWeight: FontWeight.w500),
        //                               ),
        //                             ],
        //                           ),
        //                           dense: true,
        //                           tileColor: theme.cardColor,
        //                         ),
        //
        //                         // ListTile(
        //                         //   horizontalTitleGap: 0,
        //                         //   leading: Icon(
        //                         //     Icons.navigation,
        //                         //     color: theme.primaryColor,
        //                         //     size: 20,
        //                         //   ),
        //                         //   title: Text(
        //                         //     '${widget.model.dropAddress}',
        //                         //     style:
        //                         //         TextStyle(fontWeight: FontWeight.w500),
        //                         //   ),
        //                         // ),
        //                       ],
        //                     ),
        //                   ),
        //                   SizedBox(height: 12),
        //
        //                   ///Payment via
        //                   /*Container(
        //                     padding: EdgeInsets.all(16),
        //                     decoration: BoxDecoration(
        //                         color: theme.backgroundColor,
        //                         borderRadius: BorderRadius.vertical(
        //                             top: Radius.circular(16))),
        //                     child: Row(
        //                       children: [
        //                         RowItem(
        //                             'PAYMENT_VIA',
        //                             '${widget.model.transaction}',
        //                             Icons.account_balance_wallet),
        //                         Spacer(),
        //                         RowItem(
        //                             'RIDE_FARE',
        //                             '\u{20B9} ${widget.model.amount}',
        //                             Icons.account_balance_wallet),
        //                         Spacer(),
        //                         RowItem(
        //                             'RIDE_TYPE',
        //                             '${widget.model.bookingType}',
        //                             Icons.drive_eta),
        //                       ],
        //                     ),
        //                   ),*/
        //
        //                   Container(
        //                     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        //                     // margin: EdgeInsets.symmetric(horizontal: 16),
        //                     decoration: BoxDecoration(
        //                       border: Border.all(color: MyColorName.greyBorder),
        //                       borderRadius: BorderRadius.circular(8),
        //                     ),
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         text("Payment", fontSize: 16, fontWeight: FontWeight.w700, textColor: Colors.black),
        //                         boxHeight(8),
        //                         double.parse(widget.model.baseFare.toString()) >
        //                                 0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${getTranslated(context, "BASE_FARE")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           widget.model.baseFare
        //                                               .toString(),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         double.parse(widget.model.km.toString()) >= 2 &&
        //                                 double.parse(widget.model.ratePerKm
        //                                         .toString()) >
        //                                     0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${widget.model.km.toString()} ${getTranslated(context, "KILOMETERS")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           widget.model.ratePerKm
        //                                               .toString(),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         double.parse(widget.model.timeAmount
        //                                     .toString()) >
        //                                 0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${widget.model.totalTime.toString()} ${getTranslated(context, "MINUTES")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           widget.model.timeAmount
        //                                               .toString(),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontRegular,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         double.parse(
        //                                     widget.model.gstAmount.toString()) >
        //                                 0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${getTranslated(context, "TAXES")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           widget.model.gstAmount
        //                                               .toString(),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         double.parse(widget.model.surgeAmount
        //                                     .toString()) >
        //                                 0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${getTranslated(context, "SURGE")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           widget.model.surgeAmount
        //                                               .toString(),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         double.parse(widget.model.amount.toString()) > 0
        //                             ? Row(
        //                                 mainAxisAlignment:
        //                                     MainAxisAlignment.spaceBetween,
        //                                 children: [
        //                                   text(
        //                                       "${getTranslated(context, "SUB_TOTAL")} : ",
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                   text(
        //                                       "₹" +
        //                                           (double.parse(widget
        //                                                       .model.amount
        //                                                       .toString()) +
        //                                                   double.parse(widget
        //                                                       .model
        //                                                       .promo_discount
        //                                                       .toString()))
        //                                               .toStringAsFixed(2),
        //                                       fontSize: 10.sp,
        //                                       fontFamily: fontMedium,
        //                                       textColor: Colors.black),
        //                                 ],
        //                               )
        //                             : SizedBox(),
        //                         widget.model.promo_discount.toString() != ''
        //                             ? double.parse(widget.model.promo_discount
        //                                         .toString()) >
        //                                     0
        //                                 ? Row(
        //                                     mainAxisAlignment:
        //                                         MainAxisAlignment.spaceBetween,
        //                                     children: [
        //                                       text(
        //                                           "${getTranslated(context, "PROMO")} : ",
        //                                           fontSize: 10.sp,
        //                                           fontFamily: fontRegular,
        //                                           textColor: Colors.black),
        //                                       text(
        //                                           "- ₹" +
        //                                               double.parse(widget.model
        //                                                       .promo_discount
        //                                                       .toString())
        //                                                   .toStringAsFixed(2),
        //                                           fontSize: 10.sp,
        //                                           fontFamily: fontRegular,
        //                                           textColor: Colors.black),
        //                                     ],
        //                                   )
        //                                 : SizedBox()
        //                             : SizedBox(),
        //                         Divider(color: MyColorName.greyDivider),
        //                         Row(
        //                           mainAxisAlignment:
        //                               MainAxisAlignment.spaceBetween,
        //                           children: [
        //                             text(
        //                                 // "${getTranslated(context, "TOTAL")} : ",
        //                                 "Total Amount",
        //                                 fontSize: 12.sp,
        //                                 fontFamily: fontMedium,
        //                                 textColor: Colors.black),
        //                             text(
        //                                 "₹" +
        //                                     "${double.parse(widget.model.amount.toString()).toStringAsFixed(2)}",
        //                                 fontSize: 12.sp,
        //                                 fontFamily: fontMedium,
        //                                 textColor: Colors.black),
        //                           ],
        //                         ),
        //                         boxHeight(10),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               )
        //             : SizedBox(),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }

  final colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w900,
    fontFamily: 'Inter',
  );
}
