import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pristine_andaman/Assets/assets.dart';
import 'package:pristine_andaman/BookRide/finding_ride_page.dart';
import 'package:pristine_andaman/DrawerPages/Wallet/wallet_page.dart';
import 'package:pristine_andaman/Model/driver_model.dart';
import 'package:pristine_andaman/Model/promo_code.dart';
import 'package:pristine_andaman/Model/rides_model.dart';
import 'package:pristine_andaman/Model/wallet_model.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'BookingSuccess.dart';
import 'confirm_rider_request.dart';

class CabType {
  final String car;
  final String? rideType;
  final String cost;

  CabType(this.car, this.rideType, this.cost);
}

class ChooseCabPage extends StatefulWidget {
  LatLng source, destination;
  String pickAddress,
      dropAddress,
      pickCity,
      dropCity,
      paymentType,
      shareType,
      rideType,
      time,
      returnDate,
      returnTime;

  DateTime? bookingDate;
  String? bookingTime;
  ChooseCabPage(
      this.source,
      this.destination,
      this.pickAddress,
      this.pickCity,
      this.dropCity,
      this.dropAddress,
      this.paymentType,
      this.bookingDate,
      this.shareType,
      this.rideType,
      this.time,
      this.returnDate,
      this.returnTime,
      {this.bookingTime});

  @override
  _ChooseCabPageState createState() => _ChooseCabPageState();
}

class _ChooseCabPageState extends State<ChooseCabPage> {
  int _currentCar = 0;
  bool cabSelected = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  //var distance;
  var vehicleType;
  @override
  void initState() {
    print(
        "asdadasdadd ${widget.rideType} locassaasassad ${widget.destination.latitude} ${widget.destination.longitude} adadds ${widget.source.latitude} dfdsdf ${widget.source.longitude.toString()} pkadd ${widget.pickAddress.toString()} drpadd ${widget.dropAddress.toString()}pickCity dropCity paymentType shareType rideType time returnDate returnTime bookingDate");
    // TODO: implement initState
    super.initState();
    paymentType = widget.paymentType;
    bookingDate = widget.bookingDate;
    readBefore();
    getDriver();
    // getJoiningBonus();
//    getRides();
    getTime1(
        widget.source.latitude.toString(),
        widget.source.longitude.toString(),
        widget.destination.latitude.toString(),
        widget.destination.longitude.toString());
    getEstimated();
    getWallet();
  }

