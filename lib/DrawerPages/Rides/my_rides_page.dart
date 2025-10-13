import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pristine_andaman/BookRide/rate_ride_dialog.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/DrawerPages/Rides/ride_info_page.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/Model/reason_model.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/PushNotificationService.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

// import 'package:social_share/social_share.dart';

import '../../utils/constant.dart';

class MyRidesPage extends StatefulWidget {
  String type;
  bool? fromWhere;

  MyRidesPage(this.type, {this.fromWhere});

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = true;
  bool loading1 = true;
  bool shareLoading = true;
  List<MyRideModel> rideList = [];

  String? _currentAddress;
  Position? _currentPosition;
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    // Get the address
  }

  getRides(type, status) async {
    try {
      setState(() {
        loading = true;
      });
      Map params = {
        "user_id": curUserId,
        "type": type, //"type": '1',
        "status": status
      };
      print("ALL COMPLETE RIDE PARAM ====== $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_all_complete_user"), params);
      setState(() {
        loading = false;
        rideList.clear();
        _globalKey.clear();
        if (type == "1") {
          // selected = 0;
        }
      });
      if (response['status']) {
        print(response['data']);
        for (var v in response['data']) {
          setState(() {
            rideList.add(MyRideModel.fromJson(v));
            _globalKey.add(new GlobalKey());
          });
        }
      } else {
        // UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PushNotificationService notificationService = new PushNotificationService(
        context: context,
        onResult: (result) {
          if (mounted) if (selected == 0) {
            // getRides("3");
          } else if (selected == 1) {
            // getRides("1");
          } else {
            // getRides("0");
          }
          if (result == "com") {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RateRideDialog(rideList[0]),
            );
          }
        });
    notificationService.initialise();
    getReason();

    // getRides(widget.type, "pending");
    getRides("1", "pending");
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

    return Future.value();
  }

  int selected = 1;
  List<String> filter = ["All", "Today", "Weekly", "Monthly"];
  String selectedFil = "All";

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return ' '; // Handle null or empty input
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time); // Parse input time
      return DateFormat("hh:mm a")
          .format(parsedTime); // Format to hh:mm a (04:00 PM)
    } catch (e) {
      return 'Invalid Time'; // Handle parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 4, // controls shadow height
          shadowColor: Colors.black.withOpacity(0.2),
          backgroundColor: MyColorName.colorBg1,
          leading: widget.fromWhere == true
              ? SizedBox()
              : InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
          title: Text(
            // getTranslated(context, "MY_RIDES")??"My Rides",
            "My Rides",
            style: TextStyle(
              fontSize: 22,
              fontFamily: AppTheme.fontFamily,
              color: MyColorName.secondary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              //   width: getWidth(375),
              //   child: Text(
              //     getTranslated(context, 'LIST_OF_RIDES')!,
              //     style: theme.textTheme.bodyText2!
              //         .copyWith(color: theme.hintColor, fontSize: 12),
              //   ),
              // ),
              ///Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 40,
                decoration: boxDecoration(
                  bgColor: MyColorName.colorBg1,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selected = 1;
                          });
                          getRides("1", "upcoming");
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          height: getHeight(50),
                          width: getWidth(85),
                          decoration: selected == 1
                              ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(52, 61, 164, 139),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xff7DBF04),
                                )
                              : BoxDecoration(),
                          child: Center(
                            child: text(
                              getTranslated(context, "UPCOMING")!,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: selected == 1
                                  ? Colors.white
                                  : MyColorName.secondary,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selected = 0;
                          });
                          getRides("1", "accept");
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          height: getHeight(50),
                          width: getWidth(85),
                          decoration: selected == 0
                              ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(52, 61, 164, 139),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xff7DBF04),
                                )
                              : BoxDecoration(),
                          child: Center(
                            child: text(
                              "Accepted",
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: selected == 0
                                  ? Colors.white
                                  : MyColorName.secondary,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selected = 2;
                          });
                          getRides("1", "complete");
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          height: getHeight(40),
                          width: getWidth(90),
                          decoration: selected == 2
                              ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(52, 61, 164, 139),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xff7DBF04),
                                )
                              : BoxDecoration(),
                          child: Center(
                            child: text(
                              getTranslated(context, "COMPLETED")!,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: selected == 2
                                  ? Colors.white
                                  : MyColorName.secondary,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selected = 3;
                          });
                          getRides("1", "cancel");
                        },
                        child: Container(
                          height: getHeight(40),
                          width: getWidth(90),
                          decoration: selected == 3
                              ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(52, 61, 164, 139),
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xff7DBF04),
                                )
                              : BoxDecoration(),
                          child: Center(
                            child: text(
                              "Cancelled",
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: selected == 3
                                  ? Colors.white
                                  : MyColorName.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              boxHeight(19),

              ///filter
              // Wrap(
              //   spacing: 3.w,
              //   children: filter.map((e) {
              //     return InkWell(
              //       onTap: () {
              //         setState(() {
              //           selectedFil = e.toString();
              //         });
              //         var now = new DateTime.now();
              //         var now_1w = now.subtract(Duration(days: 7));
              //         var now_1m =
              //             new DateTime(now.year, now.month - 1, now.day);
              //         if (selectedFil == "Today") {
              //           for (int i = 0; i < rideList.length; i++) {
              //             DateTime date = DateTime.parse(
              //                 rideList[i].createdDate.toString());
              //             if (now.day == date.day && now.month == date.month) {
              //               setState(() {
              //                 rideList[i].show = true;
              //               });
              //             } else {
              //               setState(() {
              //                 rideList[i].show = false;
              //               });
              //             }
              //           }
              //         }
              //         if (selectedFil == "Weekly") {
              //           for (int i = 0; i < rideList.length; i++) {
              //             DateTime date = DateTime.parse(
              //                 rideList[i].createdDate.toString());
              //             if (now_1w.isBefore(date)) {
              //               setState(() {
              //                 rideList[i].show = true;
              //               });
              //             } else {
              //               setState(() {
              //                 rideList[i].show = false;
              //               });
              //             }
              //           }
              //         }
              //         if (selectedFil == "Monthly") {
              //           for (int i = 0; i < rideList.length; i++) {
              //             DateTime date = DateTime.parse(
              //                 rideList[i].createdDate.toString());
              //             if (now_1m.isBefore(date)) {
              //               setState(() {
              //                 rideList[i].show = true;
              //               });
              //             } else {
              //               setState(() {
              //                 rideList[i].show = false;
              //               });
              //             }
              //           }
              //         }
              //         if (selectedFil == "All") {
              //           for (int i = 0; i < rideList.length; i++) {
              //             setState(() {
              //               rideList[i].show = true;
              //             });
              //           }
              //         }
              //       },
              //       child: Chip(
              //         side: BorderSide(color: MyColorName.primaryLite),
              //         backgroundColor: selectedFil == e
              //             ? MyColorName.primaryLite
              //             : Colors.transparent,
              //         shadowColor: Colors.transparent,
              //         label: text(e,
              //             fontFamily: fontMedium,
              //             fontSize: 10.sp,
              //             textColor:
              //                 selected == e ? Colors.white : Colors.black),
              //       ),
              //     );
              //   }).toList(),
              // ),
              // boxHeight(19),
              !loading
                  ? rideList.length > 0
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: rideList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                              // rideList[index].status !="Cancelled" &&
                              rideList[index].show!
                                  ? GestureDetector(
                                      onTap: () async {
                                        print(
                                            "dsaaaaaaaaaa ${rideList[index].status}");
                                        var result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RideInfoPage(
                                              rideList[index],
                                              check: rideList[index]
                                                          .acceptReject !=
                                                      "3"
                                                  ? null
                                                  : "yes",
                                            ),
                                          ),
                                        );
                                        if (result != null) {
                                          // selected == 0 ? getRides("3") : getRides("1");
                                        }
                                        if (rideList[index].acceptReject !=
                                            "3") {}
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            // showShadow: true,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: MyColorName.greyBorder)),
                                        margin: EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            bottom: 12.0),
                                        child: Column(
                                          children: [
                                            RepaintBoundary(
                                              key: _globalKey[index],
                                              child: Container(
                                                decoration: boxDecoration(
                                                    bgColor: Colors.white,
                                                    radius: 10),
                                                child: Column(
                                                  children: [
                                                    // Container(
                                                    //   height: 100,
                                                    //   padding: EdgeInsets.symmetric(
                                                    //       vertical: 12,
                                                    //       horizontal: 14),
                                                    //   child: Row(
                                                    //     children: [
                                                    //       rideList[index].driverName !=null
                                                    //           ? Container(
                                                    //               height: 60,
                                                    //               width: 60,
                                                    //               child: ClipRRect(
                                                    //                 borderRadius:
                                                    //                     BorderRadius
                                                    //                         .circular(
                                                    //                             10),
                                                    //                 child: Image.network(imagePath +
                                                    //                     rideList[
                                                    //                             index]
                                                    //                         .driverImage
                                                    //                         .toString()),
                                                    //               ),
                                                    //             )
                                                    //           : SizedBox(),
                                                    //       SizedBox(width: 8),
                                                    //       Expanded(
                                                    //         flex: 2,
                                                    //         child: Column(
                                                    //           crossAxisAlignment:
                                                    //               CrossAxisAlignment
                                                    //                   .start,
                                                    //           children: [
                                                    //             rideList[index]
                                                    //                 .driverName !=
                                                    //                 null
                                                    //                 ? Row(
                                                    //               children: [
                                                    //                 Expanded(
                                                    //                   child: Text(
                                                    //                     '${rideList[index].driverName}',
                                                    //                     style: theme
                                                    //                         .textTheme
                                                    //                         .bodyText2,
                                                    //                   ),
                                                    //                 ),
                                                    //
                                                    //                 ///Call
                                                    //                 // InkWell(
                                                    //                 //     onTap:
                                                    //                 //         () {
                                                    //                 //       showDialog(context: context, builder: (context)=>AlertDialog(
                                                    //                 //         title: Text("Confirmation"),
                                                    //                 //         content: Text("Do you want to confirm call?"),
                                                    //                 //         actions: [
                                                    //                 //           TextButton(onPressed: (){
                                                    //                 //             Navigator.pop(context);
                                                    //                 //           }, child: Text("Cancel")),
                                                    //                 //           TextButton(onPressed: (){
                                                    //                 //             Navigator.pop(context);
                                                    //                 //             launch(
                                                    //                 //                 "tel://${rideList[index].driverContact}");
                                                    //                 //           }, child: Text("Confirm")),
                                                    //                 //         ],
                                                    //                 //       ));
                                                    //                 //     },
                                                    //                 //     child: Icon(Icons
                                                    //                 //         .call,color: AppTheme.primaryColor,)),
                                                    //               ],
                                                    //             )
                                                    //                 : Text(
                                                    //               '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                    //               style: theme
                                                    //                   .textTheme
                                                    //                   .bodyText1,
                                                    //             ),
                                                    //             rideList[index]
                                                    //                         .driverName !=
                                                    //                     null
                                                    //                 ? Text(
                                                    //                     '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                    //                     style: theme
                                                    //                         .textTheme
                                                    //                         .bodyText1,
                                                    //                   )
                                                    //                 : SizedBox(),
                                                    //             Spacer(flex: 2),
                                                    //             Container(
                                                    //               width:
                                                    //                   getWidth(150),
                                                    //               child: Text(
                                                    //                 '${rideList[index].taxiType}(${rideList[index].car_no})\n${rideList[index].dateAdded}',
                                                    //                 maxLines: 3,
                                                    //                 overflow:
                                                    //                     TextOverflow
                                                    //                         .ellipsis,
                                                    //                 style: theme
                                                    //                     .textTheme
                                                    //                     .caption,
                                                    //               ),
                                                    //             ),
                                                    //           ],
                                                    //         ),
                                                    //       ),
                                                    //       SizedBox(width: 8),
                                                    //       Expanded(
                                                    //         flex: 1,
                                                    //         child: Column(
                                                    //           crossAxisAlignment:
                                                    //               CrossAxisAlignment
                                                    //                   .end,
                                                    //           children: [
                                                    //             Text(
                                                    //               '\u{20B9}${rideList[index].amount}',
                                                    //               style: theme
                                                    //                   .textTheme
                                                    //                   .bodyText2!
                                                    //                   .copyWith(
                                                    //                       color: theme
                                                    //                           .primaryColor),
                                                    //             ),
                                                    //             Spacer(flex: 2),
                                                    //             Text(
                                                    //               "${rideList[index].transaction}" +
                                                    //                   '\n' +
                                                    //                   "${rideList[index].bookingType}",
                                                    //               textAlign:
                                                    //                   TextAlign.right,
                                                    //               style: theme
                                                    //                   .textTheme
                                                    //                   .caption,
                                                    //             ),
                                                    //           ],
                                                    //         ),
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                    Container(
                                                      height: 60,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 10),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Container(
                                                              //   height: 50,
                                                              //   width: 50,
                                                              //   child:
                                                              //       ClipRRect(
                                                              //     borderRadius:
                                                              //         BorderRadius
                                                              //             .circular(
                                                              //                 10),
                                                              //     child: Image.network(rideList[
                                                              //             index]
                                                              //         .vehicleImage
                                                              //         .toString()),
                                                              //   ),
                                                              // ),

                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // Text(
                                                                  //   '${rideList[index].driverName}',
                                                                  //   style: theme
                                                                  //       .textTheme
                                                                  //       .bodyText2,
                                                                  // ),

                                                                  Text(
                                                                      '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14)),
                                                                  // Text(
                                                                  //   '${rideList[index].taxiType}',
                                                                  //   maxLines: 3,
                                                                  //   overflow:
                                                                  //       TextOverflow
                                                                  //           .ellipsis,
                                                                  //   style: theme
                                                                  //       .textTheme
                                                                  //       .bodyMedium
                                                                  //       ?.copyWith(
                                                                  //           fontSize:
                                                                  //               14),
                                                                  // ),
                                                                  // rideList[index]
                                                                  //             .status ==
                                                                  //         "complete" ?
                                                                  Text(
                                                                    "\u{20B9}${rideList[index].finalAmount}",
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            color:
                                                                                theme.primaryColor),
                                                                  )
                                                                  // : Text(
                                                                  //     '\u{20B9}${rideList[index].amount}',
                                                                  //     style: theme
                                                                  //         .textTheme
                                                                  //         .bodyText2!
                                                                  //         .copyWith(
                                                                  //             color: theme.primaryColor),
                                                                  //   ),
                                                                ],
                                                              ),
                                                              Spacer(),
                                                              Column(
                                                                children: [
                                                                  rideList[index].orderType ==
                                                                              "null" ||
                                                                          rideList[index].orderType ==
                                                                              ""
                                                                      ? Text(
                                                                          "One-Way",
                                                                          style: theme
                                                                              .textTheme
                                                                              .bodyMedium
                                                                              ?.copyWith(fontSize: 16, color: Colors.black),
                                                                        )
                                                                      : Text(
                                                                          "${rideList[index].orderType}",
                                                                          style: theme
                                                                              .textTheme
                                                                              .bodyMedium
                                                                              ?.copyWith(fontSize: 16, color: Colors.black),
                                                                        ),
                                                                  Text(
                                                                    '${rideList[index].status}',
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyMedium
                                                                        ?.copyWith(
                                                                      fontSize:
                                                                          16,
                                                                      color: rideList[index].status ==
                                                                              "Cancelled"
                                                                          ? Colors
                                                                              .red
                                                                          : rideList[index].status == "pending"
                                                                              ? Colors.orange
                                                                              : rideList[index].status == "accept"
                                                                                  ? Colors.green
                                                                                  : AppTheme.secondaryColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          // SizedBox(
                                                          //   height: 4,
                                                          // ),
                                                          // Row(
                                                          //   mainAxisAlignment:
                                                          //       MainAxisAlignment
                                                          //           .end,
                                                          //   children: [
                                                          //     // Text(
                                                          //     //   "${rideList[index].vehicleName.toString()}",
                                                          //     //   style: theme
                                                          //     //       .textTheme
                                                          //     //       .bodyText1,
                                                          //     // ),
                                                          //
                                                          //     // Text(
                                                          //     //   '${getTranslated(context, "TRIP_ID")} - ${rideList[index].uneaqueId.toString()}',
                                                          //     //   style: theme
                                                          //     //       .textTheme
                                                          //     //       .bodyMedium,
                                                          //     // ),
                                                          //     // Spacer(flex: 2),
                                                          //     // Container(
                                                          //     //   width:
                                                          //     //       getWidth(150),
                                                          //     //   child: Text(
                                                          //     //     '${rideList[index].taxiType}\n${rideList[index].dateAdded}',
                                                          //     //     maxLines: 3,
                                                          //     //     overflow:
                                                          //     //         TextOverflow
                                                          //     //             .ellipsis,
                                                          //     //     style: theme
                                                          //     //         .textTheme
                                                          //     //         .caption,
                                                          //     //   ),
                                                          //     // ),
                                                          //   ],
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          //
                                                          // Text(
                                                          //   rideList[index]
                                                          //       .vehicleCategory
                                                          //       .toString(),
                                                          //   style: theme
                                                          //       .textTheme
                                                          //       .bodyText1,
                                                          // ),
                                                          // Text(
                                                          //   "${rideList[index].seatingCapacity.toString()} Seats",
                                                          //   style: theme
                                                          //       .textTheme
                                                          //       .bodyText1,
                                                          // ),
                                                          if (rideList[index]
                                                                  .status !=
                                                              'complete')
                                                            Text(
                                                              rideList[index]
                                                                          .acceptReject ==
                                                                      "6"
                                                                  ? "Trip End OTP : ${rideList[index].bookingOtp.toString()}"
                                                                  : "Start OTP : ${rideList[index].bookingOtp.toString()}",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 12),
                                                            ),
                                                          Spacer(),
                                                          Text(
                                                              "${rideList[index].distance.toString()} Kms",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                          // rideList[index]
                                                          //             .status ==
                                                          //         'complete'
                                                          //     ? InkWell(
                                                          //         onTap:
                                                          //             () async {
                                                          //           await _getCurrentLocation();
                                                          //           String
                                                          //               googleMapsUrl =
                                                          //               "https://www.google.com/maps?q=${_currentPosition?.latitude},${_currentPosition?.longitude}";
                                                          //           String
                                                          //               shareMessage =
                                                          //               'Pickup Address: ${rideList[index].pickupAddress}\n'
                                                          //               'Drop Address: ${rideList[index].dropAddress}\n'
                                                          //               'Driver Name: ${rideList[index].driverName}\n'
                                                          //               'Driver Mobile No.: ${rideList[index].driverContact}\n'
                                                          //               'Navigate to location: $googleMapsUrl';
                                                          //
                                                          //           Share.share(
                                                          //               shareMessage,
                                                          //               subject:
                                                          //                   'Ride Information');
                                                          //         },
                                                          //         child: Icon(
                                                          //             Icons
                                                          //                 .share,
                                                          //             color: Colors
                                                          //                 .black),
                                                          //       )
                                                          //     : SizedBox()
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Text(
                                                                //   "Fuel Type",
                                                                //   style: theme
                                                                //       .textTheme
                                                                //       .bodyText1,
                                                                // ),
                                                                rideList[index].extraKmPrice ==
                                                                            null ||
                                                                        rideList[index].extraKmPrice ==
                                                                            '0.00'
                                                                    ? SizedBox()
                                                                    : Text(
                                                                        "Extra km fare",
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                      ),
                                                                // Text(
                                                                //   "Luggage Carrier",
                                                                //   style: theme
                                                                //       .textTheme
                                                                //       .bodyText1,
                                                                // ),
                                                                rideList[index]
                                                                            .luggageCapacity ==
                                                                        null
                                                                    ? SizedBox()
                                                                    : Text(
                                                                        "Luggage Capacity",
                                                                        style: theme
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                      ),
                                                                // Text("Insurance Expiry",
                                                                //     style: Theme.of(context)
                                                                //         .textTheme
                                                                //         .bodyText2!
                                                                //         .copyWith(
                                                                //         fontSize: 12,
                                                                //         fontWeight:
                                                                //         FontWeight.bold)),
                                                                // Text("Pollution Expiry",
                                                                //     style: Theme.of(context)
                                                                //         .textTheme
                                                                //         .bodyText2!
                                                                //         .copyWith(
                                                                //         fontSize: 12,
                                                                //         fontWeight:
                                                                //         FontWeight.bold)),
                                                              ]),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Text(
                                                              //   rideList[index]
                                                              //       .fuelType
                                                              //       .toString(),
                                                              //   style: Theme.of(
                                                              //           context)
                                                              //       .textTheme
                                                              //       .bodyText2!
                                                              //       .copyWith(
                                                              //           fontSize:
                                                              //               12,
                                                              //           fontWeight:
                                                              //               FontWeight.w500),
                                                              // ),
                                                              // if (rideList[index]
                                                              //     .status !=
                                                              //     'complete')
                                                              //   Text(
                                                              //     rideList[index]
                                                              //         .acceptReject ==
                                                              //         "6"
                                                              //         ? "Trip End OTP : ${rideList[index].bookingOtp.toString()}"
                                                              //         : "Start OTP : ${rideList[index].bookingOtp.toString()}",
                                                              //     style: TextStyle(
                                                              //         fontWeight:
                                                              //         FontWeight.w600,
                                                              //         color: Colors.blue,
                                                              //         fontSize: 12),
                                                              //   ),

                                                              rideList[index].extraKmPrice ==
                                                                          null ||
                                                                      rideList[index]
                                                                              .extraKmPrice ==
                                                                          '0.00'
                                                                  ? SizedBox()
                                                                  : Text(
                                                                      rideList[
                                                                              index]
                                                                          .extraKmPrice
                                                                          .toString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500),
                                                                    ),
                                                              // Text(
                                                              //   rideList[index]
                                                              //       .luggageCarrier
                                                              //       .toString(),
                                                              //   style: Theme.of(
                                                              //           context)
                                                              //       .textTheme
                                                              //       .bodyText2!
                                                              //       .copyWith(
                                                              //           fontSize:
                                                              //               12,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w500),
                                                              // ),
                                                              rideList[index]
                                                                          .luggageCapacity ==
                                                                      null
                                                                  ? SizedBox()
                                                                  : Text(
                                                                      rideList[
                                                                              index]
                                                                          .luggageCapacity
                                                                          .toString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w500),
                                                                    ),
                                                              // Text(
                                                              //   rideList[index].vehicle_no.toString(),
                                                              //   style: Theme.of(context)
                                                              //       .textTheme
                                                              //       .bodyText2!
                                                              //       .copyWith(
                                                              //       fontSize: 14,
                                                              //       fontWeight:
                                                              //       FontWeight.w500),
                                                              // ),
                                                              // Text(
                                                              //   rideList[index].insurance_expiry.toString(),
                                                              //   style: Theme.of(context)
                                                              //       .textTheme
                                                              //       .bodyText2!
                                                              //       .copyWith(
                                                              //       fontSize: 12,
                                                              //       fontWeight:
                                                              //       FontWeight.w500),
                                                              // ),
                                                              // Text(
                                                              //   rideList[index].pollution_expiry.toString(),
                                                              //   style: Theme.of(context)
                                                              //       .textTheme
                                                              //       .bodyText2!
                                                              //       .copyWith(
                                                              //       fontSize: 12,
                                                              //       fontWeight:
                                                              //       FontWeight.w500),
                                                              // ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              boxHeight(5),
                                                              !rideList[index]
                                                                      .bookingType!
                                                                      .contains(
                                                                          "Point")
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment: rideList[index].sharing_type != null &&
                                                                                rideList[index].sharing_type != ""
                                                                            ? MainAxisAlignment.spaceBetween
                                                                            : MainAxisAlignment.center,
                                                                        children: [
                                                                          AnimatedTextKit(
                                                                            animatedTexts: [
                                                                              ColorizeAnimatedText(
                                                                                "Booking Date - ${rideList[index].pickupDate ?? ''} ${rideList[index].pickupTime}",
                                                                                textStyle: colorizeTextStyle.copyWith(fontSize: 14),
                                                                                colors: colorizeColors,
                                                                              ),
                                                                            ],
                                                                            pause:
                                                                                Duration(milliseconds: 100),
                                                                            isRepeatingAnimation:
                                                                                true,
                                                                            totalRepeatCount:
                                                                                100,
                                                                            onTap:
                                                                                () {
                                                                              print("Tap Event");
                                                                            },
                                                                          ),
                                                                          // rideList[index].sharing_type !=
                                                                          //             null &&
                                                                          //         rideList[index]
                                                                          //                 .sharing_type !=
                                                                          //             ""
                                                                          //     ? AnimatedTextKit(
                                                                          //         animatedTexts: [
                                                                          //           ColorizeAnimatedText(
                                                                          //             "${getTranslated(context, "RIDE_TYPE")} - ${rideList[index].sharing_type}",
                                                                          //             textStyle:
                                                                          //                 colorizeTextStyle,
                                                                          //             colors:
                                                                          //                 colorizeColors,
                                                                          //           ),
                                                                          //         ],
                                                                          //         pause: Duration(
                                                                          //             milliseconds:
                                                                          //                 100),
                                                                          //         isRepeatingAnimation:
                                                                          //             true,
                                                                          //         totalRepeatCount:
                                                                          //             100,
                                                                          //         onTap: () {
                                                                          //           print(
                                                                          //               "Tap Event");
                                                                          //         },
                                                                          //       )
                                                                          //     : SizedBox(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                              boxHeight(8),
                                                              rideList[index].returnDate !=
                                                                          "" &&
                                                                      rideList[index]
                                                                              .returnDate !=
                                                                          null
                                                                  ? AnimatedTextKit(
                                                                      animatedTexts: [
                                                                        ColorizeAnimatedText(
                                                                          "Return Date - ${rideList[index].returnDate ?? ''}",
                                                                          textStyle:
                                                                              colorizeTextStyle.copyWith(fontSize: 16),
                                                                          colors:
                                                                              colorizeColors,
                                                                        ),
                                                                      ],
                                                                      pause: Duration(
                                                                          milliseconds:
                                                                              100),
                                                                      isRepeatingAnimation:
                                                                          true,
                                                                      totalRepeatCount:
                                                                          100,
                                                                      onTap:
                                                                          () {
                                                                        print(
                                                                            "Tap Event");
                                                                      },
                                                                    )
                                                                  : boxHeight(
                                                                      5),
                                                            ])),

                                                    //SizedBox(height: 5),
                                                    // if (!selected)
                                                    // if (rideList[index]
                                                    //         .status !=
                                                    //     'complete')
                                                    //   Text(
                                                    //     rideList[index]
                                                    //                 .acceptReject ==
                                                    //             "6"
                                                    //         ? "Trip End OTP : ${rideList[index].bookingOtp.toString()}"
                                                    //         : "Start OTP : ${rideList[index].bookingOtp.toString()}",
                                                    //     style: TextStyle(
                                                    //         fontWeight:
                                                    //             FontWeight.w600,
                                                    //         color: Colors.blue,
                                                    //         fontSize: 12),
                                                    //   ),
                                                    ListTile(
                                                      horizontalTitleGap: 0,
                                                      leading: Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          color: Colors.green),
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          text(
                                                              "Pickup Location",
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  fontRegular,
                                                              textColor:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          Text(
                                                            '${rideList[index].pickupAddress}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      dense: true,
                                                      tileColor:
                                                          theme.cardColor,
                                                    ),
                                                    ListTile(
                                                      horizontalTitleGap: 0,
                                                      leading: Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          color: Colors.red),
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          text("Drop Location",
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  fontRegular,
                                                              textColor:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          Text(
                                                            '${rideList[index].dropAddress}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      dense: true,
                                                      tileColor:
                                                          theme.cardColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Divider(),
                                            boxHeight(5),
                                            // !rideList[index]
                                            //         .bookingType!
                                            //         .contains("Point")
                                            //     ? Padding(
                                            //         padding: const EdgeInsets
                                            //             .symmetric(
                                            //             horizontal: 8.0),
                                            //         child: Row(
                                            //           mainAxisAlignment: rideList[
                                            //                               index]
                                            //                           .sharing_type !=
                                            //                       null &&
                                            //                   rideList[index]
                                            //                           .sharing_type !=
                                            //                       ""
                                            //               ? MainAxisAlignment
                                            //                   .spaceBetween
                                            //               : MainAxisAlignment
                                            //                   .center,
                                            //           children: [
                                            //             AnimatedTextKit(
                                            //               animatedTexts: [
                                            //                 ColorizeAnimatedText(
                                            //                   "Booking Date - ${rideList[index].pickupDate ?? ''} ${rideList[index].pickupTime}",
                                            //                   textStyle:
                                            //                       colorizeTextStyle
                                            //                           .copyWith(
                                            //                               fontSize:
                                            //                                   16),
                                            //                   colors:
                                            //                       colorizeColors,
                                            //                 ),
                                            //               ],
                                            //               pause: Duration(
                                            //                   milliseconds:
                                            //                       100),
                                            //               isRepeatingAnimation:
                                            //                   true,
                                            //               totalRepeatCount: 100,
                                            //               onTap: () {
                                            //                 print("Tap Event");
                                            //               },
                                            //             ),
                                            //             // rideList[index].sharing_type !=
                                            //             //             null &&
                                            //             //         rideList[index]
                                            //             //                 .sharing_type !=
                                            //             //             ""
                                            //             //     ? AnimatedTextKit(
                                            //             //         animatedTexts: [
                                            //             //           ColorizeAnimatedText(
                                            //             //             "${getTranslated(context, "RIDE_TYPE")} - ${rideList[index].sharing_type}",
                                            //             //             textStyle:
                                            //             //                 colorizeTextStyle,
                                            //             //             colors:
                                            //             //                 colorizeColors,
                                            //             //           ),
                                            //             //         ],
                                            //             //         pause: Duration(
                                            //             //             milliseconds:
                                            //             //                 100),
                                            //             //         isRepeatingAnimation:
                                            //             //             true,
                                            //             //         totalRepeatCount:
                                            //             //             100,
                                            //             //         onTap: () {
                                            //             //           print(
                                            //             //               "Tap Event");
                                            //             //         },
                                            //             //       )
                                            //             //     : SizedBox(),
                                            //           ],
                                            //         ),
                                            //       )
                                            //     : SizedBox(),
                                            // boxHeight(8),
                                            rideList[index].returnDate != "" &&
                                                    rideList[index]
                                                            .returnDate !=
                                                        null
                                                ? AnimatedTextKit(
                                                    animatedTexts: [
                                                      ColorizeAnimatedText(
                                                        "Return Date - ${rideList[index].returnDate ?? ''}",
                                                        textStyle:
                                                            colorizeTextStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        16),
                                                        colors: colorizeColors,
                                                      ),
                                                    ],
                                                    pause: Duration(
                                                        milliseconds: 100),
                                                    isRepeatingAnimation: true,
                                                    totalRepeatCount: 100,
                                                    onTap: () {
                                                      print("Tap Event");
                                                    },
                                                  )
                                                : boxHeight(5),
                                            /* !rideList[index].bookingType!.contains("Point")?Text(
                            'Schedule - ${rideList[index].pickupDate} ${rideList[index].pickupTime}',
                            style: theme.textTheme.bodyText2,
                          ):SizedBox(),*/
                                            rideList[index].status !=
                                                    "Cancelled"
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      rideList[index].status !=
                                                              "complete"
                                                          ? InkWell(
                                                              onTap: () {
                                                                showBottom1(
                                                                    rideList[
                                                                            index]
                                                                        .bookingId,
                                                                    rideList[
                                                                            index]
                                                                        .createdDate,
                                                                    index);
                                                              },
                                                              child: Container(
                                                                width: 80.w,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            5,
                                                                        horizontal:
                                                                            16),
                                                                height: 5.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      loading1
                                                                          ? text(
                                                                              "CANCEL",
                                                                              fontFamily: fontMedium,
                                                                              fontSize: 10.sp,
                                                                              isCentered: true,
                                                                              textColor: Colors.black)
                                                                          : CircularProgressIndicator(
                                                                              color: Colors.white,
                                                                            ),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox()

                                                      // InkWell(
                                                      //         onTap: () {
                                                      //           showDialog(
                                                      //             context:
                                                      //                 context,
                                                      //             builder:
                                                      //                 (context) =>
                                                      //                     RateRideDialog(
                                                      //               rideList[
                                                      //                   index],
                                                      //               check: rideList[index]
                                                      //                       .transaction!
                                                      //                       .contains("Wait")
                                                      //                   ? false
                                                      //                   : true,
                                                      //             ),
                                                      //           );
                                                      //           // showBottom(rideList[index].driverId,rideList[index].bookingId);
                                                      //         },
                                                      //         child: Container(
                                                      //           width: 80.w,
                                                      //           margin: EdgeInsets
                                                      //               .symmetric(
                                                      //                   vertical:
                                                      //                       5,
                                                      //                   horizontal:
                                                      //                       16),
                                                      //           height: 5.h,
                                                      //           decoration:
                                                      //               BoxDecoration(
                                                      //             borderRadius:
                                                      //                 BorderRadius
                                                      //                     .circular(
                                                      //                         3),
                                                      //             border: Border.all(
                                                      //                 color: Colors
                                                      //                     .black),
                                                      //           ),
                                                      //           child: Center(
                                                      //             child:
                                                      //                 loading1
                                                      //                     ? text(
                                                      //                         "RATE DRIVER",
                                                      //                         fontFamily: fontMedium,
                                                      //                         fontSize: 10.sp,
                                                      //                         isCentered: true,
                                                      //                         textColor: Colors.black)
                                                      //                     : CircularProgressIndicator(
                                                      //                         color: Colors.white,
                                                      //                       ),
                                                      //           ),
                                                      //         ),
                                                      //       )

                                                      ///Share
                                                      // InkWell(
                                                      //   onTap: () {
                                                      //     setState(() {
                                                      //       shareLoading = false;
                                                      //     });
                                                      //     final dynamicLinkParams =
                                                      //         DynamicLinkParameters(
                                                      //       link: Uri.parse(
                                                      //           "https://bikebooking.alphawizzserver.com/?${rideList[index].bookingId}"),
                                                      //       uriPrefix:
                                                      //           "https://alphawizzserver.com/cab_booking",
                                                      //       androidParameters:
                                                      //           const AndroidParameters(
                                                      //               packageName:
                                                      //                   "com.fasto.user"),
                                                      //       iosParameters:
                                                      //           const IOSParameters(
                                                      //               bundleId:
                                                      //                   "com.fasto.user"),
                                                      //     );
                                                      //     FirebaseDynamicLinks.instance
                                                      //         .buildShortLink(
                                                      //             dynamicLinkParams)
                                                      //         .then((ShortDynamicLink
                                                      //             value) {
                                                      //       print(rideList[index]
                                                      //           .bookingId);
                                                      //       print(value.shortUrl);
                                                      //       capturePng(
                                                      //           index, value.shortUrl);
                                                      //       setState(() {
                                                      //         shareLoading = true;
                                                      //       });
                                                      //     });
                                                      //     /*final referCodeService =
                                                      //           ReferCodeService(context,
                                                      //               onResult: (result) {
                                                      //         capturePng(index, result);
                                                      //       });
                                                      //       referCodeService.init(
                                                      //           rideList[index].bookingId);
                                                      //       setState(() {
                                                      //         loading1 = false;
                                                      //       });*/
                                                      //   },
                                                      //   child: Container(
                                                      //     width: 30.w,
                                                      //     margin: EdgeInsets.symmetric(
                                                      //         vertical: 5,
                                                      //         horizontal: 16),
                                                      //     height: 5.h,
                                                      //     decoration: boxDecoration(
                                                      //         radius: 5,
                                                      //         bgColor: Theme.of(context)
                                                      //             .primaryColor),
                                                      //     child: Center(
                                                      //         child: shareLoading
                                                      //             ? text(
                                                      //                 getTranslated(context,
                                                      //                     "SHARE")!,
                                                      //                 fontFamily:
                                                      //                     fontMedium,
                                                      //                 fontSize: 10.sp,
                                                      //                 isCentered: true,
                                                      //                 textColor:
                                                      //                     Colors.white)
                                                      //             : CircularProgressIndicator(
                                                      //                 color: Colors.white,
                                                      //               )),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  )
                                                : SizedBox(height: 12),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                        )
                      : Center(
                          child: text(getTranslated(context, "NO_RIDES")!,
                              fontFamily: fontMedium,
                              fontSize: 12.sp,
                              textColor: Colors.black),
                        )
                  : Center(
                      child: CircularProgressIndicator(color: Colors.black)),
            ],
          ),
        ),
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
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  PersistentBottomSheetController? controller;
  double rating = 4.0;
  TextEditingController desCon = new TextEditingController();
  showBottom(driverId, bookingId) async {
    controller = await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate Driver",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            RatingBar(
              initialRating: rating,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36,
              ratingWidget: RatingWidget(
                full: Icon(
                  Icons.star,
                  color: AppTheme.primaryColor,
                ),
                half: Icon(
                  Icons.star_half_rounded,
                  color: AppTheme.primaryColor,
                ),
                empty: Icon(
                  Icons.star_border_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              itemPadding: EdgeInsets.zero,
              onRatingUpdate: (rating1) {
                print(rating1);
                controller!.setState!(() {
                  rating = rating1;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              controller: desCon,
              keyboardType: TextInputType.name,
              label: "Write Comment",
            ),
            SizedBox(
              height: 10,
            ),
            !status
                ? InkWell(
                    onTap: () {
                      controller!.setState!(() {
                        status = true;
                      });
                      rateOrder(driverId, bookingId);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: MyColorName.primaryDark.withOpacity(0.5),
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Rate Booking",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
          ],
        ),
      );
    });
  }

  bool status = false;
  rateOrder(driverId, bookingId) async {
    await App.init();
    Map param = {
      "driver_id": driverId,
      "comments": desCon.text,
      "booking_id": bookingId,
      "rating": rating.toString(),
      "user_id": curUserId,
    };
    Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "payment/AddReviews"), param);
    controller!.setState!(() {
      status = false;
    });
    UI.setSnackBar(response['message'], context);
    if (response['status']) {
      Navigator.pop(context, "yes");
      Navigator.pop(context, "yes");
    }
  }

  List<GlobalKey> _globalKey = [];

  Future<String> capturePng(i, url) async {
    try {
      print('inside');
      RenderRepaintBoundary? boundary = _globalKey[i]
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      print(pngBytes);
      String dir = (await getApplicationSupportDirectory()).path;
      File? file = File(
          "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
      await file.writeAsBytes(pngBytes);
      setState(() {
        loading1 = true;
      });
      // SocialShare.shareOptions("${url}", imagePath: file.path);
      return file.path;
    } catch (e) {
      print(e);
    }
    return "";
  }

  bool acceptStatus = false;
  List<ReasonModel> reasonList = [];
  getReason() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "type": "User",
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "payment/cancel_ride_reason"), data);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        // UI.setSnackBar(msg, context);
        if (response['status']) {
          for (var v in response['data']) {
            setState(() {
              reasonList.add(new ReasonModel.fromJson(v));
            });
          }
          //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> OfflinePage("")), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        // UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      // UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  cancelStatus(String bookingId, status1) async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "type": "schedule_booking",
          "booking_time": status1,
          "accept_reject": "4",
          "booking_id": bookingId,
          "reason": reasonList[indexReason].reason,
        };
        Map response = await apiBase.postAPICall(
            Uri.parse(baseUrl1 + "Payment/cancel_ride_user_driver"), data);
        print(response);
        print(response);
        setState(() {
          acceptStatus = false;
        });
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          /*Navigator.popUntil(
            context,
            ModalRoute.withName('/'),
          );*/
          /* Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SearchLocationPage()),
              (route) => false);*/
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  int indexReason = 0;
  PersistentBottomSheetController? persistentBottomSheetController1;
  getDifference(index) {
    String date = rideList[index].pickupDate.toString();
    print(date);
    DateTime temp = DateTime.parse(date.replaceAll(" ", ""));
    if (temp.day == DateTime.now().day) {
      print(rideList[index].pickupTime);
      String time = rideList[index]
          .pickupTime
          .toString()
          .replaceAll(" ", "")
          .split(" ")[0];
      DateTime temp = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(time.split(":")[0]),
          int.parse(time.split(":")[1]));
      if (cancelTime != "") {
        print(int.parse(cancelTime) < temp.difference(DateTime.now()).inHours);
        return int.parse(cancelTime) > temp.difference(DateTime.now()).inHours;
      } else {
        return false;
      }
    } else {
      print(false);
      return false;
    }
  }

  showBottom1(id, date, index) async {
    persistentBottomSheetController1 =
        await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        decoration:
            boxDecoration(radius: 0, showShadow: true, color: Colors.white),
        padding: EdgeInsets.all(getWidth(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // !rideList[index].bookingType!.contains("Point") &&
            //         getDifference(index)
            //     ? Container(
            //         padding: EdgeInsets.all(getWidth(10)),
            //         color: Colors.white,
            //         child: Column(
            //           children: [
            //             AnimatedTextKit(
            //               animatedTexts: [
            //                 ColorizeAnimatedText(
            //                   "Cancellation Charge ₹${rideList[index].cancel_charge} will be deducted from the wallet.",
            //                   textStyle: colorizeTextStyle,
            //                   colors: colorizeColors,
            //                 ),
            //               ],
            //               pause: Duration(milliseconds: 100),
            //               isRepeatingAnimation: true,
            //               totalRepeatCount: 100,
            //               onTap: () {
            //                 print("Tap Event");
            //               },
            //             ),
            //             SizedBox(
            //               height: 10,
            //             ),
            //             Text(
            //               "This charge is deducted from your wallet",
            //               style: TextStyle(color: Colors.red),
            //             ),
            //           ],
            //         ),
            //       )
            //     : SizedBox(),
            // Text("OTP : ${rideList[index].otp.toString()}"),
            boxHeight(20),
            text("${getTranslated(context, "SELECT_REASON")}",
                textColor: MyColorName.colorTextPrimary,
                fontSize: 12.sp,
                fontFamily: fontBold),
            boxHeight(20),
            reasonList.length > 0
                ? Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: reasonList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              persistentBottomSheetController1!.setState!(() {
                                indexReason = index;
                              });
                              // Navigator.pop(context);
                            },
                            child: Container(
                              color: indexReason == index
                                  ? MyColorName.primaryLite.withOpacity(0.2)
                                  : Colors.white,
                              padding: EdgeInsets.all(getWidth(10)),
                              child: text(reasonList[index].reason.toString(),
                                  textColor: MyColorName.colorTextPrimary,
                                  fontSize: 10.sp,
                                  fontFamily: fontMedium,
                                  isLongText: true),
                            ),
                          );
                        }),
                  )
                : SizedBox(),
            boxHeight(20),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 35.w,
                    height: 5.h,
                    margin: EdgeInsets.all(getWidth(14)),
                    decoration: boxDecoration(
                        radius: 5, bgColor: Theme.of(context).primaryColor),
                    child: Center(
                      child: text(getTranslated(context, "CANCEL")!,
                          fontFamily: fontMedium,
                          fontSize: 10.sp,
                          isCentered: true,
                          textColor: Colors.white),
                    ),
                  ),
                ),
                boxWidth(10),
                InkWell(
                  onTap: () {
                    persistentBottomSheetController1!.setState!(() {
                      acceptStatus = true;
                    });
                    cancelStatus(id, date);
                  },
                  child: !acceptStatus
                      ? Container(
                          width: 35.w,
                          height: 5.h,
                          margin: EdgeInsets.all(getWidth(14)),
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child: Center(
                              child: text(getTranslated(context, "CONTINUE")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        )
                      : CircularProgressIndicator(color: Colors.black),
                ),
              ],
            ),
            boxHeight(40),
          ],
        ),
      );
    });
  }
}
