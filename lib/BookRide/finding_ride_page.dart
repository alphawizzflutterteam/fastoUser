import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pristine_andaman/BookRide/map.dart';
import 'package:pristine_andaman/BookRide/ride_booked_page.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/PushNotificationService.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

import '../bottom_nav_screen.dart';

class FindingRidePage extends StatefulWidget {
  LatLng source, destination;
  String pickAddress, dropAddress, paymentType, bookingId;
  String amount, km;
  bool from;
  FindingRidePage(this.source, this.destination, this.pickAddress,
      this.dropAddress, this.paymentType, this.bookingId, this.amount, this.km,
      {this.from = false});
  @override
  _FindingRidePageState createState() => _FindingRidePageState();
}

class _FindingRidePageState extends State<FindingRidePage>
    with SingleTickerProviderStateMixin {
  final List<double> sizes = [120, 160, 200];

  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )
      ..repeat()
      ..addListener(() {});
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    PushNotificationService pushNotificationService =
        new PushNotificationService(
            context: context,
            onResult: (result) {
              //  if(mounted&&result=="yes")

              if (result == "accept") {
                if (!widget.from) {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SearchLocationPage(),));
                  // Navigator.pop(context);
                }
                // Navigator.pop(context, "yes2");
                getCurrentInfo();
              }
            });
    pushNotificationService.initialise();
    //   if(mounted)
    /* Future.delayed(Duration(seconds: 4),
        () => Navigator.pushNamed(context, PageRoutes.rideBookedPage));*/
  }

  bool loading = true;
  bool saveStatus = true;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  MyRideModel? model1;

  getCurrentInfo() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_current_boooking"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var v = response["data"];

        model1 = MyRideModel.fromJson(v);
        /* Navigator.popUntil(
          context,
          ModalRoute.withName('/'),
        );*/
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => RideBookedPage(model1!)));
        /* showConfirm(RidesModel(v['id'], v['user_id'], v['username'], v['uneaque_id'], v['purpose'], v['pickup_area'],
            v['pickup_date'], v['drop_area'], v['pickup_time'], v['area'], v['landmark'], v['pickup_address'], v['drop_address'],
            v['taxi_type'], v['departure_time'], v['departure_date'], v['return_date'], v['flight_number'], v['package'],
            v['promo_code'], v['distance'], v['amount'], v['paid_amount'], v['address'], v['transfer'], v['item_status'],
            v['transaction'], v['payment_media'], v['km'], v['timetype'], v['assigned_for'], v['is_paid_advance'], v['status'], v['latitude'], v['longitude'], v['date_added'],
            v['drop_latitude'], v['drop_longitude'], v['booking_type'], v['accept_reject'], v['created_date']));*/

        //print(data);
      } else {
        // UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          getTranslated(context, "FINDING_RIDE")!,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          ///Map
          latitude != 0
              ? MapPage(
                  true,
                  pick: widget.pickAddress,
                  dest: widget.dropAddress,
                  driveList: [],
                  SOURCE_LOCATION: widget.source,
                  DEST_LOCATION: widget.destination,
                  live: false,
                )
              : Center(child: CircularProgressIndicator(color: Colors.black)),

          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.center,
              children: sizes
                  .map((element) => CircleAvatar(
                        radius: element * _animation.value,
                        backgroundColor: Theme.of(context)
                            .primaryColor
                            .withOpacity(1 - _animation.value as double),
                      ))
                  .toList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(getWidth(20)),
              padding: EdgeInsets.all(getWidth(10)),
              decoration: boxDecoration(
                  radius: 5, bgColor: Colors.white, showShadow: true),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  boxHeight(10),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration:
                            boxDecoration(radius: 100, bgColor: Colors.green),
                      ),
                      boxWidth(10),
                      Expanded(
                          child: text(widget.pickAddress,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration:
                            boxDecoration(radius: 100, bgColor: Colors.red),
                      ),
                      boxWidth(10),
                      Expanded(
                          child: text(widget.dropAddress,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text("${getTranslated(context, "AMOUNT")} ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("₹" + widget.amount,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("|",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("${getTranslated(context, "DISTANCE")} ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(widget.km + " km",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(20),
                  LinearProgressIndicator(),
                  boxHeight(20),
                  InkWell(
                    onTap: () {
                      cancelRide(widget.bookingId);
                    },
                    child: Container(
                      width: 75.w,
                      height: 6.h,
                      decoration: boxDecoration(
                          radius: 10, bgColor: Theme.of(context).primaryColor),
                      child: Center(
                        child: text(getTranslated(context, "CANCEL_RIDE")!,
                            fontFamily: fontMedium,
                            fontSize: 12.sp,
                            isCentered: true,
                            textColor: Colors.white),
                      ),
                    ),
                  ),
                  boxHeight(30)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ApiBaseHelper apiBaseHelper = new ApiBaseHelper();
  cancelRide(bookingId) async {
    Map data = {
      "booking_id": bookingId,
    };
    print("CANCEL RIDE ======= $data");
    Map response = await apiBaseHelper.postAPICall(
        Uri.parse(baseUrl1 + "payment/cancel_ride"), data);
    if (response['status']) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNavScreen()));
      UI.setSnackBar("Booking Cancelled", context);
    } else {}
  }
}