  List<WalletModel> walletList = [];
  double totalBal = 0;
  getWallet() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "users/getWallet/$curUserId"),
      );
      setState(() {
        saveStatus = true;
        walletList.clear();
      });
      if (response['status']) {
        var data = response["transactions"];
        for (var v in data) {
          print(v['Note']);
          setState(() {
            walletList.add(new WalletModel.fromJson(v));
          });
        }
        print(data);
        totalBal = double.parse(response['amount'].toString());
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

  int selectedIndex = 0;
  int selctCabIndex = 0;

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected tab index
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selectedIndex == index ? Colors.white : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Function to build tab content
  Widget _buildTabContent(List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Icon(Icons.circle, size: 8, color: Colors.green),
              SizedBox(width: 8),
              Text(items[index]),
            ],
          );
        },
      ),
    );
  }

  List<CabType> cabs = [];
  TextEditingController promoCon = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    cabs = [
      CabType(Assets.Car1, getTranslated(context, 'SHARE'), '40.50'),
      CabType(Assets.Car2, getTranslated(context, 'PRIVATE'), '65.50'),
      CabType(Assets.Car3, getTranslated(context, 'LUXURY'), '128.20'),
    ];
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: MyColorName.lightGrey,
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
            'Cabs',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(
          children: [
            ///Map
            /*latitude != 0 && !driveStatus && rideList.length > 0
                ? MapPage(
                    true,
                    pick: widget.pickAddress,
                    dest: widget.dropAddress,
                    zoom: widget.shareType != "" ? 9 : 15,
                    driveList: driverList,
                    SOURCE_LOCATION: widget.source,
                    DEST_LOCATION: widget.destination,
                    carType:
                        rideList[_currentCar].catType == "Auto" ? "1" : "2",
                    live: false,
                  )
                : Center(child: CircularProgressIndicator(color:Colors.black)),*/

            /*     Positioned(
              right: getWidth(10),
              top: getHeight(10),
              child: InkWell(
                onTap: () {
                  scaffoldKey.currentState!.showBottomSheet((context) =>  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        boxHeight(10),
                        Row(
                          children: [
                            Expanded(
                              child: text(
                                "Offers",
                                isCentered: true,
                                fontSize: 14.sp,
                                fontFamily: fontMedium,
                                textColor: MyColorName.colorTextPrimary,
                              ),
                            ),
                            IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon: Icon(Icons.close,color:MyColorName.colorTextPrimary ,)),
                          ],
                        ),
                        boxHeight(10),
                        Container(
                          margin: EdgeInsets.all(getWidth(10)),
                          child: TextField(
                            controller: promoCon,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                              ),
                              focusedBorder: OutlineInputBorder(),
                              hintText: "Enter Promo Code",
                              suffixIcon: IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  applyCode(promoCon.text);
                                },
                                icon: Icon(Icons.send,
                                color: MyColorName.primaryLite,
                                ),
                              )
                            ),
                          ),
                        ),
                        boxHeight(10),
                        ListView.builder(
                          itemCount: promoList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context,index){
                           return Container(
                             margin: EdgeInsets.all(getWidth(10)),
                             decoration: boxDecoration(
                               showShadow: true,
                             ),
                             child: ListTile(
                               title: text(
                                 "Promo Code : ${promoList[index].promocode}",
                                 fontSize: 14.sp,
                                 fontFamily: fontMedium,
                                 textColor: MyColorName.colorTextPrimary,
                               ),
                               subtitle:  text(
                                 "${promoList[index].message}",
                                 fontSize: 14.sp,
                                 fontFamily: fontMedium,
                                 textColor: MyColorName.colorTextPrimary,
                               ),
                               trailing:  InkWell(
                                 onTap: () {
                                   Navigator.pop(context);
                                   applyCode(promoList[index].promocode);
                                 },
                                 child: Container(
                                   width: 20.w,
                                   height: 4.h,
                                   decoration: boxDecoration(
                                       radius: 5,bgColor: Theme.of(context)
                                       .primaryColor),
                                   child: Center(
                                       child: text("Apply",
                                           fontFamily: fontMedium,
                                           fontSize: 10.sp,
                                           isCentered: true,
                                           textColor: Colors.white)),
                                 ),
                               ),
                             ),
                           );
                        }),
                        boxHeight(10),
                      ],
                    ),
                  ),);
                },
                child: Container(
                  decoration: boxDecoration(
                      radius: 10,
                      color: Theme.of(context).primaryColor),
                  height: 6.h,
                  width: 6.h,
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 20.sp,
                  ),
                ),
              ),
            ),*/
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup Location',
                                        style:
                                            TextStyle(color: Color(0xff8D8D8D)),
                                      ),
                                      Text(widget.pickAddress)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Drop Location',
                                        style:
                                            TextStyle(color: Color(0xff8D8D8D)),
                                      ),
                                      Text(widget.dropAddress)
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // rideList.length > 0 ?
                    Container(
                      // height: 640,
                      alignment: Alignment.center,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: rideList.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        // scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          vehicleType =
                              rideList[index].catType == "Auto" ? "1" : "2";
                          return Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                if (rideList[_currentCar].catType !=
                                    rideList[index].catType) {
                                  getDriver();
                                }
                                setState(() {
                                  _currentCar = index;
                                  cabSelected = true;
                                });
                                vendorId =
                                    rideList[_currentCar].vendorId.toString();
                                vehicleId =
                                    rideList[_currentCar].taxi_id.toString();
                                print(
                                    "vehicletaxi$vehicleId=====$vendorId======");
                                getPromo();
                              },
                              child: Card(
                                elevation: 0,
                                color: Colors.white,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 350),
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _currentCar == index && cabSelected
                                        ? MyColorName.secondary.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: MyColorName.greyBorder
                                        // _currentCar == index && cabSelected
                                        //     ? MyColorName.secondary
                                        //     : MyColorName.greyBorder
                                        ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          rideList[index].catType == "Auto" ||
                                                  !rideList[index]
                                                      .image
                                                      .contains('.')
                                              ? Image.asset(
                                                  rideList[index].catType ==
                                                          "Auto"
                                                      ? "assets/cars/car1.png"
                                                      : "assets/cars/car2.png",
                                                  height: 80,
                                                  width: 80,
                                                )
                                              : Image.network(
                                                  rideList[index].image,
                                                  height: 80,
                                                  width: 80,
                                                ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Car Types',
                                                  style: TextStyle(
                                                      color: MyColorName
                                                          .detailsColor,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: MyColorName
                                                          .primaryLite
                                                          .withOpacity(.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                      rideList[index]
                                                          .cartype
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: MyColorName
                                                              .primaryLite,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),

                                                Text(
                                                  // + surge
                                                  // '₹ ${double.parse(rideList[index].intailrate.toString()) - double.parse(promoDiscount)}',
                                                  '₹ ${double.parse(rideList[index].rate_per_km.toString()).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment
                                                //           .spaceBetween,
                                                //   children: [
                                                // Text(
                                                //   rideList[index]
                                                //       .carmodel
                                                //       .toString(),
                                                //   style: Theme.of(context)
                                                //       .textTheme
                                                //       .bodyText2!
                                                //       .copyWith(
                                                //           fontSize: 16,
                                                //           fontWeight:
                                                //               FontWeight
                                                //                   .bold),
                                                // ),
                                                // Text(
                                                //   // + surge
                                                //   // '₹ ${double.parse(rideList[index].intailrate.toString()) - double.parse(promoDiscount)}',
                                                //   '₹ ${double.parse(rideList[index].rate_per_km.toString()).toStringAsFixed(2)}',
                                                //   style: Theme.of(context)
                                                //       .textTheme
                                                //       .caption!
                                                //       .copyWith(
                                                //         fontSize: 18,
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //         color: Color(
                                                //             0xff029752),
                                                //       ),
                                                // ),
                                                //   ],
                                                // ),
                                                // SizedBox(height: 4),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment
                                                //           .spaceBetween,
                                                //   children: [
                                                //     Text(
                                                //       rideList[index]
                                                //           .cartype
                                                //           .toString(),
                                                //       style: Theme.of(context)
                                                //           .textTheme
                                                //           .bodyText2!
                                                //           .copyWith(
                                                //               fontSize: 14,
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .w500),
                                                //     ),
                                                //     Text("•"),
                                                //     Text(
                                                //       "${rideList[index].seating_capacity.toString()} Seats",
                                                //       style: Theme.of(context)
                                                //           .textTheme
                                                //           .bodyText2!
                                                //           .copyWith(
                                                //               fontSize: 14,
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .w500),
                                                //     ),
                                                //     Text("•"),
                                                //     Text(
                                                //       "${rideList[index].distance.toString()} Kms",
                                                //       style: Theme.of(context)
                                                //           .textTheme
                                                //           .bodyText2!
                                                //           .copyWith(
                                                //               fontSize: 14,
                                                //               fontWeight:
                                                //                   FontWeight
                                                //                       .w500),
                                                //     ),
                                                //   ],
                                                // ),
                                                // SizedBox(height: 8),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment.start,
                                                //   crossAxisAlignment:
                                                //       CrossAxisAlignment.start,
                                                //   children: [
                                                //     Column(
                                                //         crossAxisAlignment:
                                                //             CrossAxisAlignment
                                                //                 .start,
                                                //         children: [
                                                //           Text("Fuel Type",
                                                //               style: Theme.of(
                                                //                       context)
                                                //                   .textTheme
                                                //                   .bodyText2!
                                                //                   .copyWith(
                                                //                       fontSize:
                                                //                           12,
                                                //                       fontWeight:
                                                //                           FontWeight
                                                //                               .bold)),
                                                //
                                                //           Text(
                                                //               "Luggage Capacity",
                                                //               style: Theme.of(
                                                //                       context)
                                                //                   .textTheme
                                                //                   .bodyText2!
                                                //                   .copyWith(
                                                //                       fontSize:
                                                //                           12,
                                                //                       fontWeight:
                                                //                           FontWeight
                                                //                               .bold)),
                                                //
                                                //           // Text("Extra km fare",
                                                //           //     style: Theme.of(
                                                //           //             context)
                                                //           //         .textTheme
                                                //           //         .bodyText2!
                                                //           //         .copyWith(
                                                //           //             fontSize:
                                                //           //                 12,
                                                //           //             fontWeight:
                                                //           //                 FontWeight
                                                //           //                     .bold)),
                                                //           // Text("Insurance Expiry",
                                                //           //     style: Theme.of(context)
                                                //           //         .textTheme
                                                //           //         .bodyText2!
                                                //           //         .copyWith(
                                                //           //         fontSize: 12,
                                                //           //         fontWeight:
                                                //           //         FontWeight.bold)),
                                                //           // Text("Pollution Expiry",
                                                //           //     style: Theme.of(context)
                                                //           //         .textTheme
                                                //           //         .bodyText2!
                                                //           //         .copyWith(
                                                //           //         fontSize: 12,
                                                //           //         fontWeight:
                                                //           //         FontWeight.bold)),
                                                //         ]),
                                                //     SizedBox(
                                                //       width: 20,
                                                //     ),
                                                //     // Column(
                                                //     //   crossAxisAlignment:
                                                //     //       CrossAxisAlignment
                                                //     //           .start,
                                                //     //   children: [
                                                //     //     Text(
                                                //     //       rideList[index]
                                                //     //           .fuel_type
                                                //     //           .toString(),
                                                //     //       style: Theme.of(
                                                //     //               context)
                                                //     //           .textTheme
                                                //     //           .bodyText2!
                                                //     //           .copyWith(
                                                //     //               fontSize: 12,
                                                //     //               fontWeight:
                                                //     //                   FontWeight
                                                //     //                       .w500),
                                                //     //     ),
                                                //     //
                                                //     //     Text(
                                                //     //       rideList[index]
                                                //     //           .luggage_capacity
                                                //     //           .toString(),
                                                //     //       style: Theme.of(
                                                //     //               context)
                                                //     //           .textTheme
                                                //     //           .bodyText2!
                                                //     //           .copyWith(
                                                //     //               fontSize: 12,
                                                //     //               fontWeight:
                                                //     //                   FontWeight
                                                //     //                       .w500),
                                                //     //     ),
                                                //     //
                                                //     //     // SizedBox(
                                                //     //     //   width: 92,
                                                //     //     //   child: Text(
                                                //     //     //     "After  ${rideList[index].distance.toString()} km @ ${rideList[index].extra_price.toString()}/km",
                                                //     //     //     maxLines: 2,
                                                //     //     //     style: Theme.of(
                                                //     //     //             context)
                                                //     //     //         .textTheme
                                                //     //     //         .bodyText2!
                                                //     //     //         .copyWith(
                                                //     //     //             fontSize:
                                                //     //     //                 12,
                                                //     //     //             fontWeight:
                                                //     //     //                 FontWeight
                                                //     //     //                     .w500),
                                                //     //     //   ),
                                                //     //     // ),
                                                //     //
                                                //     //     // Text(
                                                //     //     //   rideList[index].vehicle_no.toString(),
                                                //     //     //   style: Theme.of(context)
                                                //     //     //       .textTheme
                                                //     //     //       .bodyText2!
                                                //     //     //       .copyWith(
                                                //     //     //       fontSize: 14,
                                                //     //     //       fontWeight:
                                                //     //     //       FontWeight.w500),
                                                //     //     // ),
                                                //     //     // Text(
                                                //     //     //   rideList[index].insurance_expiry.toString(),
                                                //     //     //   style: Theme.of(context)
                                                //     //     //       .textTheme
                                                //     //     //       .bodyText2!
                                                //     //     //       .copyWith(
                                                //     //     //       fontSize: 12,
                                                //     //     //       fontWeight:
                                                //     //     //       FontWeight.w500),
                                                //     //     // ),
                                                //     //     // Text(
                                                //     //     //   rideList[index].pollution_expiry.toString(),
                                                //     //     //   style: Theme.of(context)
                                                //     //     //       .textTheme
                                                //     //     //       .bodyText2!
                                                //     //     //       .copyWith(
                                                //     //     //       fontSize: 12,
                                                //     //     //       fontWeight:
                                                //     //     //       FontWeight.w500),
                                                //     //     // ),
                                                //     //   ],
                                                //     // ),
                                                //   ],
                                                // )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       borderRadius:
                                      //           BorderRadius.circular(5),
                                      //       color: Colors.white),
                                      //   padding: EdgeInsets.symmetric(
                                      //       vertical: 8, horizontal: 2),
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceEvenly,
                                      //     children: [
                                      //       GestureDetector(
                                      //         onTap: () {
                                      //           setState(() {
                                      //             selectedIndex =
                                      //                 0; // Update the selected tab index
                                      //             selctCabIndex = index;
                                      //           });
                                      //         },
                                      //         child: Container(
                                      //           padding: EdgeInsets.symmetric(
                                      //               horizontal: 16,
                                      //               vertical: 8),
                                      //           decoration: BoxDecoration(
                                      //             color: selectedIndex == 0 &&
                                      //                     selctCabIndex == index
                                      //                 ? Colors.green
                                      //                 : Colors.transparent,
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           child: Text(
                                      //             "Inclusion",
                                      //             style: TextStyle(
                                      //               color: selectedIndex == 0 &&
                                      //                       selctCabIndex ==
                                      //                           index
                                      //                   ? Colors.white
                                      //                   : Colors.green,
                                      //               fontSize: 12,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       GestureDetector(
                                      //         onTap: () {
                                      //           setState(() {
                                      //             selectedIndex =
                                      //                 1; // Update the selected tab index
                                      //             selctCabIndex = index;
                                      //           });
                                      //         },
                                      //         child: Container(
                                      //           padding: EdgeInsets.symmetric(
                                      //               horizontal: 16,
                                      //               vertical: 8),
                                      //           decoration: BoxDecoration(
                                      //             color: selectedIndex == 1 &&
                                      //                     selctCabIndex == index
                                      //                 ? Colors.green
                                      //                 : Colors.transparent,
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           child: Text(
                                      //             "Exclusion",
                                      //             style: TextStyle(
                                      //               color: selectedIndex == 1 &&
                                      //                       selctCabIndex ==
                                      //                           index
                                      //                   ? Colors.white
                                      //                   : Colors.green,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       GestureDetector(
                                      //         onTap: () {
                                      //           setState(() {
                                      //             selectedIndex =
                                      //                 2; // Update the selected tab index
                                      //             selctCabIndex = index;
                                      //           });
                                      //         },
                                      //         child: Container(
                                      //           padding: EdgeInsets.symmetric(
                                      //               horizontal: 16,
                                      //               vertical: 8),
                                      //           decoration: BoxDecoration(
                                      //             color: selectedIndex == 2 &&
                                      //                     selctCabIndex == index
                                      //                 ? Colors.green
                                      //                 : Colors.transparent,
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           child: Text(
                                      //             "Facilities",
                                      //             style: TextStyle(
                                      //               color: selectedIndex == 2 &&
                                      //                       selctCabIndex ==
                                      //                           index
                                      //                   ? Colors.white
                                      //                   : Colors.green,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       GestureDetector(
                                      //         onTap: () {
                                      //           setState(() {
                                      //             selectedIndex =
                                      //                 3; // Update the selected tab index
                                      //             selctCabIndex = index;
                                      //           });
                                      //         },
                                      //         child: Container(
                                      //           padding: EdgeInsets.symmetric(
                                      //               horizontal: 16,
                                      //               vertical: 8),
                                      //           decoration: BoxDecoration(
                                      //             color: selectedIndex == 3 &&
                                      //                     selctCabIndex == index
                                      //                 ? Colors.green
                                      //                 : Colors.transparent,
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           child: Text(
                                      //             "T&C",
                                      //             style: TextStyle(
                                      //               color: selectedIndex == 3 &&
                                      //                       selctCabIndex ==
                                      //                           index
                                      //                   ? Colors.white
                                      //                   : Colors.green,
                                      //               fontWeight: FontWeight.bold,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 5,
                                      // ),
                                      // selectedIndex == 0 &&
                                      //         selctCabIndex == index
                                      //     ? Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.spaceAround,
                                      //         children: [
                                      //           tollTax == "Included"
                                      //               ? Text(
                                      //                   "Toll Tax",
                                      //                   style: TextStyle(
                                      //                       fontSize: 12),
                                      //                 )
                                      //               : SizedBox(),
                                      //           nightCharge == "Included"
                                      //               ? Text(
                                      //                   "Night Charge",
                                      //                   style: TextStyle(
                                      //                       fontSize: 12),
                                      //                 )
                                      //               : SizedBox(),
                                      //           stateCharge == "Included"
                                      //               ? Text(
                                      //                   "State Tax",
                                      //                   style: TextStyle(
                                      //                       fontSize: 12),
                                      //                 )
                                      //               : SizedBox(),
                                      //           parking == "Included"
                                      //               ? Text(
                                      //                   "Parking",
                                      //                   style: TextStyle(
                                      //                       fontSize: 12),
                                      //                 )
                                      //               : SizedBox(),
                                      //         ],
                                      //       )
                                      //     : SizedBox(),
                                      // selectedIndex == 1 &&
                                      //         selctCabIndex == index
                                      //     ? Column(
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.start,
                                      //         children: [
                                      //           Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment
                                      //                     .spaceAround,
                                      //             children: [
                                      //               tollTax == "Excluded"
                                      //                   ? Text(
                                      //                       "Toll Tax",
                                      //                       style: TextStyle(
                                      //                           fontSize: 12),
                                      //                     )
                                      //                   : SizedBox(),
                                      //               nightCharge == "Excluded"
                                      //                   ? Text(
                                      //                       "Night Charge",
                                      //                       style: TextStyle(
                                      //                           fontSize: 12),
                                      //                     )
                                      //                   : SizedBox(),
                                      //             ],
                                      //           ),
                                      //           Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment
                                      //                     .spaceAround,
                                      //             children: [
                                      //               stateCharge == "Excluded"
                                      //                   ? Text(
                                      //                       "State Tax",
                                      //                       style: TextStyle(
                                      //                           fontSize: 12),
                                      //                     )
                                      //                   : SizedBox(),
                                      //               parking == "Excluded"
                                      //                   ? Text(
                                      //                       "Parking",
                                      //                       style: TextStyle(
                                      //                           fontSize: 12),
                                      //                     )
                                      //                   : SizedBox(),
                                      //             ],
                                      //           ),
                                      //           Column(
                                      //             crossAxisAlignment:
                                      //                 CrossAxisAlignment.start,
                                      //             children: [
                                      //               Text(
                                      //                 "After  ${rideList[index].distance.toString()} km @ ${rideList[index].extra_price.toString()}/km",
                                      //                 maxLines: 1,
                                      //                 style: TextStyle(
                                      //                     fontSize: 12),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ],
                                      //       )
                                      //     : SizedBox(),
                                      //
                                      // selectedIndex == 2 &&
                                      //         selctCabIndex == index
                                      //     ? Column(
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.start,
                                      //         children: [
                                      //           Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment
                                      //                     .spaceAround,
                                      //             children: [
                                      //               Text(
                                      //                 "Doorstep delivery",
                                      //                 style: TextStyle(
                                      //                     fontSize: 12),
                                      //               ),
                                      //               Text(
                                      //                 "Luggage Carrier",
                                      //                 style: TextStyle(
                                      //                     fontSize: 12),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //           SizedBox(
                                      //             height: 4,
                                      //           ),
                                      //           Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment
                                      //                     .spaceAround,
                                      //             children: [
                                      //               Text(
                                      //                 "24*7 Roadside Assistance",
                                      //                 style: TextStyle(
                                      //                     fontSize: 12),
                                      //               ),
                                      //               Text(
                                      //                 "FastTags",
                                      //                 style: TextStyle(
                                      //                     fontSize: 12),
                                      //               ),
                                      //             ],
                                      //           )
                                      //         ],
                                      //       )
                                      //     : SizedBox(),
                                      //
                                      // selectedIndex == 3 &&
                                      //         selctCabIndex == index
                                      //     ? Column(
                                      //         crossAxisAlignment:
                                      //             CrossAxisAlignment.start,
                                      //         children: [
                                      //           Text(
                                      //             "Minimum permissible age of rating is 21Years",
                                      //             style:
                                      //                 TextStyle(fontSize: 12),
                                      //           ),
                                      //           Text(
                                      //             "Dealer of the renter should be minimum year old as on rental start date",
                                      //             style:
                                      //                 TextStyle(fontSize: 12),
                                      //           ),
                                      //           SizedBox(
                                      //             height: 4,
                                      //           ),
                                      //           Text(
                                      //             "Few Cars may be limited to 80 KMs/hr for your safety",
                                      //             style:
                                      //                 TextStyle(fontSize: 12),
                                      //           ),
                                      //           Text(
                                      //             "Cancellation charge may be applicable",
                                      //             style:
                                      //                 TextStyle(fontSize: 12),
                                      //           ),
                                      //         ],
                                      //       )
                                      //     : SizedBox(),

                                      // Content Area
                                      // IndexedStack(
                                      //   index: selectedIndex,
                                      //   children: [
                                      //     _buildTabContent([
                                      //       "Base Fare",
                                      //       "Refundable Security Deposit",
                                      //       "Trip Insurance",
                                      //       "GST"
                                      //     ]),
                                      //     _buildTabContent([
                                      //       "Cancellation Charges",
                                      //       "No Show Penalty",
                                      //       "Non-Refundable Taxes"
                                      //     ]),
                                      //     _buildTabContent([
                                      //       "Wi-Fi",
                                      //       "Air Conditioning",
                                      //       "Parking Facilities",
                                      //       "24/7 Support"
                                      //     ]),
                                      //     _buildTabContent([
                                      //       "Terms and Conditions apply.",
                                      //       "Subject to change without notice."
                                      //     ]),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // : SizedBox(),
                    SizedBox(height: 16),
                    /* CustomButton(
                        text: getString(Strings.RIDE_NOW),
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).scaffoldBackgroundColor,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        }
                    ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
        // floatingActionButton: promoList.length > 0 && isFirstUser != "0"
        //     ? InkWell(
        //         onTap: () {
        //           scaffoldKey.currentState!.showBottomSheet(
        //             (context) => Container(
        //               child: Column(
        //                 mainAxisSize: MainAxisSize.min,
        //                 children: [
        //                   boxHeight(10),
        //                   Row(
        //                     children: [
        //                       Expanded(
        //                         child: text(
        //                           getTranslated(context, "OFFER")!,
        //                           isCentered: true,
        //                           fontSize: 14.sp,
        //                           fontFamily: fontMedium,
        //                           textColor: MyColorName.colorTextPrimary,
        //                         ),
        //                       ),
        //                       IconButton(
        //                         onPressed: () {
        //                           Navigator.pop(context);
        //                         },
        //                         icon: Icon(
        //                           Icons.close,
        //                           color: MyColorName.colorTextPrimary,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                   boxHeight(10),
        //                   Container(
        //                     margin: EdgeInsets.all(getWidth(10)),
        //                     child: TextField(
        //                       controller: promoCon,
        //                       decoration: InputDecoration(
        //                           enabledBorder: OutlineInputBorder(),
        //                           focusedBorder: OutlineInputBorder(),
        //                           hintText:
        //                               getTranslated(context, "PROMO_CODE1")!,
        //                           suffixIcon: IconButton(
        //                             onPressed: () {
        //                               Navigator.pop(context);
        //                               applyCode(promoCon.text);
        //                             },
        //                             icon: Icon(
        //                               Icons.send,
        //                               color: MyColorName.primaryLite,
        //                             ),
        //                           )),
        //                     ),
        //                   ),
        //                   boxHeight(10),
        //                   ListView.builder(
        //                       itemCount: promoList.length,
        //                       shrinkWrap: true,
        //                       physics: NeverScrollableScrollPhysics(),
        //                       itemBuilder: (context, index) {
        //                         return Container(
        //                           margin: EdgeInsets.all(getWidth(10)),
        //                           decoration: boxDecoration(
        //                             showShadow: true,
        //                           ),
        //                           child: ListTile(
        //                             title: text(
        //                               "${getTranslated(context, "PROMO_CODE1")} : ${promoList[index].promocode}",
        //                               fontSize: 14.sp,
        //                               fontFamily: fontMedium,
        //                               textColor: MyColorName.colorTextPrimary,
        //                             ),
        //                             subtitle: text(
        //                               "${promoList[index].message}",
        //                               fontSize: 14.sp,
        //                               fontFamily: fontMedium,
        //                               textColor: MyColorName.colorTextPrimary,
        //                             ),
        //                             trailing: InkWell(
        //                               onTap: () {
        //                                 if (promoCon.text !=
        //                                     promoList[index]
        //                                         .promocode
        //                                         .toString()) {
        //                                   setState(() {
        //                                     promoCon.text = promoList[index]
        //                                         .promocode
        //                                         .toString();
        //                                   });
        //                                   Navigator.pop(context);
        //                                   applyCode(promoList[index].promocode);
        //                                 } else {
        //                                   UI.setSnackBar(
        //                                       "Promo code already applied",
        //                                       context);
        //                                 }
        //                               },
        //                               child: Container(
        //                                 width: 20.w,
        //                                 height: 4.h,
        //                                 decoration: boxDecoration(
        //                                     radius: 5,
        //                                     bgColor: promoCon.text ==
        //                                             promoList[index]
        //                                                 .promocode
        //                                                 .toString()
        //                                         ? Colors.grey
        //                                         : Theme.of(context).primaryColor),
        //                                 child: Center(
        //                                     child: text(
        //                                         promoCon.text ==
        //                                                 promoList[index]
        //                                                     .promocode
        //                                                     .toString()
        //                                             ? "Applied"
        //                                             : getTranslated(
        //                                                 context, "APPLY")!,
        //                                         fontFamily: fontMedium,
        //                                         fontSize: 10.sp,
        //                                         isCentered: true,
        //                                         textColor: Colors.white)),
        //                               ),
        //                             ),
        //                           ),
        //                         );
        //                       }),
        //                   boxHeight(10),
        //                 ],
        //               ),
        //             ),
        //           );
        //         },
        //         child: Container(
        //           padding: EdgeInsets.all(12),
        //           decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(15),
        //               // radius: 100,
        //               // showShadow: true,
        //               color: Theme.of(context).primaryColor),
        //           height: 6.h,
        //           width: 27.h,
        //           child: Row(
        //             children: [
        //               Text(
        //                 "Have a promo code?",
        //                 style: TextStyle(color: Colors.white),
        //               ),
        //               const SizedBox(
        //                 width: 5,
        //               ),
        //               Icon(
        //                 Icons.local_offer_outlined,
        //                 color: Colors.white,
        //                 size: 20.sp,
        //               ),
        //             ],
        //           ),
        //         ),
        //       )
        //     : SizedBox(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              boxHeight(10),
              /*Container(
                color: theme.backgroundColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 52,
                child: Row(
                  children: [
                    Text(
                      getTranslated(context, "PAYMENT_MODE")!,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 13.5,
                          ),
                    ),
                    Spacer(),
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.hintColor,
                    ),
                    Spacer(),
                    PopupMenuButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            paymentType != ""
                                ? paymentType
                                : getTranslated(context, 'WALLET')!,
                            style: theme.textTheme.button!.copyWith(
                                color: theme.primaryColor, fontSize: 15),
                          ),
                        ],
                      ),
                      onSelected: (val) {
                        setState(() {
                          paymentType = val.toString();
                        });
                      },
                      offset: Offset(0, -144),
                      color: theme.backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: getString(Strings.CASH)!,
                            child: Row(
                              children: [
                                Icon(Icons.credit_card_sharp),
                                SizedBox(width: 12),
                                Text(getTranslated(context, 'CASH')!),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet),
                                SizedBox(width: 12),
                                Text(getTranslated(context, 'WALLET')!),
                              ],
                            ),
                            value: getString(Strings.WALLET)!,
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),*/

              ///Distance
              // Container(
              //   color: theme.backgroundColor,
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   height: 52,
              //   child: Row(
              //     children: [
              //       Text(
              //         "${getTranslated(context, "DISTANCE")}         ",
              //         style: Theme.of(context).textTheme.bodyText1!.copyWith(
              //               fontSize: 13.5,
              //             ),
              //       ),
              //       Spacer(),
              //       Container(
              //         width: 1,
              //         height: 28,
              //         color: theme.hintColor,
              //       ),
              //       Spacer(),
              //       Text(
              //         distance + " Km",
              //         style: theme.textTheme.button!
              //             .copyWith(color: theme.primaryColor, fontSize: 15),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Future.delayed(Duration(seconds: 1), () {
                          if (cabSelected) {
                            if (bookingDate != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfirmRiderRequest(
                                      bookingId: bookingId,
                                      bookingDate: bookingDate,
                                      currentCar: _currentCar,
                                      destination: widget.destination,
                                      driverList: driverList,
                                      dropAddress: widget.dropAddress,
                                      gst: gst,
                                      nightCharge: nightCharge,
                                      parking: parking,
                                      paymentType: paymentType,
                                      pickAddress: widget.pickAddress,
                                      promoDiscount: promoDiscount,
                                      promoList: promoList,
                                      returnDate: widget.returnDate,
                                      rideList: rideList,
                                      shareType: widget.shareType,
                                      source: widget.source,
                                      stateCharge: stateCharge,
                                      surge: surge,
                                      surgePer: surgePer,
                                      time: widget.time,
                                      tollTax: tollTax,
                                      type: "schedule",
                                      unitPrice: unitPrice,
                                      vehicleId: vehicleId,
                                      vendorId: vendorId,
                                      partPayment: partPayment,
                                    ),
                                  ));
                              // showConfirm("schedule");
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfirmRiderRequest(
                                      bookingId: bookingId,
                                      bookingDate: bookingDate,
                                      currentCar: _currentCar,
                                      destination: widget.destination,
                                      driverList: driverList,
                                      dropAddress: widget.dropAddress,
                                      gst: gst,
                                      nightCharge: nightCharge,
                                      parking: parking,
                                      paymentType: paymentType,
                                      pickAddress: widget.pickAddress,
                                      promoDiscount: promoDiscount,
                                      promoList: promoList,
                                      returnDate: widget.returnDate,
                                      rideList: rideList,
                                      shareType: widget.shareType,
                                      source: widget.source,
                                      stateCharge: stateCharge,
                                      surge: surge,
                                      surgePer: surgePer,
                                      time: widget.time,
                                      tollTax: tollTax,
                                      type: "now",
                                      unitPrice: unitPrice,
                                      vehicleId: vehicleId,
                                      vendorId: vendorId,
                                      partPayment: partPayment,
                                    ),
                                  ));
                              // showConfirm("now");
                            }
                          } else {
                            UI.setSnackBar("Select a cab first", context);
                          }
                        });
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                      },
                      child: Container(
                        width: 90.w,
                        height: bookingDate != null &&
                                bookingDate!.minute > DateTime.now().minute
                            ? 7.h
                            : 7.h,
                        decoration: boxDecoration(
                            radius: 10, bgColor: MyColorName.secondary),
                        child: Center(
                          child: saveStatus
                              ? text(
                                  bookingDate != null
                                      ? "CONFIRM"
                                      // "\n${getDate(bookingDate.toString())}"
                                      : "CONFIRM", //"${getTranslated(context, "RIDE_NOW")}",
                                  fontFamily: fontMedium,
                                  fontSize: bookingDate != null ? 12.sp : 14.sp,
                                  isCentered: true,
                                  fontWeight: FontWeight.w600,
                                  textColor: Colors.white)
                              : CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    // bookingDate != null
                    //     ? Container(
                    //         decoration: boxDecoration(
                    //             radius: 10,
                    //             color: Theme.of(context).primaryColor),
                    //         height: 6.h,
                    //         width: 6.h,
                    //         child: Center(
                    //           child: IconButton(
                    //               onPressed: () {
                    //                 DatePicker.showDateTimePicker(context,
                    //                     showTitleActions: true,
                    //                     onChanged: (date) {
                    //                   print('change $date in time zone ' +
                    //                       date.timeZoneOffset.inHours.toString());
                    //                 }, onConfirm: (date) {
                    //                   setState(() {
                    //                     bookingDate = date;
                    //                   });
                    //                   print('confirm $date');
                    //                 },
                    //                     //currentTime: DateTime.now(),
                    //                     minTime: DateTime.now(),
                    //                     maxTime: DateTime.now()
                    //                         .add(Duration(days: 2)));
                    //               },
                    //               icon: Icon(
                    //                 Icons.calendar_today_outlined,
                    //                 color: Theme.of(context).primaryColor,
                    //                 size: 24.sp,
                    //               )),
                    //         ),
                    //       )
                    //     : SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selectedPaymentOption = '';

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedPaymentOption = 'Part Payment';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedPaymentOption == 'Part Payment'
                                    ? Colors.green
                                    : Colors.grey, // Green if selected
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Image.asset('assets/users/partpayment.png'),
                                SizedBox(height: 8),
                                Text(
                                  'Part Payment (30%)',
                                  style: TextStyle(
                                    color:
                                        _selectedPaymentOption == 'Part Payment'
                                            ? Colors.green
                                            : Colors.grey, // Green if selected
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    "Amount: ${partPayment?.toStringAsFixed(2)}"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Full Payment Option
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedPaymentOption = 'Full Payment';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedPaymentOption == 'Full Payment'
                                    ? Colors.green
                                    : Colors.grey, // Green if selected
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Image.asset('assets/users/cashoayment.png'),
                                SizedBox(height: 8),
                                Text(
                                  'Full Payment (100%)',
                                  style: TextStyle(
                                    color:
                                        _selectedPaymentOption == 'Full Payment'
                                            ? Colors.green
                                            : Colors.grey, // Green if selected
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    "Amount: ${(double.parse(rideList[_currentCar].rate_per_km) - double.parse(promoDiscount))}")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if ("schedule" == "now") {
                        if (totalBal.isNegative) {
                          setState(() {
                            saveStatus = true;
                          });
                          UI.setSnackBar(
                              "You have negative balance, Please update wallet",
                              context);
                          Navigator.pop(context);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletPage()));
                        } else {
                          addRides();
                        }
                      } else {
                        print(
                            "this is schedule time ${bookingDate?.hour} : ${bookingDate?.minute}");
                        if (totalBal.isNegative) {
                          setState(() {
                            saveStatus = true;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletPage()));
                          UI.setSnackBar(
                              "You have negative balance, Please update wallet",
                              context);
                        } else {
                          addScheduleRides();
                        }
                      }
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          MyColorName.secondary, // Background color
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String surgePer = '0';
  bool isChecked = false;
  final Uri _url = Uri.parse(
      'https://bikebooking.alphawizzserver.com/api/authentication/read_before_book');

  Future<void> _launchURL() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  String? readBeforeText;

  readBefore() async {
    var headers = {
      'Cookie': 'ci_session=b981942df33e11728d7536ee4a8a8fe9deed764c'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://bikebooking.alphawizzserver.com/api/authentication/read_before_book'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      readBeforeText = finalResult["html"];
      print("redsdsfsfsfsf $readBeforeText");
    } else {
      print(response.reasonPhrase);
    }
  }

  ///read before dialog
  void readBeforeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(
          //   "Read Before You",
          //   style: TextStyle(fontWeight: FontWeight.w600),
          // ),
          content: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Html(
                        data: readBeforeText,
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              ),
            ],
          )),
        );
      },
    );
  }

  /// confirm riderequest dialog

  showConfirm(String type) {
    surge = 0;
    gst = 0;
    if (rideList[_currentCar].gst != null && rideList[_currentCar].gst != "") {
      gst = ((double.parse(rideList[_currentCar].gst) *
              double.parse(rideList[_currentCar].intailrate)) /
          100);
    }
    // if(isFirstUser != "1"){
    // }
    if (type != "schedule" &&
        !rideList[_currentCar].serge.contains("Not") &&
        rideList[_currentCar].surge_charge.length > 0) {
      if (rideList[_currentCar].surge_charge[0]['time_on_off'].toString() !=
          "CLOSED") {
        surge = ((double.parse(rideList[_currentCar]
                    .surge_charge[0]['amount']
                    .toString()) *
                (double.parse(rideList[_currentCar].intailrate) + gst)) /
            100);
        surgePer = rideList[_currentCar].surge_charge[0]['amount'].toString();
      } else {
        surge = 0;
      }
    }
    print(gst);
    print(surge);

    if (paymentType == "Wallet" &&
        walletAmount <
            surge + gst + double.parse(rideList[_currentCar].intailrate)) {
      UI.setSnackBar("Insufficient Balance", context);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              height: MediaQuery.of(context).size.height,
              // width: double.infinity,
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "CONFIRM_RIDE")!,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
                  boxHeight(5),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: rideList[_currentCar].cartype != "Auto"
                            ? Image.network(
                                rideList[_currentCar].image,
                                width: 80,
                              )
                            : Image.asset(
                                rideList[_currentCar].cartype != "" &&
                                        rideList[_currentCar].cartype != "Auto"
                                    ? "assets/cars/car2.png"
                                    : "assets/cars/car1.png",
                                height: 30,
                                width: 30,
                              ),
                      ),
                      boxWidth(5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text(rideList[_currentCar].cartype,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontRegular,
                              textColor: Colors.black),
                          text("₹" + rideList[_currentCar].rate_per_km,
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black),
                        ],
                      ),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pickup & Drop',
                      style: TextStyle(),
                    ),
                  ),
                  boxHeight(4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.green,
                      ),
                      // Container(
                      //   height: 10,
                      //   width: 10,
                      //   decoration:
                      //       boxDecoration(radius: 100, bgColor: Colors.green),
                      // ),
                      boxWidth(5),
                      Expanded(
                        child: text(widget.pickAddress,
                            fontSize: 9.sp,
                            fontFamily: fontRegular,
                            textColor: Colors.black),
                      ),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                      ),
                      // Container(
                      //   height: 10,
                      //   width: 10,
                      //   decoration:
                      //       boxDecoration(radius: 100, bgColor: Colors.red),
                      // ),
                      boxWidth(5),
                      Expanded(
                          child: text(widget.dropAddress,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                      // Container(
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      //   // margin: EdgeInsets.symmetric(horizontal: 16),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: MyColorName.greyBorder),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       boxHeight(8),
                      //       double.parse(widget.model.baseFare.toString()) > 0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${getTranslated(context, "BASE_FARE")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         widget.model.baseFare.toString(),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       double.parse(widget.model.km.toString()) >= 2 &&
                      //               double.parse(
                      //                       widget.model.ratePerKm.toString()) >
                      //                   0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${widget.model.km.toString()} ${getTranslated(context, "KILOMETERS")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         widget.model.ratePerKm.toString(),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       double.parse(widget.model.timeAmount.toString()) > 0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${widget.model.totalTime.toString()} ${getTranslated(context, "MINUTES")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         widget.model.timeAmount
                      //                             .toString(),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontRegular,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       double.parse(widget.model.gstAmount.toString()) > 0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${getTranslated(context, "TAXES")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         widget.model.gstAmount.toString(),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       double.parse(widget.model.surgeAmount.toString()) >
                      //               0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${getTranslated(context, "SURGE")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         widget.model.surgeAmount
                      //                             .toString(),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       double.parse(widget.model.amount.toString()) > 0
                      //           ? Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 text(
                      //                     "${getTranslated(context, "SUB_TOTAL")} : ",
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //                 text(
                      //                     "₹" +
                      //                         (double.parse(widget.model.amount
                      //                                     .toString()) +
                      //                                 double.parse(widget
                      //                                     .model.promo_discount
                      //                                     .toString()))
                      //                             .toStringAsFixed(2),
                      //                     fontSize: 10.sp,
                      //                     fontFamily: fontMedium,
                      //                     textColor: Colors.black),
                      //               ],
                      //             )
                      //           : SizedBox(),
                      //       widget.model.promo_discount.toString() != ''
                      //           ? double.parse(widget.model.promo_discount
                      //                       .toString()) >
                      //                   0
                      //               ? Row(
                      //                   mainAxisAlignment:
                      //                       MainAxisAlignment.spaceBetween,
                      //                   children: [
                      //                     text(
                      //                         "${getTranslated(context, "PROMO")} : ",
                      //                         fontSize: 10.sp,
                      //                         fontFamily: fontRegular,
                      //                         textColor: Colors.black),
                      //                     text(
                      //                         "- ₹" +
                      //                             double.parse(widget
                      //                                     .model.promo_discount
                      //                                     .toString())
                      //                                 .toStringAsFixed(2),
                      //                         fontSize: 10.sp,
                      //                         fontFamily: fontRegular,
                      //                         textColor: Colors.black),
                      //                   ],
                      //                 )
                      //               : SizedBox()
                      //           : SizedBox(),
                      //       Divider(color: MyColorName.greyDivider),
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           text(
                      //               // "${getTranslated(context, "TOTAL")} : ",
                      //               "Total Amount",
                      //               fontSize: 12.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //           text(
                      //               "₹" +
                      //                   "${double.parse(widget.model.amount.toString()).toStringAsFixed(2)}",
                      //               fontSize: 12.sp,
                      //               fontFamily: fontMedium,
                      //               textColor: Colors.black),
                      //         ],
                      //       ),
                      //       boxHeight(10),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(5),
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'User Detail',
                      style: TextStyle(),
                    ),
                  ),
                  boxHeight(4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  boxHeight(5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      mobile != "" ? mobile.toString() : "",
                    ),
                  ),
                  Divider(),
                  promoList.length > 0 && isFirstUser != "0"
                      ? Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                child: TextField(
                                  controller: promoCon,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    hintText:
                                        getTranslated(context, "PROMO_CODE1")!,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        // Navigator.pop(context);
                                        applyCode(promoCon.text);
                                      },
                                      icon: Icon(
                                        Icons.send,
                                        color: MyColorName.primaryLite,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // boxHeight(5),
                              // ListView.builder(
                              //     itemCount: promoList.length,
                              //     shrinkWrap: true,
                              //     physics: NeverScrollableScrollPhysics(),
                              //     itemBuilder: (context, index) {
                              //       return Container(
                              //         margin: EdgeInsets.all(getWidth(10)),
                              //         decoration: boxDecoration(
                              //           showShadow: true,
                              //         ),
                              //         child: ListTile(
                              //           title: text(
                              //             "${getTranslated(context, "PROMO_CODE1")} : ${promoList[index].promocode}",
                              //             fontSize: 12.sp,
                              //             fontFamily: fontMedium,
                              //             textColor:
                              //                 MyColorName.colorTextPrimary,
                              //           ),
                              //           subtitle: text(
                              //             "${promoList[index].message}",
                              //             fontSize: 12.sp,
                              //             fontFamily: fontMedium,
                              //             textColor:
                              //                 MyColorName.colorTextPrimary,
                              //           ),
                              //           trailing: InkWell(
                              //             onTap: () {
                              //               if (promoCon.text !=
                              //                   promoList[index]
                              //                       .promocode
                              //                       .toString()) {
                              //                 setState(() {
                              //                   promoCon.text = promoList[index]
                              //                       .promocode
                              //                       .toString();
                              //                 });
                              //                 Navigator.pop(context);
                              //                 applyCode(
                              //                     promoList[index].promocode);
                              //               } else {
                              //                 UI.setSnackBar(
                              //                     "Promo code already applied",
                              //                     context);
                              //               }
                              //             },
                              //             child: Container(
                              //               width: 20.w,
                              //               height: 4.h,
                              //               decoration: boxDecoration(
                              //                   radius: 5,
                              //                   bgColor: promoCon.text ==
                              //                           promoList[index]
                              //                               .promocode
                              //                               .toString()
                              //                       ? Colors.grey
                              //                       : Theme.of(context)
                              //                           .primaryColor),
                              //               child: Center(
                              //                   child: text(
                              //                       promoCon.text ==
                              //                               promoList[index]
                              //                                   .promocode
                              //                                   .toString()
                              //                           ? "Applied"
                              //                           : getTranslated(
                              //                               context, "APPLY")!,
                              //                       fontFamily: fontMedium,
                              //                       fontSize: 10.sp,
                              //                       isCentered: true,
                              //                       textColor: Colors.white)),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     }),
                            ],
                          ),
                        )
                      : SizedBox(),
                  Divider(),
                  Row(
                    children: [
                      Text('Payment'),
                    ],
                  ),
                  boxHeight(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // widget.time == 0 || widget.time.length == 0 ?
                      text("${"Toll Tax"}:",
                          // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      // : text("${widget.time}:",
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                      text("$tollTax",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // widget.time == 0 || widget.time.length == 0 ?
                      text("${"State Tax"}:",
                          // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      // : text("${widget.time}:",
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                      text("$stateCharge",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // widget.time == 0 || widget.time.length == 0 ?
                      text("${"Parking"}:",
                          // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      // : text("${widget.time}:",
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                      text("$parking",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // widget.time == 0 || widget.time.length == 0 ?
                      text("${"Night Charge"}:",
                          // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      // : text("${widget.time}:",
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                      text("$nightCharge",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     text("${getTranslated(context, "DISTANCE")} : ",
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //     text(distance + " Km",
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //   ],
                  // ),
                  // double.parse(rideList[_currentCar].base_fare) >= 1
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           text("${getTranslated(context, "BASE_FARE")} : ",
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.black),
                  //           text(
                  //               double.parse(distance) >= 1
                  //                   ? "₹" + rideList[_currentCar].base_fare
                  //                   : "₹" + rideList[_currentCar].minFare,
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.black),
                  //         ],
                  //       )
                  //     : SizedBox(),
                  // double.parse(rideList[_currentCar].main_rate_per_km) >
                  //         double.parse(rideList[_currentCar].rate_per_km)
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           text(
                  //               "$distance ${getTranslated(context, "KILOMETERS")} : ",
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.black),
                  //           text("₹" + rideList[_currentCar].main_rate_per_km,
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.red),
                  //         ],
                  //       )
                  //     : SizedBox(),
                  if (double.parse(rideList[_currentCar].main_rate_per_km) >
                      double.parse(rideList[_currentCar].rate_per_km))
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
                  double.parse(rideList[_currentCar].base_fare) >= 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // widget.time == 0 || widget.time.length == 0 ?
                            text("${"Base Fare"}:",
                                // "$distance ${"Base Fare"}:",   //"$distance ${getTranslated(context, "KILOMETERS")}:",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            // : text("${widget.time}:",
                            //     fontSize: 10.sp,
                            //     fontFamily: fontMedium,
                            //     textColor: Colors.black),
                            text(
                                "${double.parse(rideList[_currentCar].base_fare).toStringAsFixed(2)}",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),

                  // double.parse(rideList[_currentCar].time_cahrge) > 0
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           text(
                  //               "$totalTime ${getTranslated(context, "MINUTES")} : ",
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.black),
                  //           text("₹" + rideList[_currentCar].time_cahrge,
                  //               fontSize: 10.sp,
                  //               fontFamily: fontMedium,
                  //               textColor: Colors.black),
                  //         ],
                  //       )
                  //     : SizedBox(),
                  double.parse(rideList[_currentCar].tax_amount) >= 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("${getTranslated(context, "TAXES")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text(
                                "₹" +
                                    double.parse(
                                            rideList[_currentCar].tax_amount)
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
                  surge > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("${getTranslated(context, "SURGE")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text("₹" + surge.toStringAsFixed(2),
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),
                  double.parse(rideList[_currentCar].rate_per_km) > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("${getTranslated(context, "SUB_TOTAL")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text(
                                "₹" +
                                    (
                                            // surge + gst +
                                            double.parse(rideList[_currentCar]
                                                .rate_per_km))
                                        .toStringAsFixed(2),
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),
                  promoDiscount != "0"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("${getTranslated(context, "PROMO")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text("-₹" + double.parse(promoDiscount).toString(),
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),
                  Divider(),
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
                              (
                                      // surge + gst +
                                      double.parse(rideList[_currentCar]
                                              .rate_per_km) -
                                          double.parse(promoDiscount))
                                  .toStringAsFixed(2),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  // rideList[_currentCar].cancellation_charges != null
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
                  //                   rideList[_currentCar]
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
                  type != "now"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text("${getTranslated(context, "BOOKING_DATE")}: ",
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            Expanded(
                              child: text(getDate(bookingDate),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: fontMedium,
                                  textColor: Colors.black),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      // Checkbox(
                      //   checkColor: Colors.white, // Color of the check icon
                      //   fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                      //     if (states.contains(MaterialState.selected)) {
                      //       return Colors.blue; // Color when checkbox is selected
                      //     }
                      //     return Colors.grey; // Default color
                      //   }),
                      //   value: isChecked,
                      //   onChanged: (bool? value) {
                      //     setState(() {
                      //       isChecked = value!;
                      //     });
                      //   },
                      // ),
                      // InkWell(
                      //   onTap: () {
                      //     _launchURL();
                      //   },
                      //   child: Text(
                      //     "Read Before You ---->",
                      //     style: TextStyle(
                      //       fontSize: 15,
                      //       color: Colors.green,
                      //     ),
                      //   ),
                      // ),
                      // Icon(Icons.arrow_forward_ios_outlined, color: Colors.green,)
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.pop(context1);
                      //     // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                      //   },
                      //   child: Container(
                      //     width: 30.w,
                      //     height: 5.h,
                      //     decoration:
                      //         boxDecoration(radius: 5, bgColor: Colors.grey),
                      //     child: Center(
                      //         child: text(getTranslated(context, "CANCEL")!,
                      //             fontFamily: fontMedium,
                      //             fontSize: 10.sp,
                      //             isCentered: true,
                      //             textColor: Colors.white)),
                      //   ),
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          paymentCalculate(
                              (double.parse(rideList[_currentCar].rate_per_km) -
                                  double.parse(promoDiscount)));
                          addScheduleRides();
                          // _showPaymentBottomSheet(context);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 69.w,
                          height: 6.h,
                          decoration: boxDecoration(
                              radius: 5, bgColor: MyColorName.secondary),
                          child: Center(
                              child: text(
                                  // getTranslated(context, "CONFIRM")!,
                                  "BOOK RIDE",
                                  fontFamily: fontMedium,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
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
          );
        });
  }

  String paymentType = "Cash";
  DateTime? bookingDate;

  Future getEstimated() async {
    calculateDistance(widget.source.latitude, widget.source.longitude,
        widget.destination.latitude, widget.destination.longitude);
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${widget.source.latitude}%2C${widget.source.longitude}&destinations=${widget.destination.latitude}%2C${widget.destination.longitude}&key=AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU'));
    http.StreamedResponse response = await request.send();
    print(request);
    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      var data = json.decode(str);
      print(data);

      if (data["status"] == "OK") {
        setState(() {
          var dis =
              data["rows"][0]["elements"][0]["distance"]["text"].toString();
          List d = dis.toString().split(" ").toList();
          distance = d[0].toString();
          print("$distance>>>>>>>>>>>>>>>>>>>>");
        });
      } else {}
    } else {
      return null;
    }
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool saveStatus = true;
  bool driveStatus = true;
  List<RidesModel> rideList = [];
  List<DriverModel> driverList = [];
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

  double gst = 0.0;
  double surge = 0.0;

  addRides() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId,
        "username": "name",
        "pickup_address": widget.pickAddress,
        "latitude": widget.source.latitude.toString(),
        "longitude": widget.source.longitude.toString(),
        "drop_address": widget.dropAddress,
        "drop_latitude": widget.destination.latitude.toString(),
        "drop_longitude": widget.destination.longitude.toString(),
        "amount": rideList[_currentCar].rate_per_km,
        // (double.parse(rideList[_currentCar].intailrate).roundToDouble() -
        //         double.parse(promoDiscount).roundToDouble() +
        //         gst +
        //         surge)
        //     .toStringAsFixed(2),
        //double.parse(distance) >= 1 ? rideList[_currentCar].minFare
        "paid_amount": (double.parse(rideList[_currentCar].intailrate) -
                double.parse(promoDiscount) +
                gst +
                surge)
            .toStringAsFixed(2),
        "gst_amount": rideList[_currentCar].tax_amount,
        "surge_amount": surge.toStringAsFixed(2),
        "distance": distance,
        "km": distance,
        "rate_per_km": rideList[_currentCar].rate_per_km,
        "admin_commission": rideList[_currentCar].admin_commission,
        "total_time": totalTime,
        "base_fare": double.parse(distance) >= 1
            ? rideList[_currentCar].base_fare
            : rideList[_currentCar].minFare,
        "time_amount": rideList[_currentCar].time_cahrge,
        "taxi_type": rideList[_currentCar].catType != ""
            ? rideList[_currentCar].catType
            : "Auto",
        "cancel_charge": rideList[_currentCar].cancellation_charges,
        "delivery_type": rideList[_currentCar].catType != "" &&
                rideList[_currentCar].catType != "Auto"
            ? "2"
            : "1",
        "paymenttype": "Wait For Payment", //paymentType,
        "taxi_id": rideList[_currentCar].taxi_id,
        //"car_categories":rideList[_currentCar].i
        "transaction": "Wait For Payment", //paymentType,
        "surge_percentage": surgePer,
        'fuel_type': "${rideList[_currentCar].fuel_type}",
      };
      if (promoDiscount != "0") {
        params['promo_discount'] = double.parse(promoDiscount).toString();
        params['promo_code'] = promoCon.text.toString();
      }
      print("ADD RIDE PARAM =====>  $params");
      //return;
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/booking_trip"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FindingRidePage(
                    widget.source,
                    widget.destination,
                    widget.pickAddress,
                    widget.dropAddress,
                    paymentType,
                    response['booking_id'].toString(),
                    rideList[_currentCar].rate_per_km,
                    // (surge +
                    //         gst +
                    //         double.parse(rideList[_currentCar].intailrate)
                    //             .roundToDouble() -
                    //         double.parse(promoDiscount))
                    //     .roundToDouble()
                    //     .toStringAsFixed(2),
                    // (double.parse(rideList[_currentCar].rate_per_km)+double.parse(rideList[_currentCar].base_fare)-double.parse(promoDiscount)+gst+surge).toStringAsFixed(2),
                    distance)));
        UI.setSnackBar("Booking Confirmed", context);
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

  String promoDiscount = "0";
  int? bookingId;

  paymentCalculate(double? amount) {
    partPayment = double.parse(amount.toString()) * 0.30;
  }

  String? distanceAmt;
  double? partPayment, amounFinal;
  addScheduleRides() async {
    try {
      setState(() {
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
        'unit_price': unitPrice.toString(),
        "amount": (double.parse(rideList[_currentCar].intailrate) -
                double.parse(promoDiscount) +
                gst +
                surge)
            .toStringAsFixed(2),
        "paid_amount": (double.parse(rideList[_currentCar].intailrate) -
                double.parse(promoDiscount) +
                gst +
                surge)
            .toStringAsFixed(2),
        "gst_amount": rideList[_currentCar].tax_amount,
        "total_time": '${widget.time.replaceAll("Hr.", "")}',
        "taxi_id": rideList[_currentCar].taxi_id,
        "surge_amount": surge.toStringAsFixed(2),
        "distance": rideList[_currentCar].distance,
        "km": rideList[_currentCar].distance,
        "admin_commission": rideList[_currentCar].admin_commission,
        "taxi_type": rideList[_currentCar].catType != ""
            ? rideList[_currentCar].catType
            : "Auto",
        "delivery_type": rideList[_currentCar].catType != "" &&
                rideList[_currentCar].catType != "Auto"
            ? "2"
            : "1",
        "rate_per_km": rideList[_currentCar].rate_per_km,
        "base_fare": double.parse(rideList[_currentCar].base_fare).toString(),
        "time_amount": rideList[_currentCar].time_cahrge,
        "paymenttype": "Wait For Payment", //paymentType,
        "transaction": "Wait For Payment", //paymentType,
        "cancel_charge": rideList[_currentCar].cancellation_charges,
        "pickup_time": bookingDate == null
            ? '${DateTime.now()?.hour}:${DateTime.now()?.minute}'
            : bookingDate?.minute == 0
                ? '${bookingDate?.hour}:${bookingDate?.minute}0'
                : '${bookingDate?.hour}:${bookingDate?.minute}',
        "pickup_date": bookingDate == null
            ? DateFormat("yyyy-MM-dd").format(DateTime.now())
            : DateFormat("yyyy-MM-dd").format(bookingDate!),
        "sharing_type": widget.shareType,
        "surge_percentage": surgePer,
        'vendor_id': vendorId.toString(),
        'vehicle_id': rideList[_currentCar].taxi_id,
        'order_type': bookingDate == null ? 'current' : 'schedule',
        'return_date': widget.returnDate.toString(),
        "is_parking": tollTax.toString(),
        "is_toll_tax": parking.toString(),
        'fuel_type': "${rideList[_currentCar].fuel_type}",
        "night_charge": nightCharge.toString(),
        "state_tax": stateCharge.toString()
        // 'return_time': widget.returnTime.toString()
      };
      if (promoDiscount != "0") {
        params['promo_discount'] = double.parse(promoDiscount).toString();
        params['promo_code'] = promoCon.text.toString();
      }
      print("schedule ride is $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/shedual_booking_trip"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        bookingId = response['booking_id'];
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BookingSuccess()));
        // Navigator.pop(context, "yes");
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PaymentScreen(
        //       bookingId: bookingId.toString(),
        //       paymentType: _selectedPaymentOption.toString(),
        //       amount: (double.parse(rideList[_currentCar].rate_per_km)
        //                   .roundToDouble() -
        //               double.parse(promoDiscount).roundToDouble())
        //           .toStringAsFixed(2),
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

  addInterCityRides() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "user_id": curUserId,
        "username": name,
        "pickup_address": widget.pickAddress,
        "pickup_city": widget.pickCity.replaceAll(" ", ""),
        "drop_city": widget.dropCity.replaceAll(" ", ""),
        "latitude": widget.source.latitude.toString(),
        "longitude": widget.source.longitude.toString(),
        "drop_address": widget.dropAddress,
        "drop_latitude": widget.destination.latitude.toString(),
        "drop_longitude": widget.destination.longitude.toString(),
        "amount": (double.parse(rideList[_currentCar].intailrate) -
                double.parse(promoDiscount) +
                gst +
                surge)
            .toStringAsFixed(2),
        "paid_amount": (double.parse(rideList[_currentCar].intailrate) -
                double.parse(promoDiscount) +
                gst +
                surge)
            .toStringAsFixed(2),
        "gst_amount": rideList[_currentCar].tax_amount,
        "tax_percentage": rideList[_currentCar].gst.toString(),
        "total_time": totalTime,
        "taxi_id": rideList[_currentCar].taxi_id,
        "admin_commission": rideList[_currentCar].admin_commission,
        "surge_amount": surge.toStringAsFixed(2),
        "distance": distance,
        "km": distance,
        "taxi_type": rideList[_currentCar].catType != ""
            ? rideList[_currentCar].catType
            : "Auto",
        "delivery_type": rideList[_currentCar].catType != "" &&
                rideList[_currentCar].catType != "Auto"
            ? "2"
            : "1",
        "rate_per_km": rideList[_currentCar].rate_per_km,
        "base_fare": double.parse(distance) >= 1
            ? rideList[_currentCar].base_fare
            : rideList[_currentCar].minFare,
        "time_amount": rideList[_currentCar].time_cahrge,
        "paymenttype": paymentType,
        "transaction": paymentType,
        "cancel_charge": rideList[_currentCar].cancellation_charges,
        "pickup_time": bookingDate!.minute == 0
            ? '${bookingDate!.hour}:${bookingDate!.minute}0'
            : '${bookingDate!.hour}:${bookingDate!.minute}',
        "pickup_date": DateFormat("yyyy-MM-dd").format(bookingDate!),
        "sharing_type": widget.shareType == "Share" ? "1" : "0",
      };
      if (promoDiscount != "0") {
        params['promo_discount'] = double.parse(promoDiscount).toString();
        params['promo_code'] = promoCon.text.toString();
      }
      print(params);
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/intercity_booking"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        Navigator.pop(context, "yes1");
        UI.setSnackBar("Booking Confirmed", context);
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

  String? vendorId,
      vehicleId,
      unitPrice,
      tollTax,
      parking,
      stateCharge,
      nightCharge;
  getRides(totalTime) async {
    print('time ${widget.time} diatcnce $distance');
    try {
      Map params = {
        "distance": widget.time == "6 Hr."
            ? "60"
            : widget.time == "8 Hr."
                ? "80"
                : widget.time == "10 Hr."
                    ? "100"
                    : widget.time == "12 Hr."
                        ? "120"
                        : widget.time.length == 0 ||
                                widget.time.isEmpty ||
                                widget.time != null
                            ? (double.parse(distance) >= 1 ? distance : "0")
                            : "",
        'time': '${widget.time.replaceAll("Hr.", "")}',
        "pickup_lat_long":
            "${widget.source.latitude.toString()},${widget.source.longitude.toString()}",
        // "lang": widget.source.longitude.toString(),
        "drop_location": widget.dropCity.replaceAll(" ", ""),
        "pickup_location": widget.pickCity.replaceAll(" ", ""),
        "pickup_date_time": widget.bookingDate == null
            ? DateTime.now().toString()
            : widget.bookingDate.toString(),
        'drop_lat_long':
            '${widget.destination.latitude.toString()},${widget.destination.longitude.toString()}',
        "user_id": curUserId,
        // "booking_type": widget.shareType != ""
        //     ? "schedule"
        //     : bookingDate != null
        //         ? "schedule"
        //         : "",
        "booking_type": bookingDate != null ? "schedule" : "current",
        "order_type": widget.rideType.toString(),
        'return_date': widget.returnDate.toString(),
        // 'return_time': widget.returnTime.toString()
      };
      print("GET CAN CHARGE ;;;;;;;;;;;; $params");
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "booking/get_ride"), params);
      List<RidesModel> tempList = [];
      if (response['status'] &&
          response['data'] != null &&
          response['data'].length > 0) {
        for (var v in response['data']) {
          setState(() {
            unitPrice = v['unit_price'].toString();
            tollTax = v['toll_tax'].toString();
            stateCharge = v['state_tax'].toString();
            nightCharge = v['night_charge'].toString();
            parking = v['parking'].toString();
            print("unit price is $unitPrice $tollTax ${stateCharge}");
            tempList.add(new RidesModel(
              v['taxi_id'],
              v['vendor_id'].toString(),
              v['cartype'],
              v['carmodel'],
              v['intialkm'].toString(),
              double.parse(v['amount'] != null
                      ? v['amount'].toString()
                      : v['fixed_amount'] != null
                          ? v['fixed_amount'].toString()
                          : "0")
                  .toString(),
              double.parse(v['basic_fare'] != null
                      ? v['basic_fare'].toString()
                      : "0")
                  .toString(),
              double.parse(v['time_cahrge'] != null
                      ? v['time_cahrge'].toString()
                      : "0")
                  .toStringAsFixed(2),
              double.parse(v['rate_per_km'].toString()).toStringAsFixed(2),
              double.parse(v['main_rate_per_km'].toString()).toStringAsFixed(2),
              v['car_image'].toString(),
              v['serge'].toString(),
              v['gst'].toString(),
              v['surge_charge'],
              v['car_categories'],
              v['min_fare'] != null
                  ? double.parse(v['min_fare']).toString()
                  : "0",
              double.parse(v['cancellation_charges'].toString()).toString(),
              v['admin_commission'].toString(),
              v['fuel_type'].toString(),
              v['seating_capacity'].toString(),
              v['insurance_expiry'].toString(),
              v['pollution_expiry'].toString(),
              v['vehicle_no'].toString(),
              v['luggage_carrier'].toString(),
              v['luggage_capacity'].toString(),
              v['distance'].toString(),
              v['extra_price'].toString(),
              v['tax_amount'].toString(),
              v['cancellation_charge'].toString(),
              v['service_charge'].toString(),
            ));
          });
        }
        setState(() {
          rideList = new List.from(tempList);
        });
        getPromo();
        getJoiningBonus();
        // paymentCalculate();
        if (rideList[_currentCar].surge_charge != null &&
            rideList[_currentCar].surge_charge.length > 0 &&
            rideList[_currentCar].surge_charge[0]['time_on_off'].toString() !=
                "CLOSED") {
          surge = ((double.parse(rideList[_currentCar]
                      .surge_charge[0]['amount']
                      .toString()) *
                  double.parse(rideList[_currentCar].intailrate)) /
              100);
        } else {
          surge = 0;
        }
      } else {
        UI.setSnackBar("Rides Not Available", context);
        Navigator.pop(context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }

  String totalTime = "0".toString();
  String distance = "0".toString();

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
      // http.Response response = await http.get(Uri.parse(
      //     "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"));
      // print("GET TIME::::::" + response.body.toString());
      // Map res = jsonDecode(response.body);
      // List<dynamic> data = res['rows'][0]['elements'];
      // //  String totalTime = "0 Mins".toString();
      // if (response.body.contains("text")) {
      //   totalTime = (int.parse(data[0]['duration']['value'].toString()) / 60)
      //       .round()
      //       .toString();
      //   distance =
      //       (double.parse(data[0]['distance']['value'].toString()) / 1000)
      //           .toStringAsFixed(2);
      // }
      // getRides(totalTime);
      getRides(0);
      // print("TOTAL TIME" + totalTime + "");
    } else {
      print("TIME 0");
      getRides("0");
    }
  }

  getDriver() async {
    try {
      setState(() {
        driveStatus = true;
        driverList.clear();
      });
      Map params = {
        "lat": widget.source.latitude.toString(),
        "lang": widget.source.longitude.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl + "get_driver_by_lat_lang"), params);

      if (response['status']) {
        for (var v in response['data']) {
          driverList.add(new DriverModel(
              v['id'].toString(),
              v['name'].toString(),
              v['user_name'].toString(),
              v['car_no'].toString(),
              v['phone'].toString(),
              v['latitude'].toString(),
              v['longitude'].toString(),
              v['rating'].toString(),
              v['user_image'].toString(),
              v['car_type'].toString()));
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

  List<PromoModel> promoList = [];
  String bonusAmount = '';
  String minRideAmount = '';

  getPromo() async {
    try {
      setState(() {
        driveStatus = true;
        promoList.clear();
      });
      print(rideList[_currentCar].catType);
      Map params = {
        "lat": widget.source.latitude.toString(),
        "lang": widget.source.longitude.toString(),
        "user_id": curUserId,
        "vehicle_type": rideList[_currentCar].catType != "" &&
                rideList[_currentCar].catType != "Auto"
            ? "2"
            : "1",
      };
      print('PrintData:_____${params}______');
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_promo_code"), params);

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

  getJoiningBonus() async {
    try {
      setState(() {
        driveStatus = true;
        driverList.clear();
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
          if (double.parse(rideList[_currentCar].intailrate) >
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

  applyCode(code) async {
    try {
      setState(() {
        saveStatus = false;
        driverList.clear();
      });
      double gst = 0;
      if (rideList[_currentCar].gst != null &&
          rideList[_currentCar].gst != "") {
        gst = ((double.parse(rideList[_currentCar].gst) *
                double.parse(rideList[_currentCar].intailrate)) /
            100);
      }
      print(gst);
      double surge = 0;
      if (widget.bookingDate == null &&
          !rideList[_currentCar].serge.contains("Not") &&
          rideList[_currentCar].surge_charge.length > 0) {
        if (rideList[_currentCar].surge_charge[0]['time_on_off'].toString() !=
            "CLOSED") {
          surge = ((double.parse(rideList[_currentCar]
                      .surge_charge[0]['amount']
                      .toString()) *
                  double.parse(rideList[_currentCar].intailrate)) /
              100);
        } else {
          surge = 0;
        }
      }
      print(widget.bookingDate);
      print(surge);
      print(rideList[_currentCar].intailrate);
      gst += surge + double.parse(rideList[_currentCar].intailrate);
      Map params = {
        "final_total": gst.toString(),
        "promo_code": code,
        "user_id": curUserId,
      };
      https: //productsalphawizz.com/taxi/api/Payment/get_promo_code
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/validate_promo_code5"), params);
      // Uri.parse(baseUrl1 + "Payment/apply_promo_code"),params);

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
                    .toString()
                : "0";
            /*rideList[_currentCar].intailrate =
                (double.parse(rideList[_currentCar].intailrate) -
                        double.parse(promoDiscount))
                    .toStringAsFixed(0);*/
          });
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
/* Future<RideModel?> getRide(distance) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://productsalphawizz.com/taxi/api/products/get_cab_charge'));
    request.fields.addAll({'distance': '$distance'});

    http.StreamedResponse response = await request.send();
     print(request.fields);
    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      print(str);
      return RideModel.fromJson(json.decode(str));
    } else {
      return null;
    }
  }*/
}
