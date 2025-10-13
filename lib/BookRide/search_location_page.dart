import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pristine_andaman/BookRide/choose_cab_page.dart';
import 'package:pristine_andaman/BookRide/ride_booked_page.dart';
import 'package:pristine_andaman/DrawerPages/Rides/intercity_rides.dart';
import 'package:pristine_andaman/DrawerPages/Rides/rental_rides.dart';
import 'package:pristine_andaman/DrawerPages/app_drawer.dart';
import 'package:pristine_andaman/DrawerPages/notification_list.dart';
import 'package:pristine_andaman/Model/category_model.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/Model/share_ride_model.dart';
import 'package:pristine_andaman/Model/slider_model.dart';
import 'package:pristine_andaman/Model/wallet_model.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/location_details.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/referCodeService.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

import '../Model/driver_model.dart';
import '../Model/location_model.dart';
import '../Model/premium_slider_model.dart';
import '../Model/promo_code.dart';
import '../Model/rental_model_new.dart';
import '../Model/rides_model.dart';
import '../utils/PushNotificationService.dart';
import '../utils/new_utils/MapScreen.dart';

class SearchLocationPage extends StatefulWidget {
  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage>
    with WidgetsBindingObserver {
  TextEditingController pickupCon = new TextEditingController();
  TextEditingController dropCon = new TextEditingController();
  TextEditingController pickupCityCon = new TextEditingController();
  TextEditingController dropCityCon = new TextEditingController();
  List<CategoryModel> catList = [
    //   CategoryModel("5", "Pool Ride", "assets/pool_ride.png"),
  ];

  // List<TimeModel> timeList = [
  //   TimeModel("1", "1 Hour", "₹200", "20Km", "₹200"),
  //   TimeModel("2", "2 Hour", "₹350", "40Km", "₹175"),
  //   TimeModel("3", "3 Hour", "₹450", "60Km", "₹150"),
  // ];

  String? selectedHour;
  String? selectedAir;
  int sliderIndex = 0;

  List<String> hourList = [
    '6 Hr.',
    '8 Hr.',
    '10 Hr.',
    '12 Hr.',
  ];
  List<String> airportType = ['Airport Pick Up', 'Airport Drop'];
  String? _currentAddress;
  Position? _currentPosition;
  LatLng? _currentPositions;

  Future<void> _getCurrentLocations() async {
    print("hererereer");
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPositions = LatLng(position.latitude, position.longitude);
    });
    print("ddddddddddddd $_currentPositions");
  }

  Future<void> _getCurrentLocation() async {
    print("locationfuntcion===========");
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
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

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    await _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      print(e);
    }
  }

  sendSosRequest() async {
    await _getCurrentLocation();

    try {
      Map params = {
        "user_id": curUserId.toString(),
        'lat': _currentPosition?.latitude.toString() ?? '',
        'long': _currentPosition?.longitude.toString() ?? '',
        'address': _currentAddress
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/user_sos_contact"), params);
      Fluttertoast.showToast(msg: response['message']);
    } on TimeoutException catch (_) {
      UI.setSnackBar("Something Went Wrong", context);
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

  String distance = "0".toString();
  String totalTime = "0".toString();
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

  Future getEstimated() async {
    calculateDistance(latitude, longitude, dropLatitude, dropLongitude);
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${latitude},${longitude}&destinations=${dropLatitude},${dropLongitude}&key=AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU'));
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
        getRides('');
      } else {}
    } else {
      return null;
    }
  }

  int _currentCar = 0;
  String promoDiscount = "0";

  getRides(totalTime) async {
    try {
      Map params = {
        "distance": (double.parse(distance) >= 1 ? distance : "0"),
        'time': '',
        "pickup_lat_long": "${latitude},${longitude}",
        // "lang": widget.source.longitude.toString(),
        "drop_location": dropCon.text,
        "pickup_location": pickupCon.text,
        "pickup_date_time": bookingDate == null
            ? DateTime.now().toString()
            : bookingDate.toString(),
        'drop_lat_long': '${dropLatitude},${dropLongitude}',
        "user_id": curUserId,
        // "booking_type": widget.shareType != ""
        //     ? "schedule"
        //     : bookingDate != null
        //         ? "schedule"
        //         : "",
        "booking_type": bookingDate != null ? "schedule" : "current",
        "order_type": '',
        'return_date': returnDate.toString(),
        'return_time': returnTime.toString()
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
        "lat": latitude.toString(),
        "lang": longitude.toString(),
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

  bool loadingButton = false;
  vehicleCardBike(RentalModel rentList, int index) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              bikeIndex = index;
            });

            print(
                "this is current cabid ======>>> ${timeIndex.toString()} ${rentList.cabId}");
          },
          child: Container(
            margin: EdgeInsets.only(right: getWidth(5)),
            height: getHeight(160),
            // width: getWidth(110),
            padding: EdgeInsets.all(getWidth(10)),
            decoration: boxDecoration(
                bgColor: bikeIndex == index
                    ? MyColorName.primaryLite.withOpacity(0.1)
                    : Colors.transparent,
                radius: 5,
                color: MyColorName.colorTextPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  rentList.carCategories == "1" ? "Auto" : "Car",
                  fontSize: 8.sp,
                  fontFamily: fontMedium,
                  textColor: MyColorName.appbarBg,
                ),
                boxHeight(10),
                Image.asset(
                  vehicleType == 1
                      ? "assets/cars/car2.png"
                      : "assets/cars/car1.png",
                  height: getHeight(50),
                  width: getWidth(50),
                  fit: BoxFit.fill,
                ),
                boxHeight(10),
                text(
                  rentList.hoursData![rentList.selectedIndex!].hours
                          .toString() +
                      " Minutes",
                  fontSize: 10.sp,
                  fontFamily: fontMedium,
                  textColor: MyColorName.appbarBg,
                ),
                // boxHeight(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "₹" +
                          rentList
                              .hoursData![rentList.selectedIndex!].fixedAmount
                              .toString(),
                      fontSize: 9.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    boxWidth(5),
                    text(
                      "₹" + rentList.ratePerHour.toString() + "/mins",
                      fontSize: 7.sp,
                      fontFamily: fontRegular,
                      textColor: MyColorName.appbarBg,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      "₹" +
                          '${rentList.ratePerKm.toString()}/Km after ' +
                          rentList.hoursData![rentList.selectedIndex!].fixedKm
                              .toString() +
                          "Kms",
                      fontSize: 7.sp,
                      fontFamily: fontRegular,
                      textColor: MyColorName.appbarBg,
                    ),
                    // text(
                    //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                    //   + "kms",
                    //   fontSize: 7.sp,
                    //   fontFamily: fontRegular,
                    //   textColor: MyColorName.appbarBg,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        rentList.hoursData!.length > 1
            ? Row(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      if (rentList.selectedIndex! != 0) {
                        setState(() {
                          tempList[index].selectedIndex =
                              tempList[index].selectedIndex! - 1;
                        });
                      }
                    },
                    mini: true,
                    backgroundColor: rentList.selectedIndex! == 0
                        ? Colors.grey
                        : Colors.black,
                    child: Icon(Icons.keyboard_arrow_left),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      if (rentList.selectedIndex! !=
                          rentList.hoursData!.length - 1) {
                        setState(() {
                          tempList[index].selectedIndex =
                              tempList[index].selectedIndex! + 1;
                        });
                      }
                    },
                    mini: true,
                    backgroundColor: rentList.selectedIndex! ==
                            rentList.hoursData!.length - 1
                        ? Colors.grey
                        : Colors.black,
                    child: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              )
            : SizedBox()
      ],
    );
  }

  String paymentType = "Cash";

  /* vehicleCardCar(CarData rentList, int index) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width / 3 - 10,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: rentList.hoursData!.length,
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                setState(() {
                  timeIndex = index;
                });
                print(
                    "this is current cabid ======>>> ${timeIndex.toString()} ${carRentList[index].cabId}");
              },
              child: Container(
                margin: EdgeInsets.only(right: getWidth(5)),
                height: getHeight(150),
                // width: getWidth(110),
                padding: EdgeInsets.all(getWidth(10)),
                decoration: boxDecoration(
                    bgColor: timeIndex == index
                        ? MyColorName.primaryLite.withOpacity(0.1)
                        : Colors.transparent,
                    radius: 5,
                    color: MyColorName.colorTextPrimary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(
                      rentList.carModel != null
                          ? rentList.carModel.toString()
                          : "Auto",
                      fontSize: 8.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    boxHeight(10),
                    Image.asset(
                      rentList.carModel != null
                          ? "assets/cars/car2.png"
                          : "assets/cars/car1.png",
                      height: getHeight(50),
                      width: getWidth(50),
                      fit: BoxFit.fill,
                    ),
                    boxHeight(10),
                    text(
                      rentList.hoursData![i].hours.toString() + " Minutes",
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: MyColorName.appbarBg,
                    ),
                    // boxHeight(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          "₹" + rentList.hoursData![i].fixedAmount.toString(),
                          fontSize: 9.sp,
                          fontFamily: fontMedium,
                          textColor: MyColorName.appbarBg,
                        ),
                        boxWidth(5),
                        text(
                          "₹" + rentList.ratePerHour.toString() + "/mins",
                          fontSize: 7.sp,
                          fontFamily: fontRegular,
                          textColor: MyColorName.appbarBg,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          "₹" +
                              '${rentList.ratePerKm.toString()}/Km after ' +
                              rentList.hoursData![i].fixedKm.toString() +
                              "Kms",
                          fontSize: 7.sp,
                          fontFamily: fontRegular,
                          textColor: MyColorName.appbarBg,
                        ),
                        // text(
                        //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                        //   + "kms",
                        //   fontSize: 7.sp,
                        //   fontFamily: fontRegular,
                        //   textColor: MyColorName.appbarBg,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }*/
  getNumber() async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
      };
      var res = await http.get(
        Uri.parse(baseUrl1 + "Authentication/get_setting"),
      );
      Map response = jsonDecode(res.body);
      print(response);
      if (response['status']) {
        var data = response["data"];
        print(data);
        setState(() {
          userNumber = data['user_number'];
          contactEmail = data['contact_email'];
          contactNo = data['contact_number'];
          cancelTime = data['ride_cancellation_time'];
        });
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }

  List<ShareRideModel> shareRideList = [];
  double dropLatitude = 0, dropLongitude = 0;
  bool sharing = false;
  @override
  void initState() {
    super.initState();
    _getCurrentLocations();
    getSlider();
    getPremiumSlider();
    getAvailableLocation();
    WidgetsBinding.instance.addObserver(this);
    getLocation();
    PushNotificationService notificationService = PushNotificationService(
        context: context,
        onResult: (result) {
          getBookInfo();
          //  getCurrentInfo();
          //getRides("3");
        });
    notificationService.initialise();
    // listenDeepLinkData(context);
    registerToken();
    getProfile();
    getCurrentInfo(first: true);
    getBookInfo();

    getRental();
    getNumber();
    // getTime1(
    //     latitude.toString(), longitude.toString(), dropLatitude, dropLongitude);
    // getWallet();
  }

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool background = false;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (background) {
          background = false;
          getCurrentInfo(first: true);
          getBookInfo();

          getRides("3");
          // getRental();
          print("app in resumed from background");
        }
        //you can add your codes here
        break;
      case AppLifecycleState.inactive:
        background = true;
        print("app is in inactive state");
        break;
      case AppLifecycleState.paused:
        background = true;
        print("app is in paused state");
        break;
      case AppLifecycleState.detached:
        background = true;
        print("app has been removed");
        break;
      case AppLifecycleState.hidden:
        background = true;
        print("app has been hidden");
        // TODO: Handle this case.
        break;
    }
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
        Uri.parse(baseUrl1 + "users/getWallet/${curUserId}"),
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

  List<RentalModel> bikeRentList = [];
  List<RentalModel> carRentList = [];
  List<RentalModel> tempList = [];
  getShareRide() async {
    Map param = {
      "pic_city": pickupCityCon.text.replaceAll(" ", ""),
      "drop_city": dropCityCon.text.replaceAll(" ", ""),
    };
    try {
      Map data = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/ride_check_booking"), param);
      setState(() {
        loadingButton = false;
        shareRideList.clear();
      });
      if (data['status']) {
        for (var v in data['booking_id']) {
          setState(() {
            shareRideList.add(ShareRideModel.fromJson(v));
          });
        }
      }
    } catch (e) {
      setState(() {
        loadingButton = false;
      });
    }
  }

  getRental() async {
    Map data = await apiBase.getAPICall(Uri.parse(baseUrl1 + "ride/rental"));
    bikeRentList.clear();
    carRentList.clear();
    //Map data = jsonDecode(response.body);
    if (data['status']) {
      for (var v in data['bike_data']) {
        bikeRentList.add(RentalModel.fromJson(v));
        print(
            "this is bike list ======>>>>> ${bikeRentList[0].hours.toString()}");
      }
      setState(() {
        tempList = bikeRentList.toList();
      });
      for (var v in data['car_data']) {
        carRentList.add(RentalModel.fromJson(v));
        print(
            "this is car list ======>>>>> ${carRentList[0].hours.toString()}");
      }
    }
  }

  bool dialogOpen = false;
  // getRidess(type, {bool first = false}) async {
  //   try {
  //     setState(() {
  //       loading = true;
  //     });
  //     Map params = {
  //       "user_id": curUserId,
  //       "type": type,
  //     };
  //     print("ALL COMPLETE RIDE PARAM ====== $params");
  //     Map response = await apiBase.postAPICall(
  //         Uri.parse(baseUrl1 + "Payment/get_all_complete_user"), params);
  //
  //     setState(() {
  //       loading = false;
  //       rideList.clear();
  //     });
  //     if (response['status']) {
  //       print(response['data']);
  //       for (var v in response['data']) {
  //         if (v['transaction'].toString().contains("Wait") &&
  //             v['accept_reject'] == "3") {
  //           setState(() {
  //             rideList.add(MyRideModel.fromJson(v));
  //           });
  //         }
  //       }
  //
  //       //await Future.delayed(Duration(seconds: 2));
  //       if (rideList.isNotEmpty && first && !dialogOpen) {
  //         dialogOpen = true;
  //         var result = await showDialog(
  //             context: context,
  //             barrierDismissible: false,
  //             builder: (context) => RateRideDialog(
  //                   rideList[0],
  //                   check: false,
  //                   from: true,
  //                 ));
  //         if (result != null && result) {
  //           dialogOpen = false;
  //           getProfile();
  //           getRides("3");
  //         }
  //       }
  //     } else {}
  //   } on TimeoutException catch (_) {
  //     UI.setSnackBar(getTranslated(context, "WRONG")!, context);
  //   }
  // }

  getLocation() {
    GetLocation location = new GetLocation((result) {
      if (mounted) {
        setState(() {
          var first = result.first;
          address =
              '${first.name},${first.subLocality},${first.locality},${first.country}';
          latitude = latitudeFirst;
          longitude = longitudeFirst;
          pickupCon.text = address;
          pickupCityCon.text = result.first.locality;
          print(pickupCityCon.text);
        });
      }
    });
    location.getLoc();
  }

  // void listenDeepLinkData(BuildContext context) async {
  //   final PendingDynamicLinkData? initialLink =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   if (initialLink != null) {
  //     final Uri deepLink = initialLink.link;
  //     // Example of using the dynamic link to push the user to a different screen
  //     print("deep link ${deepLink}");
  //     if (deepLink != "" && deepLink.toString().contains("/")) {
  //       print(deepLink.toString().split('?').last);
  //       getBookingInfo(deepLink.toString().split('?').last);
  //     }
  //   } else {
  //     print("deep link");
  //   }
  //   FirebaseDynamicLinks.instance.onLink.listen(
  //     (pendingDynamicLinkData) {
  //       // Set up the `onLink` event listener next as it may be received here
  //       if (pendingDynamicLinkData != null) {
  //         final Uri deepLink = pendingDynamicLinkData.link;
  //         // Example of using the dynamic link to push the user to a different screen
  //         print("deep link ${deepLink}");
  //         if (deepLink != "" && deepLink.toString().contains("/")) {
  //           print(deepLink.toString().split('?').last);
  //           getBookingInfo(deepLink.toString().split('?').last);
  //         }
  //       }
  //     },
  //   );
  //   /*FlutterBranchSdk.initSession().listen((data) {
  //     print("data" + data.toString());
  //     if (data['codeId'] != null) {
  //       getBookingInfo(data['codeId']);
  //     }
  //
  //     print("temp = ${data['codeId']}");
  //   });*/
  // }

  bool loading = true;
  bool loadingRental = false;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;

  showConfirm(MyRideModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "RIDE_INFO")!,
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
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
                          child: text(model.pickupAddress!,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  model.dropAddress != null
                      ? Row(
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: boxDecoration(
                                  radius: 100, bgColor: Colors.red),
                            ),
                            boxWidth(10),
                            Expanded(
                                child: text(model.dropAddress!,
                                    fontSize: 9.sp,
                                    fontFamily: fontRegular,
                                    textColor: Colors.black)),
                          ],
                        )
                      : SizedBox(),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  model.transaction != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("${getTranslated(context, "PAYMENT_MODE")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text(model.transaction!,
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "RIDE_TYPE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(model.bookingType!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text("${getTranslated(context, "BOOKING_ON")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      Expanded(
                          child: text(getDate(model.dateAdded!),
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  model.bookingType != "Rental Booking"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context1);
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                              },
                              child: Container(
                                width: 30.w,
                                height: 5.h,
                                decoration: boxDecoration(
                                    radius: 5, bgColor: Colors.grey),
                                child: Center(
                                    child: text(
                                        getTranslated(context, "CANCEL")!,
                                        fontFamily: fontMedium,
                                        fontSize: 10.sp,
                                        isCentered: true,
                                        textColor: Colors.white)),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context1);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RideBookedPage(
                                              model,
                                              from: true,
                                            )));
                              },
                              child: Container(
                                width: 30.w,
                                height: 5.h,
                                decoration: boxDecoration(
                                    radius: 5,
                                    bgColor: Theme.of(context).primaryColor),
                                child: Center(
                                    child: text(getTranslated(context, "VIEW")!,
                                        fontFamily: fontMedium,
                                        fontSize: 10.sp,
                                        isCentered: true,
                                        textColor: Colors.white)),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
          );
        });
  }

  getSlider() async {
    try {
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "authentication/get_sliders"),
      );
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        sliderImages = (response['data'] as List)
            .map((e) => SliderData.fromJson(e))
            .toList();
        setState(() {});
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

  getPremiumSlider() async {
    try {
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "authentication/get_premium_sliders"),
      );
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        premiumSliderImages = (response['data'] as List)
            .map((e) => PremiumSliderData.fromJson(e))
            .toList();
        setState(() {});
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

  void _showCitySelector() async {
    final result = await showDialog<LocationData>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a City'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableLocationList
                  .map((city) => RadioListTile<LocationData>(
                        title: Text(city.location ?? ''),
                        value: city,
                        groupValue: selectedCity,
                        onChanged: (value) {
                          print("select city ${selectedCity}");
                          setState(() {
                            selectedCity = value;
                          });
                          print("select city ${selectedCity}");
                          Navigator.pop(context, value);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedCity = result;
      });
    }
  }

  LocationData? selectedCity;
  List<LocationData> availableLocationList = [];
  getAvailableLocation() async {
    try {
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "authentication/get_locations"),
      );
      setState(() {
        saveStatus = true;
        walletList.clear();
      });
      if (response['status']) {
        availableLocationList = (response['data'] as List)
            .map((e) => LocationData.fromJson(e))
            .toList();
        selectedCity = availableLocationList.isNotEmpty
            ? availableLocationList.first
            : null;
        setState(() {});
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

  getBookingInfo(tempRefer) async {
    try {
      setState(() {
        saveStatus = false;
      });
      print(tempRefer);
      Map params = {
        "booking_id": tempRefer.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/getBookingid"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var v = response["data"];
        showConfirm(MyRideModel.fromJson(v));
        //print(data);
      } else {}
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  getProfile() async {
    try {
      setState(() {
        saveStatus = false;
      });
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Map params = {
        "user_id": curUserId.toString(),
        "device_info": androidInfo.id.toString(),
      };

      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "get_profile"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status']) {
        var data = response["data"];
        print(data['wallet_amount']);
        setState(() {
          name = data['username'];
          emergencyName = data['emergency_name'] ?? '';
          points = double.parse(data['point_value']);
          mobile = data['mobile'];
          emergencyMobile = data['emergency_mobile'] ?? '';

          email = data['email'];
          emergencyEmail = data['emergency_gmail'] ?? '';

          gender1 = data['gender'];
          dob = data['dob'];
          isFirstUser = data['first_order'] ?? '';
          password = data['new_password'] ?? '';
          walletAmount =
              data['wallet_amount'] != null && data['wallet_amount'] != ""
                  ? double.parse(data['wallet_amount'])
                  : 0;
          image =
              response['image_path'].toString() + data['user_image'].toString();
          imagePath = response['image_path'].toString();
          refer = data['referral_code'];
        });

        print("IMAGE========" + imagePath.toString());
        final referCodeService = ReferCodeService(context);
        referCodeService.init(null);
      } else {
        UI.setSnackBar(response['message'], context);
        Common.logoutApi();
        Navigator.pushNamedAndRemoveUntil(context, "Login", (route) => false);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  String count = "0";

  getCount() async {
    try {
      setState(() {
        saveStatus = false;
      });
      Map params = {
        "driver_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/count_noti_driver"), params);

      if (response['status']) {
        count = response["noti_count"].toString();
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

  DateTime? currentBackPressTime;

  Future<bool> onWill() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Common().toast("Press back again to exit");
      return Future.value(false);
    }
    exit(1);
    return Future.value();
  }

  GoogleMapController? _mapController;

  String? selectCabType;
  int currentIndex = 0, timeIndex = 0, vehicleType = 0, bikeIndex = 0;
  List<SliderData> sliderImages = [];
  List<PremiumSliderData> premiumSliderImages = [];
  @override
  Widget build(BuildContext context) {
    catList = [
      CategoryModel("1", "Current Booking", "assets/current_booking.png"),
      CategoryModel("2", "Scheduled Booking", "assets/schedule_booking.png"),
      // CategoryModel("3", "Airport", "assets/svg/airport.svg"),
      // CategoryModel("4", "Hourly", "assets/svg/hourly.svg"),
    ];
    var theme = Theme.of(context);

    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 4, // controls shadow height
          shadowColor: Colors.black.withOpacity(0.2),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: SvgPicture.asset(
                  "assets/svg/drawer_icon.svg",
                  height: 16,
                  color: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          // title: Text(
          //   getTranslated(context, "BOOK_YOUR_RIDE")!.toUpperCase(),
          //   style: TextStyle(fontSize: 16, color: Colors.black),
          // ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: SvgPicture.asset("assets/svg/Notification.svg",
                  color: Colors.black),
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
                if (result != null) {
                  if (result == "yes") {
                    setState(() {
                      count = "0";
                    });
                    return;
                  }
                  getBookingInfo(result);
                }
              },
            ),
            // UI.commonIconButton(
            //   message: "Refresh",
            //   iconData: Icons.refresh,
            //   onPressed: ()async {
            //     getLocation();
            //     getRides("3");
            //     getCurrentInfo();
            //     getBookInfo();
            //     getProfile();
            //   },
            // ),
            // UI.commonIconButton(
            //   message: "Subscriptions",
            //   iconData: Icons.subscriptions,
            //   onPressed: ()async {
            //     var result = await Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => PlanScreen()));
            //     if (result != null) {
            //
            //     }
            //   },
            // ),
            // UI.commonIconButton(
            //   message: "Notifications",
            //   iconData: Icons.notifications_none,
            //   onPressed: ()async {
            //     var result = await Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => NotificationScreen()));
            //     if (result != null) {
            //       if (result == "yes") {
            //         setState(() {
            //           count = "0";
            //         });
            //         return;
            //       }
            //       getBookingInfo(result);
            //     }
            //   },
            // ),
            // InkWell(
            //   onTap: () {
            //     _showCitySelector();
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 12, bottom: 12),
            //     child: Container(
            //       height: 30,
            //       decoration: BoxDecoration(
            //           color: MyColorName.secondary,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: Padding(
            //         padding: const EdgeInsets.all(6.0),
            //         child: Row(
            //           children: [
            //             Text(
            //               selectedCity?.location ?? '',
            //               style: TextStyle(color: Colors.white),
            //             ),
            //             SizedBox(
            //               width: 5,
            //             ),
            //             Icon(
            //               Icons.arrow_forward,
            //               size: 15,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              width: 20,
            )

            // Stack(
            //   alignment: Alignment.topRight,
            //   children: [
            //     UI.commonIconButton(
            //       message: "Notifications",
            //       iconData: Icons.notifications_none,
            //       onPressed: ()async {
            //         var result = await Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => NotificationScreen()));
            //         if (result != null) {
            //           if (result == "yes") {
            //             setState(() {
            //               count = "0";
            //             });
            //             return;
            //           }
            //           getBookingInfo(result);
            //         }
            //       },
            //     ),
            //     count != "0"
            //         ? Container(
            //             width: getWidth(18),
            //             height: getWidth(18),
            //             margin: EdgeInsets.only(
            //                 right: getWidth(3), top: getHeight(3)),
            //             decoration:
            //                 boxDecoration(radius: 100, bgColor: Colors.red),
            //             child: Center(
            //                 child: text(count.toString(),
            //                     fontFamily: fontMedium,
            //                     fontSize: 6.sp,
            //                     textColor: Colors.white)),
            //           )
            //         : SizedBox(),
            //   ],
            // ),
          ],
          toolbarHeight: 64,
        ),
        drawer: AppDrawer(
          onResult: (result) {
            if (result != null) {
              setState(() {
                saveStatus = false;
              });
              getLocation();
              getRides("3");
              getCurrentInfo();
              getBookInfo();
              getProfile();
            }
          },
        ),
        resizeToAvoidBottomInset: true,
        // floatingActionButton: rideList.isNotEmpty
        //     ? Container(
        //         margin: EdgeInsets.all(8.0),
        //         padding: EdgeInsets.all(8.0),
        //         decoration:
        //             boxDecoration(showShadow: true, bgColor: Colors.white),
        //         child: Row(
        //           children: [
        //             Expanded(
        //                 child: Text(
        //               "Your previous ${rideList[0].bookingType!} ride payment is due",
        //             )),
        //             boxWidth(10),
        //             InkWell(
        //               onTap: () async {
        //                 /*if (bookModel!.bookingType!
        //                           .toLowerCase()
        //                           .contains("schedule")) {
        //                         Navigator.push(
        //                             context,
        //                             MaterialPageRoute(
        //                                 builder: (context) =>
        //                                     MyRidesPage("1")));
        //                       } else*/
        //                 if (rideList[0]!
        //                     .bookingType!
        //                     .toLowerCase()
        //                     .contains("intercity")) {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (context) =>
        //                               InterCityRidePage("1")));
        //                 } else if (rideList[0]!
        //                     .bookingType!
        //                     .toLowerCase()
        //                     .contains("rental")) {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (context) => RentalRides(
        //                                 selected: false,
        //                               )));
        //                 } else {
        //                   var result = await showDialog(
        //                       context: context,
        //                       builder: (context) => RateRideDialog(
        //                             rideList[0],
        //                             check: false,
        //                             from: true,
        //                           ),
        //                   );
        //                   if (result != null) {
        //                     getRides("3");
        //                   }
        //                 }
        //               },
        //               child: Container(
        //                 width: 30.w,
        //                 height: 5.h,
        //                 decoration: boxDecoration(
        //                     radius: 5, bgColor: Theme.of(context).primaryColor),
        //                 child: Center(
        //                     child: text("Pay",
        //                         fontFamily: fontMedium,
        //                         fontSize: 10.sp,
        //                         isCentered: true,
        //                         textColor: Colors.white)),
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     : SizedBox(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: saveStatus
            ? RefreshIndicator(
                onRefresh: () {
                  return Future(() => null);
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Map image placeholder
                      _currentPositions == null || _currentPositions == ""
                          ? Container(
                              height: MediaQuery.of(context).size.height / 2,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : Container(
                              height: 300,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _currentPositions!,
                                  zoom: 15,
                                ),
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                                markers: {
                                  Marker(
                                    markerId: const MarkerId("currentLocation"),
                                    position: _currentPositions!,
                                    infoWindow:
                                        const InfoWindow(title: "You are here"),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueRed),
                                  ),
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                              ),
                            ),
                      SizedBox(
                        height: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Center(
                          child: Text(
                            "For saving carbon pollution by not choosing Petrol or diesel vehicle.",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     InkWell(
                      //       onTap: () {
                      //         _showCitySelector();
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //             color: MyColorName.secondary,
                      //             borderRadius: BorderRadius.circular(10)),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Row(
                      //             children: [
                      //               Icon(Icons.location_on_outlined),
                      //               SizedBox(width: 5,),
                      //               Text(
                      //                 selectedCity?.location ?? '',
                      //                 style: TextStyle(color: Colors.white),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 20,
                      //     )
                      //   ],
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     SizedBox(
                      //       width: 16,
                      //     ),
                      //     Text(
                      //       'Schedule Destination',
                      //       style: TextStyle(fontSize: 15),
                      //     ),
                      //   ],
                      // ),
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 0, right: 0, top: 5),
                      //   child: Container(
                      //     height: 200,
                      //     child: CarouselSlider.builder(
                      //       options: CarouselOptions(
                      //         viewportFraction:
                      //             0.73, // Reduce to show part of next image
                      //         autoPlay: true,
                      //         enlargeCenterPage: true,
                      //         disableCenter: true,
                      //         onPageChanged: (index, reason) {
                      //           setState(() {
                      //             sliderIndex = index;
                      //           });
                      //         },
                      //       ),
                      //       itemCount: premiumSliderImages.length ?? 0,
                      //       itemBuilder: (context, index, _) {
                      //         return InkWell(
                      //           onTap: () {
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) =>
                      //                     PremiumSliderDetails(
                      //                   sliderData: premiumSliderImages[index],
                      //                   availableLocationList: selectedCity,
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //           child: Card(
                      //             elevation: 7,
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Container(
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(10),
                      //                 color: Colors.white,
                      //               ),
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(10),
                      //                 child: FadeInImage.assetNetwork(
                      //                   placeholder: 'assets/slider_image.png',
                      //                   fit: BoxFit.fill,
                      //                   image:
                      //                       premiumSliderImages[index].image ??
                      //                           '',
                      //                   imageErrorBuilder: (c, o, s) =>
                      //                       Image.asset(
                      //                     'assets/slider_image.png',
                      //                     fit: BoxFit.fill,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(
                      //   height: 10,
                      // ),
                      // premiumSliderImages.isNotEmpty ?? false
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           AnimatedSmoothIndicator(
                      //             activeIndex:
                      //                 sliderIndex, // Use the updated index
                      //             count: premiumSliderImages.length ?? 0,
                      //             effect: ExpandingDotsEffect(
                      //               dotWidth: 8.0,
                      //               dotHeight: 8.0,
                      //               activeDotColor: MyColorName.secondary,
                      //               dotColor: Colors.grey.shade300,
                      //               spacing: 6.0,
                      //               expansionFactor: 3.0,
                      //             ),
                      //           ),
                      //         ],
                      //       )
                      //     : SizedBox(),
                      //
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // // latitude != 0
                      // //     ? MapPage(
                      // //         false,
                      // //         driveList: [],
                      // //         live: false,
                      // //         SOURCE_LOCATION: LatLng(latitude, longitude),
                      // //       )
                      // //     : Center(child: CircularProgressIndicator(color:Colors.black)),
                      // // Container(
                      // //   height: double.infinity,
                      // //   color: Colors.white.withOpacity(0.5),
                      // // ),
                      // Container(
                      //   decoration:
                      //       BoxDecoration(color: MyColorName.greyBorder),
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(
                      //         left: 16, right: 16, top: 8, bottom: 8),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //             'Explore ${selectedCity?.location ?? ''} like Never Before'),
                      //         Spacer(),
                      //         // Icon(
                      //         //   Icons.arrow_forward,
                      //         //   color: Colors.black,
                      //         // )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: Container(
                          // height: 100,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                // height: getHeight(160),
                                // padding: EdgeInsets.symmetric(horizontal: 0,),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Row(
                                    children:
                                        List.generate(catList.length, (index) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Radio<int>(
                                            value: index,
                                            groupValue: currentIndex,
                                            activeColor: Colors
                                                .green, // green like screenshot
                                            onChanged: (val) {
                                              setState(() {
                                                bookingDate = null;
                                                returnDate = null;
                                                selectedHour = null;
                                                currentIndex = val!;
                                                selectCabType = catList[val]
                                                    .name
                                                    .toString();
                                              });

                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => SelectLocationScreen(
                                              //       currentIndex: currentIndex,
                                              //       selectCabType: selectCabType,
                                              //       availableLocationList: selectedCity,
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                          ),
                                          Text(
                                            catList[index].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),

                                  // child: SingleChildScrollView(
                                  //   scrollDirection: Axis.horizontal,
                                  //   physics: AlwaysScrollableScrollPhysics(),
                                  //   child: Row(
                                  //     children:
                                  //         List.generate(catList.length, (index) {
                                  //       return InkWell(
                                  //         onTap: () {
                                  //           setState(() {
                                  //             bookingDate = null;
                                  //             returnDate = null;
                                  //             currentIndex = index;
                                  //             selectedHour = null;
                                  //           });
                                  //           print(
                                  //               "tyepindex=${catList[index].name}===========");
                                  //           selectCabType =
                                  //               catList[index].name.toString();
                                  //           Navigator.push(
                                  //             context,
                                  //             MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   SelectLocationScreen(
                                  //                 currentIndex: currentIndex,
                                  //                 selectCabType: selectCabType,
                                  //                 availableLocationList:
                                  //                     selectedCity,
                                  //               ),
                                  //             ),
                                  //           );
                                  //           /*if (index == 0) {
                                  //           setState(() {
                                  //             currentIndex = index;
                                  //           });
                                  //           return;
                                  //         }
                                  //         if (bookModel == null) {
                                  //
                                  //         } else {
                                  //           UI.setSnackBar(
                                  //               "You have an already scheduled ride", context);
                                  //         }*/
                                  //         },
                                  //         child: Container(
                                  //           margin: EdgeInsets.only(
                                  //               right: getWidth(12)),
                                  //           height: getHeight(160),
                                  //           width: getWidth(148),
                                  //           padding: EdgeInsets.all(getWidth(12)),
                                  //           // margin: EdgeInsets.all(getWidth(5)),
                                  //           decoration: boxDecoration(
                                  //             bgColor: currentIndex == index
                                  //                 ? MyColorName.lightGrey
                                  //                 : Colors.transparent,
                                  //             color: currentIndex == index
                                  //                 ? Colors.transparent
                                  //                 : Colors.grey,
                                  //             radius: 8,
                                  //           ),
                                  //           child: Column(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.center,
                                  //             crossAxisAlignment:
                                  //                 CrossAxisAlignment.center,
                                  //             children: [
                                  //               SizedBox(
                                  //                 height: 8,
                                  //               ),
                                  //               Image.asset(
                                  //                 catList[index].image,
                                  //                 scale: 4,
                                  //               ),
                                  //               // SvgPicture.asset(
                                  //               //   catList[index].image,
                                  //               //   width: getHeight(65),
                                  //               //   height: getHeight(65),
                                  //               // ),
                                  //               SizedBox(
                                  //                 height: 16,
                                  //               ),
                                  //               Text(
                                  //                 catList[index].name,
                                  //                 style: Theme.of(context)
                                  //                     .textTheme
                                  //                     .titleLarge!
                                  //                     .copyWith(
                                  //                         fontSize: 14.0,
                                  //                         fontWeight:
                                  //                             FontWeight.w700),
                                  //               ),
                                  //               // SizedBox(
                                  //               //   height: 12,
                                  //               // ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }).toList(),
                                  //   ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              // currentIndex == 2?Container(
                              //   padding: EdgeInsets.all(getWidth(15)),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //     MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       text(
                              //         getTranslated(context, "START_NOW")!,
                              //         fontSize: 9.sp,
                              //         fontFamily: fontMedium,
                              //         textColor: MyColorName.appbarBg,
                              //       ),
                              //       text("",
                              //         // "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(DateTime.now().add(Duration(hours: int.parse(rentList[0].hours.toString()))))}",
                              //         fontSize: 9.sp,
                              //         fontFamily: fontMedium,
                              //         textColor: MyColorName.appbarBg,
                              //       ),
                              //     ],
                              //   ),
                              // ):SizedBox(),

                              ///
                              // currentIndex == 2
                              //     ? Padding(
                              //         padding: const EdgeInsets.only(left: 15.0),
                              //         child: Row(
                              //           children: [
                              //             InkWell(
                              //               onTap: () {
                              //                 setState(() {
                              //                   vehicleType = 0;
                              //                   bikeIndex = 0;
                              //                   tempList = bikeRentList.toList();
                              //                 });
                              //               },
                              //               child: Container(
                              //                 margin: EdgeInsets.only(
                              //                     right: getWidth(5)),
                              //                 // height: getHeight(200),
                              //                 // width: getWidth(110),
                              //                 padding:
                              //                     EdgeInsets.all(getWidth(10)),
                              //                 decoration: boxDecoration(
                              //                     bgColor: vehicleType == 0
                              //                         ? MyColorName.primaryLite
                              //                             .withOpacity(0.1)
                              //                         : Colors.transparent,
                              //                     radius: 5,
                              //                     color: MyColorName
                              //                         .colorTextPrimary),
                              //                 child: Row(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.center,
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.center,
                              //                   children: [
                              //                     // text(
                              //                     //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
                              //                     //   fontSize: 8.sp,
                              //                     //   fontFamily: fontMedium,
                              //                     //   textColor: MyColorName.appbarBg,
                              //                     // ),
                              //                     // boxHeight(10),
                              //                     Image.asset(
                              //                       "assets/cars/car1.png",
                              //                       height: getHeight(30),
                              //                       width: getWidth(30),
                              //                       fit: BoxFit.fill,
                              //                     ),
                              //                     SizedBox(
                              //                       height: 5,
                              //                       width: 5,
                              //                     ),
                              //                     Center(
                              //                       child: text(
                              //                         "Auto",
                              //                         // rentList[0].hours.toString()+" Hour",
                              //                         fontSize: 10.sp,
                              //                         fontFamily: fontMedium,
                              //                         textColor:
                              //                             MyColorName.appbarBg,
                              //                       ),
                              //                     ),
                              //                     // Row(
                              //                     //   mainAxisAlignment:
                              //                     //   MainAxisAlignment.spaceBetween,
                              //                     //   children: [
                              //                     //     text(
                              //                     //       "₹"+rentList[index].fixedRate.toString(),
                              //                     //       fontSize: 9.sp,
                              //                     //       fontFamily: fontMedium,
                              //                     //       textColor: MyColorName.appbarBg,
                              //                     //     ),
                              //                     //     text(
                              //                     //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
                              //                     //       fontSize: 7.sp,
                              //                     //       fontFamily: fontRegular,
                              //                     //       textColor: MyColorName.appbarBg,
                              //                     //     ),
                              //                     //   ],
                              //                     // ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //             InkWell(
                              //               onTap: () {
                              //                 setState(() {
                              //                   vehicleType = 1;
                              //                   bikeIndex = 0;
                              //                   tempList = carRentList.toList();
                              //                 });
                              //               },
                              //               child: Container(
                              //                 margin: EdgeInsets.only(
                              //                     right: getWidth(5)),
                              //                 // height: getHeight(200),
                              //                 // width: getWidth(110),
                              //                 padding:
                              //                     EdgeInsets.all(getWidth(10)),
                              //                 decoration: boxDecoration(
                              //                     bgColor: vehicleType == 1
                              //                         ? MyColorName.primaryLite
                              //                             .withOpacity(0.1)
                              //                         : Colors.transparent,
                              //                     radius: 5,
                              //                     color: MyColorName
                              //                         .colorTextPrimary),
                              //                 child: Row(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.center,
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment
                              //                           .spaceBetween,
                              //                   children: [
                              //                     // text(
                              //                     //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
                              //                     //   fontSize: 8.sp,
                              //                     //   fontFamily: fontMedium,
                              //                     //   textColor: MyColorName.appbarBg,
                              //                     // ),
                              //                     // boxHeight(10),
                              //                     Image.asset(
                              //                       "assets/cars/car2.png",
                              //                       height: getHeight(30),
                              //                       width: getWidth(30),
                              //                       fit: BoxFit.fill,
                              //                     ),
                              //                     SizedBox(
                              //                       height: 5,
                              //                       width: 5,
                              //                     ),
                              //                     Center(
                              //                       child: text(
                              //                         "Car",
                              //                         // rentList[0].hours.toString()+" Hour",
                              //                         fontSize: 10.sp,
                              //                         fontFamily: fontMedium,
                              //                         textColor:
                              //                             MyColorName.appbarBg,
                              //                       ),
                              //                     ),
                              //                     boxHeight(5),
                              //                     // Row(
                              //                     //   mainAxisAlignment:
                              //                     //   MainAxisAlignment.spaceBetween,
                              //                     //   children: [
                              //                     //     text(
                              //                     //       "₹"+rentList[index].fixedRate.toString(),
                              //                     //       fontSize: 9.sp,
                              //                     //       fontFamily: fontMedium,
                              //                     //       textColor: MyColorName.appbarBg,
                              //                     //     ),
                              //                     //     text(
                              //                     //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
                              //                     //       fontSize: 7.sp,
                              //                     //       fontFamily: fontRegular,
                              //                     //       textColor: MyColorName.appbarBg,
                              //                     //     ),
                              //                     //   ],
                              //                     // ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       )
                              //     : SizedBox(),
                              currentIndex == 2
                                  ? Container(
                                      height: getHeight(255),
                                      padding: EdgeInsets.all(getWidth(15)),
                                      child:
                                          // rentList.length>0?
                                          ListView.builder(
                                              itemCount: tempList.length,
                                              // rentList[0].carCategories == "1" ? rentList[0].hoursData!.length
                                              // : rentList[1].hoursData!.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return vehicleCardBike(
                                                    tempList[index], index);
                                                //   InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       timeIndex = index;
                                                //     });
                                                //   },
                                                //   child: Container(
                                                //     margin: EdgeInsets.only(right: getWidth(5)),
                                                //     height: getHeight(150),
                                                //     // width: getWidth(110),
                                                //     padding: EdgeInsets.all(getWidth(10)),
                                                //     decoration: boxDecoration(
                                                //         bgColor: timeIndex == index
                                                //             ? MyColorName.primaryLite
                                                //                 .withOpacity(0.1)
                                                //             : Colors.transparent,
                                                //         radius: 5,
                                                //         color: MyColorName.colorTextPrimary),
                                                //     child: Column(
                                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //       children: [
                                                //         text(
                                                //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
                                                //           fontSize: 8.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         boxHeight(10),
                                                //         Image.asset(
                                                //           rentList[index].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                                                //           height: getHeight(50),
                                                //           width: getWidth(50),
                                                //           fit: BoxFit.fill,
                                                //         ),
                                                //         boxHeight(10),
                                                //         text(
                                                //           rentList[0].hoursData![0].hours.toString()+" Minutes",
                                                //           fontSize: 10.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         // boxHeight(5),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //               MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //              "₹"+rentList[0].hoursData![0].fixedAmount.toString(),
                                                //               fontSize: 9.sp,
                                                //               fontFamily: fontMedium,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             boxWidth(5),
                                                //             text(
                                                //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //           ],
                                                //         ),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             // text(
                                                //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                                                //             //   + "kms",
                                                //             //   fontSize: 7.sp,
                                                //             //   fontFamily: fontRegular,
                                                //             //   textColor: MyColorName.appbarBg,
                                                //             // ),
                                                //           ],
                                                //         ),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // )
                                                //     :  InkWell(
                                                //       onTap: () {
                                                //         setState(() {
                                                //           timeIndex = index;
                                                //         });
                                                //       },
                                                //       child: Container(
                                                //         margin: EdgeInsets.only(right: getWidth(5)),
                                                //         height: getHeight(150),
                                                //         // width: getWidth(110),
                                                //         padding: EdgeInsets.all(getWidth(10)),
                                                //         decoration: boxDecoration(
                                                //             bgColor: timeIndex == index
                                                //                 ? MyColorName.primaryLite
                                                //                 .withOpacity(0.1)
                                                //                 : Colors.transparent,
                                                //             radius: 5,
                                                //             color: MyColorName.colorTextPrimary),
                                                //         child: Column(
                                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               rentList[1].carModel!=null?rentList[1].carModel.toString():"Auto",
                                                //               fontSize: 8.sp,
                                                //               fontFamily: fontMedium,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             boxHeight(10),
                                                //             Image.asset(
                                                //               rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                                                //               height: getHeight(50),
                                                //               width: getWidth(50),
                                                //               fit: BoxFit.fill,
                                                //             ),
                                                //             boxHeight(10),
                                                //             text(
                                                //               rentList[1].hoursData![index].hours.toString()+" Minutes",
                                                //               fontSize: 10.sp,
                                                //               fontFamily: fontMedium,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             // boxHeight(5),
                                                //             Row(
                                                //               mainAxisAlignment:
                                                //               MainAxisAlignment.spaceBetween,
                                                //               children: [
                                                //                 text(
                                                //                   "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
                                                //                   fontSize: 9.sp,
                                                //                   fontFamily: fontMedium,
                                                //                   textColor: MyColorName.appbarBg,
                                                //                 ),
                                                //                 boxWidth(5),
                                                //                 text(
                                                //                   "₹"+rentList[1].ratePerHour.toString() + "/mins",
                                                //                   fontSize: 7.sp,
                                                //                   fontFamily: fontRegular,
                                                //                   textColor: MyColorName.appbarBg,
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //             Row(
                                                //               mainAxisAlignment:
                                                //               MainAxisAlignment.spaceBetween,
                                                //               children: [
                                                //                 text(
                                                //                   "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
                                                //                   fontSize: 7.sp,
                                                //                   fontFamily: fontRegular,
                                                //                   textColor: MyColorName.appbarBg,
                                                //                 ),
                                                //                 // text(
                                                //                 //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                                                //                 //   + "kms",
                                                //                 //   fontSize: 7.sp,
                                                //                 //   fontFamily: fontRegular,
                                                //                 //   textColor: MyColorName.appbarBg,
                                                //                 // ),
                                                //               ],
                                                //             ),
                                                //           ],
                                                //         ),
                                                //       ),
                                                //     )
                                                // : SizedBox.shrink();
                                                // :  rentList[0].carCategories == "2" ?
                                                // InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       timeIndex = index;
                                                //     });
                                                //   },
                                                //   child: Container(
                                                //     margin: EdgeInsets.only(right: getWidth(5)),
                                                //     height: getHeight(150),
                                                //     // width: getWidth(110),
                                                //     padding: EdgeInsets.all(getWidth(10)),
                                                //     decoration: boxDecoration(
                                                //         bgColor: timeIndex == index
                                                //             ? MyColorName.primaryLite
                                                //             .withOpacity(0.1)
                                                //             : Colors.transparent,
                                                //         radius: 5,
                                                //         color: MyColorName.colorTextPrimary),
                                                //     child: Column(
                                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                                //       mainAxisAlignment:
                                                //       MainAxisAlignment.spaceBetween,
                                                //       children: [
                                                //         text(
                                                //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
                                                //           fontSize: 8.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         boxHeight(10),
                                                //         Image.asset(
                                                //           rentList[0].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                                                //           height: getHeight(50),
                                                //           width: getWidth(50),
                                                //           fit: BoxFit.fill,
                                                //         ),
                                                //         boxHeight(10),
                                                //         text(
                                                //           rentList[0].hoursData![index].hours.toString()+" Minutes",
                                                //           fontSize: 10.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         // boxHeight(5),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               "₹"+rentList[0].hoursData![index].fixedAmount.toString(),
                                                //               fontSize: 9.sp,
                                                //               fontFamily: fontMedium,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             boxWidth(5),
                                                //             text(
                                                //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //           ],
                                                //         ),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             // text(
                                                //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                                                //             //   + "kms",
                                                //             //   fontSize: 7.sp,
                                                //             //   fontFamily: fontRegular,
                                                //             //   textColor: MyColorName.appbarBg,
                                                //             // ),
                                                //           ],
                                                //         ),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // )
                                                //     :  InkWell(
                                                //   onTap: () {
                                                //     setState(() {
                                                //       timeIndex = index;
                                                //     });
                                                //   },
                                                //   child: Container(
                                                //     margin: EdgeInsets.only(right: getWidth(5)),
                                                //     height: getHeight(150),
                                                //     // width: getWidth(110),
                                                //     padding: EdgeInsets.all(getWidth(10)),
                                                //     decoration: boxDecoration(
                                                //         bgColor: timeIndex == index
                                                //             ? MyColorName.primaryLite
                                                //             .withOpacity(0.1)
                                                //             : Colors.transparent,
                                                //         radius: 5,
                                                //         color: MyColorName.colorTextPrimary),
                                                //     child: Column(
                                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                                //       mainAxisAlignment:
                                                //       MainAxisAlignment.spaceBetween,
                                                //       children: [
                                                //         text(
                                                //           rentList[1].carModel!=null?rentList[1].carModel.toString():"Auto",
                                                //           fontSize: 8.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         boxHeight(10),
                                                //         Image.asset(
                                                //           rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
                                                //           height: getHeight(50),
                                                //           width: getWidth(50),
                                                //           fit: BoxFit.fill,
                                                //         ),
                                                //         boxHeight(10),
                                                //         text(
                                                //           rentList[1].hoursData![index].hours.toString()+" Minutes",
                                                //           fontSize: 10.sp,
                                                //           fontFamily: fontMedium,
                                                //           textColor: MyColorName.appbarBg,
                                                //         ),
                                                //         // boxHeight(5),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
                                                //               fontSize: 9.sp,
                                                //               fontFamily: fontMedium,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             boxWidth(5),
                                                //             text(
                                                //               "₹"+rentList[1].ratePerHour.toString() + "/mins",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //           ],
                                                //         ),
                                                //         Row(
                                                //           mainAxisAlignment:
                                                //           MainAxisAlignment.spaceBetween,
                                                //           children: [
                                                //             text(
                                                //               "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
                                                //               fontSize: 7.sp,
                                                //               fontFamily: fontRegular,
                                                //               textColor: MyColorName.appbarBg,
                                                //             ),
                                                //             // text(
                                                //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
                                                //             //   + "kms",
                                                //             //   fontSize: 7.sp,
                                                //             //   fontFamily: fontRegular,
                                                //             //   textColor: MyColorName.appbarBg,
                                                //             // ),
                                                //           ],
                                                //         ),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // );
                                              })
                                      // :SizedBox(),
                                      )
                                  : SizedBox(),

                              // currentIndex == 2
                              //     ? DropdownButtonHideUnderline(
                              //         child: Container(
                              //           height: 56,
                              //           width: double.infinity,
                              //           padding:
                              //               const EdgeInsets.only(left: 12),
                              //           margin: EdgeInsets.symmetric(
                              //               horizontal: 16, vertical: 8),
                              //           decoration: BoxDecoration(
                              //             color: Color(0xffF5F5F5),
                              //             borderRadius:
                              //                 BorderRadius.circular(8),
                              //             border: Border.all(
                              //               color: Color(0xffE1E1E1),
                              //               width: 1,
                              //             ),
                              //           ),
                              //           child: DropdownButton<String>(
                              //             value: selectedAir,
                              //             isExpanded: true,
                              //             icon: Icon(Icons.arrow_drop_down,
                              //                 color: Colors.grey),
                              //             iconSize: 30,
                              //             style: TextStyle(
                              //                 color: Colors.black,
                              //                 fontSize: 16),
                              //             hint: Text('Airport Tranfer',
                              //                 style: TextStyle(
                              //                     color: Colors.grey)),
                              //             items: airportType.map((String item) {
                              //               return DropdownMenuItem<String>(
                              //                 value: item,
                              //                 child: Container(
                              //                   padding:
                              //                       const EdgeInsets.symmetric(
                              //                           vertical: 10),
                              //                   decoration: BoxDecoration(
                              //                     border: Border(
                              //                       bottom: BorderSide(
                              //                         color:
                              //                             Colors.grey.shade300,
                              //                         width: 0.5,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   child: Text(
                              //                     item,
                              //                     style:
                              //                         TextStyle(fontSize: 13),
                              //                   ),
                              //                 ),
                              //               );
                              //             }).toList(),
                              //             onChanged: (String? newValue) {
                              //               setState(() {
                              //                 selectedAir = newValue;
                              //               });
                              //             },
                              //           ),
                              //         ),
                              //       )
                              //     : SizedBox(),

                              TextFormField(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MapSearchScreen()),
                                  ).then((result) {
                                    if (result != null &&
                                        result is Map<String, dynamic>) {
                                      setState(() {
                                        pickupCon.text = result['address'];
                                        latitude = double.parse(
                                            result['lat'].toString());
                                        longitude = double.parse(
                                            result['lng'].toString());
                                      });
                                      getEstimated();
                                      getRides("3");
                                    }
                                  });
                                },
                                controller: pickupCon,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Pickup Location',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              TextFormField(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapSearchScreen(),
                                    ),
                                  ).then((result) {
                                    if (result != null &&
                                        result is Map<String, dynamic>) {
                                      setState(() {
                                        dropCon.text = result['address'];
                                        dropLatitude = double.parse(
                                            result['lat'].toString());
                                        dropLongitude = double.parse(
                                            result['lng'].toString());
                                      });
                                      getEstimated();
                                      getRides("3");
                                    }
                                  });
                                },
                                controller: dropCon,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Drop Location',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                ),
                              ),

                              // EntryField(
                              //   controller: pickupCon,
                              //   readOnly: true,
                              //   //   onTap: () {
                              //   //     Navigator.push(
                              //   //       context,
                              //   //       MaterialPageRoute(
                              //   //         builder: (context) =>
                              //   //             PlacePicker(
                              //   //           apiKey:
                              //   //               "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //   //           initialPosition: LatLng(
                              //   //               latitude, longitude),
                              //   //           useCurrentLocation: false,
                              //   //           autocompleteTypes: [
                              //   //             'airport'
                              //   //           ],
                              //   //           onPlacePicked: (result) {
                              //   //             if (currentIndex == 2) {
                              //   //               latitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lat;
                              //   //               longitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lng;
                              //   //               pickupCon.text = result
                              //   //                   .formattedAddress
                              //   //                   .toString();
                              //   //               print(
                              //   //                   "aaaaaaasssssssssssssss $latitude $longitude");
                              //   //               if (result
                              //   //                       .formattedAddress
                              //   //                       .toString()
                              //   //                       .split(",")
                              //   //                       .length >
                              //   //                   2) {
                              //   //                 List<String>
                              //   //                     cityList =
                              //   //                     result
                              //   //                         .formattedAddress
                              //   //                         .toString()
                              //   //                         .split(",");
                              //   //                 setState(() {
                              //   //                   pickupCityCon
                              //   //                           .text =
                              //   //                       cityList[cityList
                              //   //                               .length -
                              //   //                           3];
                              //   //                 });
                              //   //               }
                              //   //               /* getAddress(latitude, longitude)
                              //   //     .then((value) {
                              //   //   if (!value.first.city
                              //   //       .toString()
                              //   //       .contains("pricing"))
                              //   //     setState(() {
                              //   //       pickupCityCon.text =
                              //   //           value.first.city.toString();
                              //   //     });
                              //   // });*/
                              //   //             } else {
                              //   //               setState(() {
                              //   //                 pickupCon.text = result
                              //   //                     .formattedAddress
                              //   //                     .toString();
                              //   //                 latitude = result
                              //   //                     .geometry!
                              //   //                     .location
                              //   //                     .lat;
                              //   //                 longitude = result
                              //   //                     .geometry!
                              //   //                     .location
                              //   //                     .lng;
                              //   //               });
                              //   //             }
                              //   //             Navigator.of(context)
                              //   //                 .pop();
                              //   //           },
                              //   //         ),
                              //   //       ),
                              //   //     );
                              //   //   },
                              //   label:
                              //       getTranslated(context, "PICKUP_LOCATION"),
                              //   suffixIcon: currentIndex == 2
                              //       ? Text(pickupCityCon.text)
                              //       : null,
                              // ),
                              // : Container(
                              //     // height: 60,
                              //     // margin: EdgeInsets.all(10),
                              //     child: EntryField(
                              //         controller: pickupCon,
                              //         readOnly: true,
                              //         //     onTap: () {
                              //         //       Navigator.push(
                              //         //         context,
                              //         //         MaterialPageRoute(
                              //         //           builder: (context) =>
                              //         //               PlacePicker(
                              //         //             apiKey: Platform
                              //         //                     .isAndroid
                              //         //                 ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                              //         //                 : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //         //             onPlacePicked:
                              //         //                 (result) {
                              //         //               if (currentIndex ==
                              //         //                   2) {
                              //         //                 latitude = result
                              //         //                     .geometry!
                              //         //                     .location
                              //         //                     .lat;
                              //         //                 longitude = result
                              //         //                     .geometry!
                              //         //                     .location
                              //         //                     .lng;
                              //         //                 pickupCon.text = result
                              //         //                     .formattedAddress
                              //         //                     .toString();
                              //         //                 print(
                              //         //                     "asdadadsaddaasdasd $latitude $longitude");
                              //         //                 if (result
                              //         //                         .formattedAddress
                              //         //                         .toString()
                              //         //                         .split(",")
                              //         //                         .length >
                              //         //                     2) {
                              //         //                   List<String>
                              //         //                       cityList =
                              //         //                       result
                              //         //                           .formattedAddress
                              //         //                           .toString()
                              //         //                           .split(
                              //         //                               ",");
                              //         //                   setState(() {
                              //         //                     pickupCityCon
                              //         //                             .text =
                              //         //                         cityList[
                              //         //                             cityList.length -
                              //         //                                 3];
                              //         //                   });
                              //         //                 }
                              //         //                 /* getAddress(latitude, longitude)
                              //         //     .then((value) {
                              //         //   if (!value.first.city
                              //         //       .toString()
                              //         //       .contains("pricing"))
                              //         //     setState(() {
                              //         //       pickupCityCon.text =
                              //         //           value.first.city.toString();
                              //         //     });
                              //         // });*/
                              //         //               } else {
                              //         //                 setState(() {
                              //         //                   pickupCon.text = result
                              //         //                       .formattedAddress
                              //         //                       .toString();
                              //         //                   latitude = result
                              //         //                       .geometry!
                              //         //                       .location
                              //         //                       .lat;
                              //         //                   longitude = result
                              //         //                       .geometry!
                              //         //                       .location
                              //         //                       .lng;
                              //         //                 });
                              //         //               }
                              //         //               Navigator.of(context)
                              //         //                   .pop();
                              //         //             },
                              //         //             initialPosition: LatLng(
                              //         //                 latitude,
                              //         //                 longitude),
                              //         //             useCurrentLocation:
                              //         //                 true,
                              //         //           ),
                              //         //         ),
                              //         //       );
                              //         //     },
                              //         label: getTranslated(context,
                              //             "PICKUP_LOCATION"),
                              //         suffixIcon: currentIndex == 2
                              //             ? Text(pickupCityCon.text)
                              //             : null,
                              //         prefixIcon:
                              //             Icons.location_on),
                              //   ),

                              // currentIndex != 2 ?
                              // currentIndex == 2 &&
                              //         selectedAir == 'Airport Drop'
                              //     ?
                              // EntryField(
                              //   controller: dropCon,
                              //   readOnly: true,
                              //   //   onTap: () {
                              //   //     Navigator.push(
                              //   //       context,
                              //   //       MaterialPageRoute(
                              //   //         builder: (context) =>
                              //   //             PlacePicker(
                              //   //           apiKey:
                              //   //               "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //   //           initialPosition: LatLng(
                              //   //               latitude, longitude),
                              //   //           useCurrentLocation: false,
                              //   //           autocompleteTypes: [
                              //   //             'airport'
                              //   //           ],
                              //   //           onPlacePicked: (result) {
                              //   //             if (currentIndex == 2) {
                              //   //               latitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lat;
                              //   //               longitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lng;
                              //   //               dropLatitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lat;
                              //   //               dropLongitude = result
                              //   //                   .geometry!
                              //   //                   .location
                              //   //                   .lng;
                              //   //               dropCon.text = result
                              //   //                   .formattedAddress
                              //   //                   .toString();
                              //   //               print(
                              //   //                   "======drop=========$dropLatitude dropp $dropLongitude===========");
                              //   //               if (result
                              //   //                       .formattedAddress
                              //   //                       .toString()
                              //   //                       .split(",")
                              //   //                       .length >
                              //   //                   2) {
                              //   //                 List<String>
                              //   //                     cityList =
                              //   //                     result
                              //   //                         .formattedAddress
                              //   //                         .toString()
                              //   //                         .split(",");
                              //   //                 setState(() {
                              //   //                   dropCityCon.text =
                              //   //                       cityList[cityList
                              //   //                               .length -
                              //   //                           3];
                              //   //                 });
                              //   //               }
                              //   //               /* getAddress(latitude, longitude)
                              //   //     .then((value) {
                              //   //   if (!value.first.city
                              //   //       .toString()
                              //   //       .contains("pricing"))
                              //   //     setState(() {
                              //   //       pickupCityCon.text =
                              //   //           value.first.city.toString();
                              //   //     });
                              //   // });*/
                              //   //             } else {
                              //   //               setState(() {
                              //   //                 dropCon.text = result
                              //   //                     .formattedAddress
                              //   //                     .toString();
                              //   //                 latitude = result
                              //   //                     .geometry!
                              //   //                     .location
                              //   //                     .lat;
                              //   //                 longitude = result
                              //   //                     .geometry!
                              //   //                     .location
                              //   //                     .lng;
                              //   //               });
                              //   //             }
                              //   //             Navigator.of(context)
                              //   //                 .pop();
                              //   //           },
                              //   //         ),
                              //   //       ),
                              //   //     );
                              //   //   },
                              //   label: getTranslated(context, "DROP_LOCATION"),
                              //   suffixIcon: currentIndex == 2
                              //       ? Text(dropCityCon.text)
                              //       : null,
                              // ),
                              // Stack(
                              //   alignment: Alignment.centerRight,
                              //   children: [
                              //     Column(
                              //       children: [
                              //         // currentIndex == 2 &&
                              //         //         selectedAir == 'Airport Pick Up'
                              //         //     ?
                              //         Container(
                              //           // height: 60,
                              //           // margin: EdgeInsets.all(10),
                              //           child: EntryField(
                              //             controller: pickupCon,
                              //             readOnly: true,
                              //             //   onTap: () {
                              //             //     Navigator.push(
                              //             //       context,
                              //             //       MaterialPageRoute(
                              //             //         builder: (context) =>
                              //             //             PlacePicker(
                              //             //           apiKey:
                              //             //               "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //             //           initialPosition: LatLng(
                              //             //               latitude, longitude),
                              //             //           useCurrentLocation: false,
                              //             //           autocompleteTypes: [
                              //             //             'airport'
                              //             //           ],
                              //             //           onPlacePicked: (result) {
                              //             //             if (currentIndex == 2) {
                              //             //               latitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lat;
                              //             //               longitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lng;
                              //             //               pickupCon.text = result
                              //             //                   .formattedAddress
                              //             //                   .toString();
                              //             //               print(
                              //             //                   "aaaaaaasssssssssssssss $latitude $longitude");
                              //             //               if (result
                              //             //                       .formattedAddress
                              //             //                       .toString()
                              //             //                       .split(",")
                              //             //                       .length >
                              //             //                   2) {
                              //             //                 List<String>
                              //             //                     cityList =
                              //             //                     result
                              //             //                         .formattedAddress
                              //             //                         .toString()
                              //             //                         .split(",");
                              //             //                 setState(() {
                              //             //                   pickupCityCon
                              //             //                           .text =
                              //             //                       cityList[cityList
                              //             //                               .length -
                              //             //                           3];
                              //             //                 });
                              //             //               }
                              //             //               /* getAddress(latitude, longitude)
                              //             //     .then((value) {
                              //             //   if (!value.first.city
                              //             //       .toString()
                              //             //       .contains("pricing"))
                              //             //     setState(() {
                              //             //       pickupCityCon.text =
                              //             //           value.first.city.toString();
                              //             //     });
                              //             // });*/
                              //             //             } else {
                              //             //               setState(() {
                              //             //                 pickupCon.text = result
                              //             //                     .formattedAddress
                              //             //                     .toString();
                              //             //                 latitude = result
                              //             //                     .geometry!
                              //             //                     .location
                              //             //                     .lat;
                              //             //                 longitude = result
                              //             //                     .geometry!
                              //             //                     .location
                              //             //                     .lng;
                              //             //               });
                              //             //             }
                              //             //             Navigator.of(context)
                              //             //                 .pop();
                              //             //           },
                              //             //         ),
                              //             //       ),
                              //             //     );
                              //             //   },
                              //             label: getTranslated(
                              //                 context, "PICKUP_LOCATION"),
                              //             suffixIcon: currentIndex == 2
                              //                 ? Text(pickupCityCon.text)
                              //                 : null,
                              //           ),
                              //         ),
                              //         // : Container(
                              //         //     // height: 60,
                              //         //     // margin: EdgeInsets.all(10),
                              //         //     child: EntryField(
                              //         //         controller: pickupCon,
                              //         //         readOnly: true,
                              //         //         //     onTap: () {
                              //         //         //       Navigator.push(
                              //         //         //         context,
                              //         //         //         MaterialPageRoute(
                              //         //         //           builder: (context) =>
                              //         //         //               PlacePicker(
                              //         //         //             apiKey: Platform
                              //         //         //                     .isAndroid
                              //         //         //                 ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                              //         //         //                 : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //         //         //             onPlacePicked:
                              //         //         //                 (result) {
                              //         //         //               if (currentIndex ==
                              //         //         //                   2) {
                              //         //         //                 latitude = result
                              //         //         //                     .geometry!
                              //         //         //                     .location
                              //         //         //                     .lat;
                              //         //         //                 longitude = result
                              //         //         //                     .geometry!
                              //         //         //                     .location
                              //         //         //                     .lng;
                              //         //         //                 pickupCon.text = result
                              //         //         //                     .formattedAddress
                              //         //         //                     .toString();
                              //         //         //                 print(
                              //         //         //                     "asdadadsaddaasdasd $latitude $longitude");
                              //         //         //                 if (result
                              //         //         //                         .formattedAddress
                              //         //         //                         .toString()
                              //         //         //                         .split(",")
                              //         //         //                         .length >
                              //         //         //                     2) {
                              //         //         //                   List<String>
                              //         //         //                       cityList =
                              //         //         //                       result
                              //         //         //                           .formattedAddress
                              //         //         //                           .toString()
                              //         //         //                           .split(
                              //         //         //                               ",");
                              //         //         //                   setState(() {
                              //         //         //                     pickupCityCon
                              //         //         //                             .text =
                              //         //         //                         cityList[
                              //         //         //                             cityList.length -
                              //         //         //                                 3];
                              //         //         //                   });
                              //         //         //                 }
                              //         //         //                 /* getAddress(latitude, longitude)
                              //         //         //     .then((value) {
                              //         //         //   if (!value.first.city
                              //         //         //       .toString()
                              //         //         //       .contains("pricing"))
                              //         //         //     setState(() {
                              //         //         //       pickupCityCon.text =
                              //         //         //           value.first.city.toString();
                              //         //         //     });
                              //         //         // });*/
                              //         //         //               } else {
                              //         //         //                 setState(() {
                              //         //         //                   pickupCon.text = result
                              //         //         //                       .formattedAddress
                              //         //         //                       .toString();
                              //         //         //                   latitude = result
                              //         //         //                       .geometry!
                              //         //         //                       .location
                              //         //         //                       .lat;
                              //         //         //                   longitude = result
                              //         //         //                       .geometry!
                              //         //         //                       .location
                              //         //         //                       .lng;
                              //         //         //                 });
                              //         //         //               }
                              //         //         //               Navigator.of(context)
                              //         //         //                   .pop();
                              //         //         //             },
                              //         //         //             initialPosition: LatLng(
                              //         //         //                 latitude,
                              //         //         //                 longitude),
                              //         //         //             useCurrentLocation:
                              //         //         //                 true,
                              //         //         //           ),
                              //         //         //         ),
                              //         //         //       );
                              //         //         //     },
                              //         //         label: getTranslated(context,
                              //         //             "PICKUP_LOCATION"),
                              //         //         suffixIcon: currentIndex == 2
                              //         //             ? Text(pickupCityCon.text)
                              //         //             : null,
                              //         //         prefixIcon:
                              //         //             Icons.location_on),
                              //         //   ),
                              //
                              //         // currentIndex != 2 ?
                              //         // currentIndex == 2 &&
                              //         //         selectedAir == 'Airport Drop'
                              //         //     ?
                              //         Container(
                              //           // height: 60,
                              //           // margin: EdgeInsets.all(10),
                              //           child: EntryField(
                              //             controller: dropCon,
                              //             readOnly: true,
                              //             //   onTap: () {
                              //             //     Navigator.push(
                              //             //       context,
                              //             //       MaterialPageRoute(
                              //             //         builder: (context) =>
                              //             //             PlacePicker(
                              //             //           apiKey:
                              //             //               "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //             //           initialPosition: LatLng(
                              //             //               latitude, longitude),
                              //             //           useCurrentLocation: false,
                              //             //           autocompleteTypes: [
                              //             //             'airport'
                              //             //           ],
                              //             //           onPlacePicked: (result) {
                              //             //             if (currentIndex == 2) {
                              //             //               latitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lat;
                              //             //               longitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lng;
                              //             //               dropLatitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lat;
                              //             //               dropLongitude = result
                              //             //                   .geometry!
                              //             //                   .location
                              //             //                   .lng;
                              //             //               dropCon.text = result
                              //             //                   .formattedAddress
                              //             //                   .toString();
                              //             //               print(
                              //             //                   "======drop=========$dropLatitude dropp $dropLongitude===========");
                              //             //               if (result
                              //             //                       .formattedAddress
                              //             //                       .toString()
                              //             //                       .split(",")
                              //             //                       .length >
                              //             //                   2) {
                              //             //                 List<String>
                              //             //                     cityList =
                              //             //                     result
                              //             //                         .formattedAddress
                              //             //                         .toString()
                              //             //                         .split(",");
                              //             //                 setState(() {
                              //             //                   dropCityCon.text =
                              //             //                       cityList[cityList
                              //             //                               .length -
                              //             //                           3];
                              //             //                 });
                              //             //               }
                              //             //               /* getAddress(latitude, longitude)
                              //             //     .then((value) {
                              //             //   if (!value.first.city
                              //             //       .toString()
                              //             //       .contains("pricing"))
                              //             //     setState(() {
                              //             //       pickupCityCon.text =
                              //             //           value.first.city.toString();
                              //             //     });
                              //             // });*/
                              //             //             } else {
                              //             //               setState(() {
                              //             //                 dropCon.text = result
                              //             //                     .formattedAddress
                              //             //                     .toString();
                              //             //                 latitude = result
                              //             //                     .geometry!
                              //             //                     .location
                              //             //                     .lat;
                              //             //                 longitude = result
                              //             //                     .geometry!
                              //             //                     .location
                              //             //                     .lng;
                              //             //               });
                              //             //             }
                              //             //             Navigator.of(context)
                              //             //                 .pop();
                              //             //           },
                              //             //         ),
                              //             //       ),
                              //             //     );
                              //             //   },
                              //             label: getTranslated(
                              //                 context, "DROP_LOCATION"),
                              //             suffixIcon: currentIndex == 2
                              //                 ? Text(dropCityCon.text)
                              //                 : null,
                              //           ),
                              //         )
                              //         // : currentIndex == 3
                              //         //     ? SizedBox()
                              //         //     : Container(
                              //         //         // height: 60,
                              //         //         // margin: EdgeInsets.all(10),
                              //         //         child: EntryField(
                              //         //             controller: dropCon,
                              //         //             readOnly: true,
                              //         //             onTap: () {
                              //         //               //     Navigator.push(
                              //         //               //       context,
                              //         //               //       MaterialPageRoute(
                              //         //               //         builder: (context) =>
                              //         //               //             PlacePicker(
                              //         //               //           apiKey: Platform
                              //         //               //                   .isAndroid
                              //         //               //               ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                              //         //               //               : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                              //         //               //           onPlacePicked:
                              //         //               //               (result) {
                              //         //               //             print(result
                              //         //               //                 .formattedAddress);
                              //         //               //             if (currentIndex ==
                              //         //               //                 2) {
                              //         //               //               dropLatitude =
                              //         //               //                   result
                              //         //               //                       .geometry!
                              //         //               //                       .location
                              //         //               //                       .lat;
                              //         //               //               dropLongitude =
                              //         //               //                   result
                              //         //               //                       .geometry!
                              //         //               //                       .location
                              //         //               //                       .lng;
                              //         //               //               dropCon.text = result
                              //         //               //                   .formattedAddress
                              //         //               //                   .toString();
                              //         //               //               if (result
                              //         //               //                       .formattedAddress
                              //         //               //                       .toString()
                              //         //               //                       .split(
                              //         //               //                           ",")
                              //         //               //                       .length >
                              //         //               //                   2) {
                              //         //               //                 List<String>
                              //         //               //                     cityList =
                              //         //               //                     result
                              //         //               //                         .formattedAddress
                              //         //               //                         .toString()
                              //         //               //                         .split(
                              //         //               //                             ",");
                              //         //               //                 setState(() {
                              //         //               //                   dropCityCon
                              //         //               //                           .text =
                              //         //               //                       cityList[
                              //         //               //                           cityList.length -
                              //         //               //                               3];
                              //         //               //                 });
                              //         //               //               }
                              //         //               //               /*getAddress(
                              //         //               //         dropLatitude, dropLongitude)
                              //         //               //     .then((value) {
                              //         //               //   if (!value.first.city
                              //         //               //       .toString()
                              //         //               //       .contains("pricing"))
                              //         //               //     setState(() {
                              //         //               //       dropCityCon.text =
                              //         //               //           value.first.city.toString();
                              //         //               //     });
                              //         //               // });*/
                              //         //               //             } else {
                              //         //               //               setState(() {
                              //         //               //                 dropCon.text = result
                              //         //               //                     .formattedAddress
                              //         //               //                     .toString();
                              //         //               //                 dropLatitude = result
                              //         //               //                     .geometry!
                              //         //               //                     .location
                              //         //               //                     .lat;
                              //         //               //                 dropLongitude = result
                              //         //               //                     .geometry!
                              //         //               //                     .location
                              //         //               //                     .lng;
                              //         //               //               });
                              //         //               //             }
                              //         //               //             Navigator.of(
                              //         //               //                     context)
                              //         //               //                 .pop();
                              //         //               //             //  getBookInfo();
                              //         //               //             // getRides("3");
                              //         //               //           },
                              //         //               //           initialPosition: dropLatitude !=
                              //         //               //                   0
                              //         //               //               ? LatLng(
                              //         //               //                   dropLatitude,
                              //         //               //                   dropLongitude)
                              //         //               //               : LatLng(
                              //         //               //                   latitude,
                              //         //               //                   longitude),
                              //         //               //           useCurrentLocation:
                              //         //               //               true,
                              //         //               //         ),
                              //         //               //       ),
                              //         //               //     );
                              //         //             },
                              //         //             label: getTranslated(
                              //         //                 context,
                              //         //                 "DROP_LOCATION"),
                              //         //             suffixIcon:
                              //         //                 currentIndex == 2
                              //         //                     ? Text(dropCityCon
                              //         //                         .text)
                              //         //                     : null,
                              //         //             prefixIcon:
                              //         //                 Icons.location_on),
                              //         //       ),
                              //       ],
                              //     ),
                              //     // Row(
                              //     //   mainAxisAlignment: MainAxisAlignment.end,
                              //     //   children: [
                              //     //     GestureDetector(
                              //     //         onTap: () {
                              //     //           var pickLocation = pickupCon.text;
                              //     //           var dropLocation = dropCon.text;
                              //     //           pickupCon.text = dropLocation;
                              //     //           dropCon.text = pickLocation;
                              //     //           //
                              //     //           // //recie ->sender
                              //     //           // //sender - >receiver
                              //     //           //
                              //     //           var recieverLat2 = latitude;
                              //     //           var recieverLong2 = longitude;
                              //     //
                              //     //           latitude = dropLatitude;
                              //     //           longitude = dropLongitude;
                              //     //
                              //     //           dropLatitude = recieverLat2;
                              //     //           dropLongitude = recieverLong2;
                              //     //           //
                              //     //           // print(latSender.toString() +
                              //     //           //     "Sender Lat Sender 2");
                              //     //           // print(longSender.toString() +
                              //     //           //     "Sender Long Sender 2");
                              //     //           //
                              //     //           // print(latReceiver.toString() +
                              //     //           //     "Sender Lat 2 Receiver Lat 2");
                              //     //           // print(longReceiver.toString() +
                              //     //           //     "Sender Long 2 Receiver Lat 2");
                              //     //         },
                              //     //         child: Image.asset(
                              //     //           "assets/change.png",
                              //     //           height: 30,
                              //     //         )),
                              //     //     SizedBox(width: 24)
                              //     //   ],
                              //     // ),
                              //   ],
                              // ),

                              // : SizedBox(),
                              /*currentIndex != 2
                        ? Container(
                            color: theme.backgroundColor,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            height: 52,
                            child: Row(
                              children: [
                                Text(
                                  getTranslated(context, "PAYMENT_MODE")!,
                                  style:
                                      Theme.of(context).textTheme.bodyText1!.copyWith(
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
                          )
                        : SizedBox.shrink(),*/

                              ///personal/sharing
                              // currentIndex == 3
                              //     ? Padding(
                              //         padding: EdgeInsets.all(8.0),
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           children: [
                              //             InkWell(
                              //               onTap: () {
                              //                 setState(() {
                              //                   sharing = false;
                              //                 });
                              //               },
                              //               child: Row(
                              //                 children: [
                              //                   boxWidth(10),
                              //                   Icon(
                              //                       !sharing
                              //                           ? Icons
                              //                               .radio_button_checked_sharp
                              //                           : Icons
                              //                               .radio_button_unchecked_sharp,
                              //                       color: Theme.of(context)
                              //                           .colorScheme
                              //                           .primary),
                              //                   boxWidth(5),
                              //                   text("Personal",
                              //                       fontFamily: fontMedium,
                              //                       fontSize: 10.sp,
                              //                       textColor: Theme.of(context)
                              //                           .colorScheme
                              //                           .primary),
                              //                 ],
                              //               ),
                              //             ),
                              //             InkWell(
                              //               onTap: () {
                              //                 if (latitude != 0 &&
                              //                     dropLatitude != 0 &&
                              //                     dropCon.text != "") {
                              //                   setState(() {
                              //                     sharing = true;
                              //                     loadingButton = true;
                              //                   });
                              //                   getShareRide();
                              //                 } else {
                              //                   UI.setSnackBar(
                              //                       "Please Pick Both Location",
                              //                       context);
                              //                 }
                              //               },
                              //               child: Row(
                              //                 children: [
                              //                   Icon(
                              //                       sharing
                              //                           ? Icons
                              //                               .radio_button_checked_sharp
                              //                           : Icons
                              //                               .radio_button_unchecked_sharp,
                              //                       color: Theme.of(context)
                              //                           .colorScheme
                              //                           .primary),
                              //                   boxWidth(5),
                              //                   text("Sharing",
                              //                       fontFamily: fontMedium,
                              //                       fontSize: 10.sp,
                              //                       textColor: Theme.of(context)
                              //                           .colorScheme
                              //                           .primary),
                              //                   boxWidth(10),
                              //                 ],
                              //               ),
                              //             ),
                              //           ],
                              //         ))
                              //     : SizedBox(),
                              // currentIndex == 3 && sharing
                              //     ? Padding(
                              //         padding: EdgeInsets.all(8.0),
                              //         child: text(
                              //             shareRideList.length > 0
                              //                 ? "Similar Sharing Rides"
                              //                 : "No Similar Rides Available",
                              //             fontFamily: fontMedium,
                              //             fontSize: 10.sp,
                              //             isCentered: true,
                              //             textColor: shareRideList.length > 0
                              //                 ? Theme.of(context).primaryColor
                              //                 : Colors.redAccent))
                              //     : SizedBox(),
                              // currentIndex == 3 &&
                              //         sharing &&
                              //         shareRideList.length > 0
                              //     ? Padding(
                              //         padding: EdgeInsets.all(8.0),
                              //         child: ListView.builder(
                              //             shrinkWrap: true,
                              //             itemCount: shareRideList.length,
                              //             itemBuilder: (context, index) {
                              //               return shareRideList[index]
                              //                               .pickupDate !=
                              //                           null &&
                              //                       shareRideList[index]
                              //                               .pickupTime !=
                              //                           null
                              //                   ? ListTile(
                              //                       leading: Icon(
                              //                         Icons.location_on_rounded,
                              //                         color: Colors.green,
                              //                       ),
                              //                       shape: RoundedRectangleBorder(
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   8.0),
                              //                           side: BorderSide(
                              //                               color: Colors.grey)),
                              //                       title: Text(
                              //                         "${shareRideList[index].pickupCity}-${shareRideList[index].dropCity}",
                              //                         style: TextStyle(
                              //                             fontWeight:
                              //                                 FontWeight.w700),
                              //                       ),
                              //                       subtitle: Text(
                              //                         shareRideList[index]
                              //                                         .pickupDate !=
                              //                                     null &&
                              //                                 shareRideList[index]
                              //                                         .pickupTime !=
                              //                                     null
                              //                             ? "${shareRideList[index].pickupDate} ${shareRideList[index].pickupTime}"
                              //                             : "",
                              //                         style: TextStyle(
                              //                             fontWeight:
                              //                                 FontWeight.w400,
                              //                             fontSize: 10),
                              //                       ),
                              //                       trailing: InkWell(
                              //                         onTap: () {
                              //                           showRide(
                              //                               shareRideList[index]);
                              //                         },
                              //                         child: Container(
                              //                           width: 30.w,
                              //                           margin:
                              //                               EdgeInsets.symmetric(
                              //                                   vertical: 5,
                              //                                   horizontal: 16),
                              //                           height: 5.h,
                              //                           decoration: boxDecoration(
                              //                               radius: 5,
                              //                               bgColor: Theme.of(
                              //                                       context)
                              //                                   .primaryColor),
                              //                           child: Center(
                              //                             child: text(
                              //                                 "Join ₹${shareRideList[index].amount}",
                              //                                 fontFamily:
                              //                                     fontMedium,
                              //                                 fontSize: 10.sp,
                              //                                 isCentered: true,
                              //                                 textColor:
                              //                                     Colors.white),
                              //                           ),
                              //                         ),
                              //                       ),
                              //                     )
                              //                   : SizedBox();
                              //             }),
                              //       )
                              //     : SizedBox(),
                              // currentIndex == 3 && sharing
                              //     ? Padding(
                              //         padding: EdgeInsets.all(8.0),
                              //         child: text(getTranslated(context, "ONLY")!,
                              //             fontFamily: fontMedium,
                              //             fontSize: 10.sp,
                              //             isCentered: true,
                              //             textColor: Colors.redAccent),
                              //       )
                              //     : SizedBox(),
                              /*  currentIndex != 3 && isFirstUser == "0"
                              ? Center(
                                  child: Container(
                                    padding: EdgeInsets.all(getWidth(10)),
                                    color: Colors.white,
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        ColorizeAnimatedText(
                                          "Get special offer on your first ride",
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
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),*/
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 16, right: 16, top: 8, bottom: 8),
                              //   child: Column(
                              //     // mainAxisAlignment: currentIndex == 1 ||
                              //     //         currentIndex == 3 ||
                              //     //         currentIndex == 2
                              //     //     ? MainAxisAlignment.spaceEvenly
                              //     //     : MainAxisAlignment.center,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           currentIndex == 1
                              //               ? InkWell(
                              //                   onTap: () async {
                              //                     // DatePicker.showDateTimePicker(
                              //                     //   context,
                              //                     //   showTitleActions: true,
                              //                     //   onChanged: (date) {
                              //                     //     print('change $date in time zone ' +
                              //                     //         date.timeZoneOffset.inHours
                              //                     //             .toString());
                              //                     //   },
                              //                     //   onConfirm: (date) {
                              //                     //     setState(() {
                              //                     //       bookingDate = date;
                              //                     //       bookngDat = bookingDate.toString();
                              //                     //     });
                              //                     //     bookingTime = DateFormat('HH:mm:ss')
                              //                     //         .format(date);
                              //                     //     print(
                              //                     //         'confirm $date -----$bookingTime -----$bookngDat');
                              //                     //   },
                              //                     //   currentTime: DateTime.now(),
                              //                     //   minTime: DateTime.now().subtract(
                              //                     //     Duration(hours: 1),
                              //                     //   ),
                              //                     //   // maxTime: DateTime.now().add(
                              //                     //   //   Duration(days: 3),
                              //                     //   // ),
                              //                     // );
                              //                     DateTime today = DateTime.now();
                              //                     DateTime dayAfterTomorrow =
                              //                         today
                              //                             .add(Duration(days: 2));
                              //
                              //                     DateTime? selectedDate =
                              //                         await showDatePicker(
                              //                       context: context,
                              //                       initialDate: dayAfterTomorrow,
                              //                       firstDate: dayAfterTomorrow,
                              //                       lastDate: DateTime(2100),
                              //                       builder:
                              //                           (BuildContext context,
                              //                               Widget? child) {
                              //                         return Theme(
                              //                           data: Theme.of(context)
                              //                               .copyWith(
                              //                             dialogBackgroundColor:
                              //                                 Colors
                              //                                     .white, // Optional: Change dialog background
                              //                             colorScheme:
                              //                                 ColorScheme.light(
                              //                               primary: MyColorName
                              //                                   .primaryLite, // Primary color for header and buttons
                              //                             ),
                              //                             dialogTheme:
                              //                                 DialogTheme(
                              //                               shape:
                              //                                   RoundedRectangleBorder(
                              //                                 borderRadius:
                              //                                     BorderRadius
                              //                                         .circular(
                              //                                             12.0), // Dialog shape
                              //                               ),
                              //                             ),
                              //                           ),
                              //                           child: child!,
                              //                         );
                              //                       },
                              //                     );
                              //
                              //                     if (selectedDate != null) {
                              //                       bookingDate = selectedDate;
                              //                       bookngDat =
                              //                           bookingDate.toString();
                              //                       String formattedDate =
                              //                           DateFormat('yyyy-MM-dd')
                              //                               .format(selectedDate);
                              //                       print(
                              //                           'Selected Date: $formattedDate');
                              //                       setState(() {});
                              //                     }
                              //                   },
                              //                   child: Container(
                              //                     padding: EdgeInsets.all(12),
                              //                     decoration: boxDecoration(
                              //                       bgColor: Color(0xffF5F5F5),
                              //                       radius: 8,
                              //                       color: Color(0xffE1E1E1),
                              //                     ),
                              //                     height: 56,
                              //                     width: 140,
                              //                     child: Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment
                              //                               .spaceBetween,
                              //                       children: [
                              //                         bookingDate == null
                              //                             ? Text(
                              //                                 "Pickup Date",
                              //                                 style: TextStyle(
                              //                                   color: Color(
                              //                                       0xff666666),
                              //                                 ),
                              //                               )
                              //                             : Text(
                              //                                 "${DateFormat('yyyy-MM-dd').format(bookingDate!)}",
                              //                                 // "${getDate(bookingDate.toString())}",
                              //                                 style: TextStyle(
                              //                                     color: Color(
                              //                                         0xff666666)),
                              //                               ),
                              //                         SvgPicture.asset(
                              //                             "assets/svg/Calendar.svg"),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 )
                              //               : SizedBox(),
                              //           Spacer(),
                              //           currentIndex == 1
                              //               ? InkWell(
                              //                   onTap: () async {
                              //                     // DatePicker.showDateTimePicker(
                              //                     //   context,
                              //                     //   showTitleActions: true,
                              //                     //   onChanged: (date) {
                              //                     //     print('change $date in time zone ' +
                              //                     //         date.timeZoneOffset.inHours
                              //                     //             .toString());
                              //                     //   },
                              //                     //   onConfirm: (date) {
                              //                     //     setState(() {
                              //                     //       bookingDate = date;
                              //                     //       bookngDat = bookingDate.toString();
                              //                     //     });
                              //                     //     bookingTime = DateFormat('HH:mm:ss')
                              //                     //         .format(date);
                              //                     //     print(
                              //                     //         'confirm $date -----$bookingTime -----$bookngDat');
                              //                     //   },
                              //                     //   currentTime: DateTime.now(),
                              //                     //   minTime: DateTime.now().subtract(
                              //                     //     Duration(hours: 1),
                              //                     //   ),
                              //                     //   // maxTime: DateTime.now().add(
                              //                     //   //   Duration(days: 3),
                              //                     //   // ),
                              //                     // );
                              //                     TimeOfDay? selectedTime =
                              //                         await showTimePicker(
                              //                       context: context,
                              //                       initialTime: TimeOfDay.now(),
                              //                       builder:
                              //                           (BuildContext context,
                              //                               Widget? child) {
                              //                         return Theme(
                              //                           data: Theme.of(context)
                              //                               .copyWith(
                              //                             dialogBackgroundColor:
                              //                                 Colors
                              //                                     .white, // Optional: Change the dialog background color
                              //                             colorScheme:
                              //                                 ColorScheme.light(
                              //                               primary: MyColorName
                              //                                   .primaryLite, // Set header and button colors
                              //                             ),
                              //                             timePickerTheme:
                              //                                 TimePickerThemeData(
                              //                               dialBackgroundColor:
                              //                                   Colors
                              //                                       .white, // Optional: Dial background color
                              //                               hourMinuteTextColor:
                              //                                   MyColorName
                              //                                       .primaryLite, // Hour and minute text color
                              //                               dialHandColor: MyColorName
                              //                                   .primaryLite, // Dial hand color
                              //                             ),
                              //                           ),
                              //                           child: child!,
                              //                         );
                              //                       },
                              //                     );
                              //
                              //                     if (selectedTime != null) {
                              //                       // Convert TimeOfDay to DateTime for formatting
                              //                       final now = DateTime.now();
                              //                       final DateTime
                              //                           formattedDateTime =
                              //                           DateTime(
                              //                         now.year,
                              //                         now.month,
                              //                         now.day,
                              //                         selectedTime.hour,
                              //                         selectedTime.minute,
                              //                       );
                              //                       // Format the time as HH:mm:ss
                              //                       bookingTime = DateFormat(
                              //                               'HH:mm:ss')
                              //                           .format(
                              //                               formattedDateTime);
                              //                       print(
                              //                           'Selected Time: $bookingTime');
                              //                       setState(() {});
                              //                     }
                              //                   },
                              //                   child: Container(
                              //                     padding: EdgeInsets.all(12),
                              //                     decoration: boxDecoration(
                              //                       bgColor: Color(0xffF5F5F5),
                              //                       radius: 8,
                              //                       color: Color(0xffE1E1E1),
                              //                     ),
                              //                     height: 56,
                              //                     width: 140,
                              //                     child: Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment
                              //                               .spaceBetween,
                              //                       children: [
                              //                         bookingTime == null
                              //                             ? Text(
                              //                                 "Pickup Time",
                              //                                 style: TextStyle(
                              //                                   color: Color(
                              //                                       0xff666666),
                              //                                 ),
                              //                               )
                              //                             : Text(
                              //                                 "${bookingTime}",
                              //                                 style: TextStyle(
                              //                                     color: Color(
                              //                                         0xff666666)),
                              //                               ),
                              //                         Icon(
                              //                           Icons.access_time_sharp,
                              //                           color: Colors.black,
                              //                         )
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 )
                              //               : SizedBox(),
                              //         ],
                              //       ),
                              //       SizedBox(
                              //         height: 10,
                              //       )
                              //
                              //       // currentIndex == 1
                              //       //     ? InkWell(
                              //       //         onTap: () {
                              //       //           DatePicker.showDateTimePicker(
                              //       //             context,
                              //       //             showTitleActions: true,
                              //       //             onChanged: (date) {
                              //       //               print(
                              //       //                   'change $date in time zone ' +
                              //       //                       date.timeZoneOffset
                              //       //                           .inHours
                              //       //                           .toString());
                              //       //             },
                              //       //             onConfirm: (date) {
                              //       //               setState(() {
                              //       //                 returnDate = date;
                              //       //                 retrnDat =
                              //       //                     returnDate.toString();
                              //       //               });
                              //       //               returnTime =
                              //       //                   DateFormat('HH:mm:ss')
                              //       //                       .format(date);
                              //       //               print(
                              //       //                   'confirm $date -----$returnTime -----$retrnDat');
                              //       //             },
                              //       //             currentTime: DateTime.now(),
                              //       //             minTime: DateTime.now().subtract(
                              //       //               Duration(hours: 1),
                              //       //             ),
                              //       //             // maxTime: DateTime.now().add(
                              //       //             //   Duration(days: 3),
                              //       //             // ),
                              //       //           );
                              //       //         },
                              //       //         child: Container(
                              //       //           padding: EdgeInsets.all(12),
                              //       //           margin: EdgeInsets.only(top: 8),
                              //       //           decoration: boxDecoration(
                              //       //             bgColor: Color(0xffF5F5F5),
                              //       //             radius: 8,
                              //       //             color: Color(0xffE1E1E1),
                              //       //           ),
                              //       //           height: 56, //7.h,
                              //       //           // width: 10.h,
                              //       //           child: Row(
                              //       //             mainAxisAlignment:
                              //       //                 MainAxisAlignment
                              //       //                     .spaceBetween,
                              //       //             children: [
                              //       //               returnDate == null
                              //       //                   ? Text(
                              //       //                       "Return Date/Time",
                              //       //                       style: TextStyle(
                              //       //                         color:
                              //       //                             Color(0xff666666),
                              //       //                       ),
                              //       //                     )
                              //       //                   : Text(
                              //       //                       "${getDate(returnDate.toString())}",
                              //       //                       style: TextStyle(
                              //       //                           color: Color(
                              //       //                               0xff666666)),
                              //       //                     ),
                              //       //               SvgPicture.asset(
                              //       //                   "assets/svg/Calendar.svg"),
                              //       //
                              //       //               // returnDate == null ||
                              //       //               //         returnDate == "" ||
                              //       //               //         returnTime == "" ||
                              //       //               //         returnTime == null
                              //       //               //     ? Row(
                              //       //               //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       //               //         children: [
                              //       //               //           Text(
                              //       //               //             "Return Date/Time",
                              //       //               //             style: TextStyle(
                              //       //               //               color: Color(
                              //       //               //                   0xff666666),
                              //       //               //             ),
                              //       //               //           ),
                              //       //               //           SvgPicture.asset(
                              //       //               //               "assets/svg/Calendar.svg")
                              //       //               //         ],
                              //       //               //       )
                              //       //               //     : Text(
                              //       //               //         "$returnDate : $returnTime",
                              //       //               //         style: TextStyle(
                              //       //               //           color:
                              //       //               //               Color(0xff666666),
                              //       //               //         ),
                              //       //               //       )
                              //       //             ],
                              //       //           ),
                              //       //         ),
                              //       //       )
                              //       //     : currentIndex == 3
                              //       //         ? DropdownButtonHideUnderline(
                              //       //             child: Container(
                              //       //               height: 56,
                              //       //               width: double.infinity,
                              //       //               padding:
                              //       //                   const EdgeInsets.symmetric(
                              //       //                       horizontal: 16,
                              //       //                       vertical: 0),
                              //       //               margin: EdgeInsets.only(top: 8),
                              //       //               decoration: BoxDecoration(
                              //       //                 color: Color(0xffF5F5F5),
                              //       //                 borderRadius:
                              //       //                     BorderRadius.circular(8),
                              //       //                 border: Border.all(
                              //       //                   color: Color(0xffE1E1E1),
                              //       //                   width: 1,
                              //       //                 ),
                              //       //               ),
                              //       //               child: DropdownButton<String>(
                              //       //                 value: selectedHour,
                              //       //                 isExpanded: true,
                              //       //                 icon: Icon(
                              //       //                     Icons.arrow_drop_down,
                              //       //                     color: Colors.grey),
                              //       //                 iconSize: 30,
                              //       //                 style: TextStyle(
                              //       //                     color: Colors.black,
                              //       //                     fontSize: 16),
                              //       //                 hint: Text(
                              //       //                   'Rent For',
                              //       //                   style: TextStyle(
                              //       //                       color: Colors.grey),
                              //       //                 ),
                              //       //                 items: hourList
                              //       //                     .map((String item) {
                              //       //                   return DropdownMenuItem<
                              //       //                       String>(
                              //       //                     value: item,
                              //       //                     child: Container(
                              //       //                       padding:
                              //       //                           const EdgeInsets
                              //       //                               .symmetric(
                              //       //                               vertical: 10),
                              //       //                       decoration:
                              //       //                           BoxDecoration(
                              //       //                         border: Border(
                              //       //                           bottom: BorderSide(
                              //       //                             color: Colors.grey
                              //       //                                 .shade300,
                              //       //                             width: 0.5,
                              //       //                           ),
                              //       //                         ),
                              //       //                       ),
                              //       //                       child: Text(item),
                              //       //                     ),
                              //       //                   );
                              //       //                 }).toList(),
                              //       //                 onChanged:
                              //       //                     (String? newValue) {
                              //       //                   setState(() {
                              //       //                     selectedHour = newValue;
                              //       //                   });
                              //       //                   print(
                              //       //                       "asdadadsaasdsad $selectedHour");
                              //       //                 },
                              //       //               ),
                              //       //             ),
                              //       //           )
                              //       //         : SizedBox(),
                              //     ],
                              //   ),
                              // ),

                              // bookingDate != null
                              //     ? Padding(
                              //         padding: EdgeInsets.all(8.0),
                              //         child: text(
                              //             "${getTranslated(context, "BOOKING_DATE")} : " +
                              //                 getDate(bookingDate.toString()),
                              //             fontFamily: fontMedium,
                              //             fontSize: 10.sp,
                              //             textColor: Theme.of(context)
                              //                 .colorScheme
                              //                 .primary),
                              //       )
                              //     : SizedBox(),

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 16, right: 16, top: 4, bottom: 20),
                              //   child: Row(
                              //     mainAxisAlignment: currentIndex == 1 ||
                              //             currentIndex == 3 ||
                              //             currentIndex == 2
                              //         ? MainAxisAlignment.spaceEvenly
                              //         : MainAxisAlignment.center,
                              //     children: [
                              //       Expanded(
                              //         child: InkWell(
                              //           onTap: () async {
                              //             bool status = await getBookInfo();
                              //             if (status) {}
                              //             // if (bookModel != null &&
                              //             //     (getDifference() ||
                              //             //         getDayDifference())) {
                              //             //   UI.setSnackBar(
                              //             //       "you have a booking in an hour or same day",
                              //             //       context);
                              //             //   return;
                              //             // }
                              //             if (rideList.isNotEmpty) {
                              //               return;
                              //             }
                              //             if (currentIndex == 2) {
                              //               if (bookingDate == null) {
                              //                 UI.setSnackBar(
                              //                     "Please Select Date and Time",
                              //                     context);
                              //               } else {
                              //                 // showRental();
                              //                 await Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         ChooseCabPage(
                              //                       LatLng(latitude, longitude),
                              //                       LatLng(dropLatitude,
                              //                           dropLongitude),
                              //                       pickupCon.text,
                              //                       pickupCityCon.text,
                              //                       dropCityCon.text,
                              //                       dropCon.text,
                              //                       paymentType,
                              //                       bookingDate != null
                              //                           ? bookingDate
                              //                           : null,
                              //                       currentIndex == 3
                              //                           ? sharing
                              //                               ? "Share"
                              //                               : "Personal"
                              //                           : "",
                              //                       selectCabType.toString(),
                              //                       selectedHour.toString(),
                              //                       returnDate.toString(),
                              //                       returnTime.toString(),
                              //                     ),
                              //                   ),
                              //                 );
                              //               }
                              //             } else if (currentIndex == 1 &&
                              //                     bookingDate == null ||
                              //                 currentIndex == 3 &&
                              //                     bookingDate == null) {
                              //               UI.setSnackBar(
                              //                   "Please Select Date and Time",
                              //                   context);
                              //               return;
                              //             } else if (latitude != 0) {
                              //               print("choose cab ");
                              //               var result = await Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       ChooseCabPage(
                              //                     LatLng(latitude, longitude),
                              //                     LatLng(dropLatitude,
                              //                         dropLongitude),
                              //                     pickupCon.text,
                              //                     pickupCityCon.text,
                              //                     dropCityCon.text,
                              //                     dropCon.text,
                              //                     paymentType,
                              //                     bookingDate != null
                              //                         ? bookingDate
                              //                         : null,
                              //                     currentIndex == 3
                              //                         ? sharing
                              //                             ? "Share"
                              //                             : "Personal"
                              //                         : "",
                              //                     selectCabType.toString(),
                              //                     selectedHour.toString(),
                              //                     returnDate.toString(),
                              //                     returnTime.toString(),
                              //                   ),
                              //                 ),
                              //               );
                              //               print(result);
                              //               if (result == "yes") {
                              //                 setState(() {
                              //                   bookingDate = null;
                              //                   dropCon.text = "";
                              //                 });
                              //                 getLocation();
                              //                 getBookInfo();
                              //                 var result1 = await Navigator.push(
                              //                     context,
                              //                     MaterialPageRoute(
                              //                         builder: (context) =>
                              //                             MyRidesPage("1")));
                              //                 if (result1 != null) {
                              //                   getBookInfo();
                              //                 }
                              //               } else if (result == "yes1") {
                              //                 setState(() {
                              //                   bookingDate = null;
                              //                   dropCon.text = "";
                              //                 });
                              //                 getLocation();
                              //                 getBookInfo();
                              //                 var result2 = await Navigator.push(
                              //                   context,
                              //                   MaterialPageRoute(
                              //                     builder: (context) =>
                              //                         InterCityRidePage("1"),
                              //                   ),
                              //                 );
                              //                 if (result2 != null) {
                              //                   getBookInfo();
                              //                 }
                              //               } else if (result == "yes2") {
                              //                 getCurrentInfo(first: true);
                              //                 getRides("3");
                              //                 getBookInfo();
                              //               }
                              //             } else {
                              //               UI.setSnackBar(
                              //                   "Please Pick Location", context);
                              //             }
                              //           },
                              //           child: Container(
                              //             width: double.infinity,
                              //             height: 7.h,
                              //             decoration: boxDecoration(
                              //                 radius: 10,
                              //                 bgColor: AppTheme.secondaryColor),
                              //             child: Center(
                              //               child: currentIndex == 2 ||
                              //                       currentIndex == 3
                              //                   ? loadingRental || loadingButton
                              //                       ? CircularProgressIndicator(
                              //                           color: Colors.white,
                              //                         )
                              //                       : text(
                              //                           // getTranslated(context, "CONTINUE")!,
                              //                           "SEARCH RIDE",
                              //                           fontFamily: fontMedium,
                              //                           fontSize: 12.sp,
                              //                           textColor: Colors.white)
                              //                   : text(
                              //                       // getTranslated(context, "CONTINUE")!,
                              //                       "SEARCH RIDE",
                              //                       fontFamily: fontMedium,
                              //                       fontSize: 12.sp,
                              //                       textColor: Colors.white),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //
                              //       // currentIndex == 0 ||
                              //       //     currentIndex == 1 ||
                              //       //     currentIndex == 3 ||
                              //       //     currentIndex == 2
                              //       //     ? InkWell(
                              //       //   onTap: () {
                              //       //     DatePicker.showDateTimePicker(
                              //       //       context,
                              //       //       showTitleActions: true,
                              //       //       onChanged: (date) {
                              //       //         print(
                              //       //             'change $date in time zone ' +
                              //       //                 date.timeZoneOffset
                              //       //                     .inHours
                              //       //                     .toString());
                              //       //       },
                              //       //       onConfirm: (date) {
                              //       //         setState(() {
                              //       //           bookingDate = date;
                              //       //           bookngDat =
                              //       //               bookingDate.toString();
                              //       //         });
                              //       //         bookingTime =
                              //       //             DateFormat('HH:mm:ss')
                              //       //                 .format(date);
                              //       //         print(
                              //       //             'confirm $date -----$bookingTime -----$bookngDat');
                              //       //       },
                              //       //       currentTime: DateTime.now(),
                              //       //       minTime: DateTime.now().subtract(
                              //       //         Duration(hours: 1),
                              //       //       ),
                              //       //       maxTime: DateTime.now().add(
                              //       //         Duration(days: 3),
                              //       //       ),
                              //       //     );
                              //       //   },
                              //       //   child: Container(
                              //       //     margin: EdgeInsets.only(left: 8),
                              //       //     decoration: boxDecoration(
                              //       //       bgColor: Color(0xffF5F5F5),
                              //       //       radius: 10,
                              //       //       color: Color(0xffE1E1E1),
                              //       //     ),
                              //       //     height: 7.h,
                              //       //     width: 7.h,
                              //       //     child: Icon(
                              //       //       Icons.calendar_month_outlined,
                              //       //       color: Color(0xff383838),
                              //       //       size: 24.sp,
                              //       //     ),
                              //       //   ),
                              //       // )
                              //       //     : SizedBox(),
                              //     ],
                              //   ),
                              // ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectLocationScreen(currentIndex: currentIndex,selectCabType: selectCabType,)));
                              //   },
                              //   child: Container(
                              //     width: double.infinity,
                              //     height: 7.h,
                              //     decoration: boxDecoration(
                              //         radius: 10,
                              //         bgColor: AppTheme.secondaryColor),
                              //     child: Center(
                              //         child:text(
                              //           // getTranslated(context, "CONTINUE")!,
                              //             "SEARCH RIDE",
                              //             fontFamily: fontMedium,
                              //             fontSize: 12.sp,
                              //             textColor: Colors.white)
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  currentIndex == 1
                                      ? InkWell(
                                          onTap: () async {
                                            DateTime today = DateTime.now();
                                            DateTime dayAfterTomorrow =
                                                today.add(Duration(days: 1));

                                            DateTime? selectedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: dayAfterTomorrow,
                                              firstDate: dayAfterTomorrow,
                                              lastDate:
                                                  today.add(Duration(days: 14)),
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    dialogBackgroundColor:
                                                        Colors.white,
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary: MyColorName
                                                          .primaryLite,
                                                    ),
                                                    dialogTheme: DialogTheme(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            if (selectedDate != null) {
                                              bookingDate = selectedDate;
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(selectedDate);
                                              print(
                                                  'Selected Date: $formattedDate');
                                              TimeOfDay? selectedTime =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      dialogBackgroundColor:
                                                          Colors.white,
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: MyColorName
                                                            .primaryLite,
                                                      ),
                                                      timePickerTheme:
                                                          TimePickerThemeData(
                                                        dialBackgroundColor:
                                                            Colors.white,
                                                        hourMinuteTextColor:
                                                            MyColorName
                                                                .primaryLite,
                                                        dialHandColor:
                                                            MyColorName
                                                                .primaryLite,
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (selectedTime != null) {
                                                final now = DateTime.now();
                                                final selectedDateTime =
                                                    DateTime(
                                                  bookingDate!.year,
                                                  bookingDate!.month,
                                                  bookingDate!.day,
                                                  selectedTime.hour,
                                                  selectedTime.minute,
                                                );

                                                final minAllowedBookingTime =
                                                    now.add(
                                                        Duration(hours: 24));

                                                if (selectedDateTime.isBefore(
                                                    minAllowedBookingTime)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "You can only book for 24 hours or more in advance."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                bookingTime = DateFormat(
                                                        'HH:mm:ss')
                                                    .format(selectedDateTime);
                                                print(
                                                    'Selected Time: $bookingTime');

                                                setState(() {});
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: boxDecoration(
                                              bgColor: MyColorName.colorBg1,
                                              radius: 6,
                                              color: Color(0xffE1E1E1),
                                            ),
                                            height: 42,
                                            width: 140,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                bookingDate == null
                                                    ? Text(
                                                        "Pickup Date",
                                                        style: TextStyle(
                                                            color: MyColorName
                                                                .secondary,
                                                            fontSize: 16,
                                                            fontFamily: AppTheme
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    : Text(
                                                        "${DateFormat('yyyy-MM-dd').format(bookingDate!)}",
                                                        // "${getDate(bookingDate.toString())}",
                                                        style: TextStyle(
                                                            color: MyColorName
                                                                .secondary,
                                                            fontSize: 16,
                                                            fontFamily: AppTheme
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                Image.asset(
                                                    "assets/calendar.png"),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  Spacer(),
                                  currentIndex == 1
                                      ? InkWell(
                                          onTap: () async {
                                            if (bookingDate == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Please select a booking date first."),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            TimeOfDay? selectedTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    dialogBackgroundColor:
                                                        Colors.white,
                                                    colorScheme:
                                                        ColorScheme.light(
                                                      primary: MyColorName
                                                          .primaryLite,
                                                    ),
                                                    timePickerTheme:
                                                        TimePickerThemeData(
                                                      dialBackgroundColor:
                                                          Colors.white,
                                                      hourMinuteTextColor:
                                                          MyColorName
                                                              .primaryLite,
                                                      dialHandColor: MyColorName
                                                          .primaryLite,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (selectedTime != null) {
                                              final now = DateTime.now();
                                              final bookingDateTime = DateTime(
                                                bookingDate!.year,
                                                bookingDate!.month,
                                                bookingDate!.day,
                                                selectedTime.hour,
                                                selectedTime.minute,
                                              );
                                              final minAllowedBookingTime =
                                                  now.add(Duration(hours: 24));
                                              if (bookingDateTime.isBefore(
                                                  minAllowedBookingTime)) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "You can only book for 24 hours or more in advance."),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                              bookingTime =
                                                  DateFormat('HH:mm:ss')
                                                      .format(bookingDateTime);
                                              print(
                                                  'Selected Time: $bookingTime');
                                              setState(() {});
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: boxDecoration(
                                              bgColor: MyColorName.colorBg1,
                                              radius: 6,
                                              color: Color(0xffE1E1E1),
                                            ),
                                            height: 42,
                                            width: 140,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                bookingTime == null
                                                    ? Text(
                                                        "Pickup Time",
                                                        style: TextStyle(
                                                            color: MyColorName
                                                                .secondary,
                                                            fontSize: 16,
                                                            fontFamily: AppTheme
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    : Text(
                                                        "${bookingTime}",
                                                        style: TextStyle(
                                                            color: MyColorName
                                                                .secondary,
                                                            fontSize: 16,
                                                            fontFamily: AppTheme
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                Image.asset(
                                                    "assets/back-in-time.png")
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),

                              // SizedBox(height: 10,),
                              // SingleChildScrollView(
                              //   scrollDirection: Axis.horizontal,
                              //   physics: AlwaysScrollableScrollPhysics(),
                              //   child: Row(
                              //     children: List.generate(sliderImages.length,
                              //         (index) {
                              //       return InkWell(
                              //         onTap: () async {
                              //           if (sliderImages[index].url == null ||
                              //               sliderImages[index].url == '') {
                              //             print('Could not launch');
                              //           } else {
                              //             await launchUrl(
                              //                 Uri.parse(
                              //                     sliderImages[index].url ??
                              //                         ''),
                              //                 mode: LaunchMode
                              //                     .externalApplication);
                              //           }
                              //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>PremiumSliderDetails(sliderData: premiumSliderImages[index],availableLocationList: availableLocationList,)));
                              //         },
                              //         child: Padding(
                              //           padding: const EdgeInsets.all(8.0),
                              //           child: Card(
                              //             child: Container(
                              //               decoration: BoxDecoration(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10),
                              //               ),
                              //               width: 340,
                              //               height: 180,
                              //               child: ClipRRect(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10),
                              //                 child: FadeInImage.assetNetwork(
                              //                   placeholder:
                              //                       'assets/slider_image.png',
                              //                   fit: BoxFit.fill,
                              //                   image:
                              //                       sliderImages[index].image ??
                              //                           '',
                              //                   imageErrorBuilder: (c, o, s) =>
                              //                       Image.asset(
                              //                           'assets/slider_image.png',
                              //                           fit: BoxFit.fill),
                              //                 ),
                              //               ),
                              //               // child: Image.asset(
                              //               //   slider1Images[index],
                              //               //   scale: 4,
                              //               //   fit: BoxFit.cover,
                              //               // ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     }).toList(),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 5),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (pickupCon.text == '') {
                                UI.setSnackBar(
                                    "Please Select Pickup Location", context);
                              } else if (dropCon.text == '') {
                                UI.setSnackBar(
                                    "Please Select Drop Location", context);
                              } else if (currentIndex == 1 &&
                                  bookingDate == null) {
                                UI.setSnackBar(
                                    "Please Select Pickup Date", context);
                              } else if (currentIndex == 1 &&
                                  bookingTime == null) {
                                UI.setSnackBar(
                                    "Please Select Pickup Time", context);
                              } else {
                                // showRental();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChooseCabPage(
                                      LatLng(latitude, longitude),
                                      LatLng(dropLatitude, dropLongitude),
                                      pickupCon.text,
                                      pickupCityCon.text,
                                      dropCityCon.text,
                                      dropCon.text,
                                      paymentType,
                                      bookingDate != null ? bookingDate : null,
                                      currentIndex == 3
                                          ? sharing
                                              ? "Share"
                                              : "Personal"
                                          : "",
                                      selectCabType.toString(),
                                      selectedHour.toString(),
                                      returnDate.toString(),
                                      returnTime.toString(),
                                    ),
                                  ),
                                );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ConfirmRiderRequest(
                                //       bookingId: 1,
                                //       bookingDate: bookingDate,
                                //       currentCar: _currentCar,
                                //       destination: LatLng(latitude, longitude),
                                //       driverList: driverList,
                                //       dropAddress: dropCon.text,
                                //       gst: gst,
                                //       nightCharge: nightCharge,
                                //       parking: parking,
                                //       paymentType: paymentType,
                                //       pickAddress: pickupCon.text,
                                //       promoDiscount: promoDiscount,
                                //       promoList: promoList,
                                //       returnDate: bookingTime.toString(),
                                //       rideList: rideList,
                                //       shareType: '',
                                //       source:
                                //           LatLng(dropLatitude, dropLongitude),
                                //       stateCharge: stateCharge,
                                //       surge: surge,
                                //       surgePer: '',
                                //       time: '',
                                //       tollTax: tollTax,
                                //       type: currentIndex == 1
                                //           ? 'current'
                                //           : 'schedule',
                                //       unitPrice: unitPrice,
                                //       vehicleId: vehicleId,
                                //       vendorId: vendorId,
                                //       partPayment: 0.0,
                                //     ),
                                //   ),
                                // );
                              }
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ConfirmRiderRequest(
                              //       bookingType: currentIndex == 0
                              //           ? "Current Booking"
                              //           : "Schedule Booking",
                              //     ),
                              //   ),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Align(
                      //   alignment: Alignment.topCenter,
                      //   child: bookModel != null
                      //       ? Container(
                      //     margin: EdgeInsets.all(8.0),
                      //     padding: EdgeInsets.all(8.0),
                      //     decoration: boxDecoration(
                      //         showShadow: true, bgColor: Colors.white),
                      //     child: Row(
                      //       children: [
                      //         Expanded(
                      //           child: Text(
                      //             "You have an already ${bookModel!.bookingType!} ride",
                      //           ),
                      //         ),
                      //         boxWidth(10),
                      //         InkWell(
                      //           onTap: () async {
                      //             print(
                      //                 "dksjdksjdkjsf ${bookModel!.bookingType!}");
                      //             print(bookModel!.bookingType!.toLowerCase());
                      //             if (bookModel!.bookingType!
                      //                 .toLowerCase()
                      //                 .contains("schedule")) {
                      //               var result = await Navigator.push(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                       builder: (context) =>
                      //                           MyRidesPage("1")));
                      //               if (result != null) {
                      //                 getBookInfo();
                      //               }
                      //             } else if (bookModel!.bookingType!
                      //                 .toLowerCase()
                      //                 .contains("intercity")) {
                      //               var result1 = await Navigator.push(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                       builder: (context) =>
                      //                           InterCityRidePage("1")));
                      //               if (result1 != null) {
                      //                 getBookInfo();
                      //               }
                      //             } else {
                      //               var result2 = await Navigator.push(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                       builder: (context) => RentalRides(
                      //                         selected: false,
                      //                       )));
                      //               if (result2 != null) {
                      //                 getBookInfo();
                      //               }
                      //             }
                      //           },
                      //           child: Container(
                      //             width: 30.w,
                      //             height: 5.h,
                      //             decoration: boxDecoration(
                      //                 radius: 5,
                      //                 bgColor: Theme.of(context).primaryColor),
                      //             child: Center(
                      //                 child: text(
                      //                     getTranslated(context, "VIEW")!,
                      //                     fontFamily: fontMedium,
                      //                     fontSize: 10.sp,
                      //                     isCentered: true,
                      //                     textColor: Colors.white)),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      //       : SizedBox()
                      // ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: MyColorName.primaryLite,
                ),
              ),
        // bottomNavigationBar: saveStatus
        //     ? Container(
        //         color: Colors.white,
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.stretch,
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Container(
        //               height: getHeight(90),
        //               padding: EdgeInsets.all(getWidth(10)),
        //               child:Row(
        //                 children: List.generate(catList.length, (index){
        //                   return Expanded(child: InkWell(
        //                     onTap: () {
        //                       setState(() {
        //                         bookingDate = null;
        //                         currentIndex = index;
        //                       });
        //                       /*if (index == 0) {
        //                           setState(() {
        //                             currentIndex = index;
        //                           });
        //                           return;
        //                         }
        //                         if (bookModel == null) {
        //
        //                         } else {
        //                           UI.setSnackBar(
        //                               "You have an already scheduled ride", context);
        //                         }*/
        //                     },
        //                     child: Container(
        //                       // margin: EdgeInsets.only(right: getWidth(15)),
        //                       height: getHeight(90),
        //                       width: getWidth(90),
        //                       margin: EdgeInsets.all(getWidth(5)),
        //                       decoration: boxDecoration(
        //                         bgColor: currentIndex == index
        //                             ? MyColorName.primaryLite.withOpacity(0.1)
        //                             : Colors.transparent,
        //                         color: currentIndex == index?Colors.transparent:Colors.grey,
        //                         radius: 5,
        //                       ),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         children: [
        //                           SizedBox(width: 10,),
        //                           Image.asset(
        //                             catList[index].image,
        //                             width: getHeight(45),
        //                             height: getHeight(45),
        //                           ),
        //                           SizedBox(width: 10,),
        //                           Expanded(
        //                             child: Text(
        //                                 catList[index].name,
        //                               style: Theme.of(context).textTheme.titleLarge!.copyWith(
        //                                 fontSize: 14.0,
        //                                 fontWeight: FontWeight.w700
        //                               ),
        //                             ),
        //                           ),
        //                           SizedBox(width: 10,),
        //                         ],
        //                       ),
        //                     ),
        //                   ));
        //                 }).toList(),
        //               ),
        //             ),
        //
        //             // currentIndex == 2?Container(
        //             //   padding: EdgeInsets.all(getWidth(15)),
        //             //   child: Row(
        //             //     mainAxisAlignment:
        //             //     MainAxisAlignment.spaceBetween,
        //             //     children: [
        //             //       text(
        //             //         getTranslated(context, "START_NOW")!,
        //             //         fontSize: 9.sp,
        //             //         fontFamily: fontMedium,
        //             //         textColor: MyColorName.appbarBg,
        //             //       ),
        //             //       text("",
        //             //         // "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(DateTime.now().add(Duration(hours: int.parse(rentList[0].hours.toString()))))}",
        //             //         fontSize: 9.sp,
        //             //         fontFamily: fontMedium,
        //             //         textColor: MyColorName.appbarBg,
        //             //       ),
        //             //     ],
        //             //   ),
        //             // ):SizedBox(),
        //             currentIndex == 2
        //                 ? Padding(
        //                     padding: const EdgeInsets.only(left: 15.0),
        //                     child: Row(
        //                       children: [
        //                         InkWell(
        //                           onTap: () {
        //                             setState(() {
        //                               vehicleType = 0;
        //                               bikeIndex = 0;
        //                               tempList = bikeRentList.toList();
        //                             });
        //                           },
        //                           child: Container(
        //                             margin: EdgeInsets.only(right: getWidth(5)),
        //                             // height: getHeight(200),
        //                             // width: getWidth(110),
        //                             padding: EdgeInsets.all(getWidth(10)),
        //                             decoration: boxDecoration(
        //                                 bgColor: vehicleType == 0
        //                                     ? MyColorName.primaryLite
        //                                         .withOpacity(0.1)
        //                                     : Colors.transparent,
        //                                 radius: 5,
        //                                 color: MyColorName.colorTextPrimary),
        //                             child: Row(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.center,
        //                               mainAxisAlignment:
        //                                   MainAxisAlignment.center,
        //                               children: [
        //                                 // text(
        //                                 //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
        //                                 //   fontSize: 8.sp,
        //                                 //   fontFamily: fontMedium,
        //                                 //   textColor: MyColorName.appbarBg,
        //                                 // ),
        //                                 // boxHeight(10),
        //                                 Image.asset(
        //                                   "assets/cars/car1.png",
        //                                   height: getHeight(30),
        //                                   width: getWidth(30),
        //                                   fit: BoxFit.fill,
        //                                 ),
        //                                 SizedBox(
        //                                   height: 5,
        //                                   width: 5,
        //                                 ),
        //                                 Center(
        //                                   child: text(
        //                                     "Auto",
        //                                     // rentList[0].hours.toString()+" Hour",
        //                                     fontSize: 10.sp,
        //                                     fontFamily: fontMedium,
        //                                     textColor: MyColorName.appbarBg,
        //                                   ),
        //                                 ),
        //                                 // Row(
        //                                 //   mainAxisAlignment:
        //                                 //   MainAxisAlignment.spaceBetween,
        //                                 //   children: [
        //                                 //     text(
        //                                 //       "₹"+rentList[index].fixedRate.toString(),
        //                                 //       fontSize: 9.sp,
        //                                 //       fontFamily: fontMedium,
        //                                 //       textColor: MyColorName.appbarBg,
        //                                 //     ),
        //                                 //     text(
        //                                 //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
        //                                 //       fontSize: 7.sp,
        //                                 //       fontFamily: fontRegular,
        //                                 //       textColor: MyColorName.appbarBg,
        //                                 //     ),
        //                                 //   ],
        //                                 // ),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                         InkWell(
        //                           onTap: () {
        //                             setState(() {
        //                               vehicleType = 1;
        //                               bikeIndex = 0;
        //                               tempList = carRentList.toList();
        //                             });
        //                           },
        //                           child: Container(
        //                             margin: EdgeInsets.only(right: getWidth(5)),
        //                             // height: getHeight(200),
        //                             // width: getWidth(110),
        //                             padding: EdgeInsets.all(getWidth(10)),
        //                             decoration: boxDecoration(
        //                                 bgColor: vehicleType == 1
        //                                     ? MyColorName.primaryLite
        //                                         .withOpacity(0.1)
        //                                     : Colors.transparent,
        //                                 radius: 5,
        //                                 color: MyColorName.colorTextPrimary),
        //                             child: Row(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.center,
        //                               mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                               children: [
        //                                 // text(
        //                                 //   rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
        //                                 //   fontSize: 8.sp,
        //                                 //   fontFamily: fontMedium,
        //                                 //   textColor: MyColorName.appbarBg,
        //                                 // ),
        //                                 // boxHeight(10),
        //                                 Image.asset(
        //                                   "assets/cars/car2.png",
        //                                   height: getHeight(30),
        //                                   width: getWidth(30),
        //                                   fit: BoxFit.fill,
        //                                 ),
        //                                 SizedBox(
        //                                   height: 5,
        //                                   width: 5,
        //                                 ),
        //                                 Center(
        //                                   child: text(
        //                                     "Car",
        //                                     // rentList[0].hours.toString()+" Hour",
        //                                     fontSize: 10.sp,
        //                                     fontFamily: fontMedium,
        //                                     textColor: MyColorName.appbarBg,
        //                                   ),
        //                                 ),
        //                                 boxHeight(5),
        //                                 // Row(
        //                                 //   mainAxisAlignment:
        //                                 //   MainAxisAlignment.spaceBetween,
        //                                 //   children: [
        //                                 //     text(
        //                                 //       "₹"+rentList[index].fixedRate.toString(),
        //                                 //       fontSize: 9.sp,
        //                                 //       fontFamily: fontMedium,
        //                                 //       textColor: MyColorName.appbarBg,
        //                                 //     ),
        //                                 //     text(
        //                                 //       "₹"+rentList[index].ratePerHour.toString() + "/hr",
        //                                 //       fontSize: 7.sp,
        //                                 //       fontFamily: fontRegular,
        //                                 //       textColor: MyColorName.appbarBg,
        //                                 //     ),
        //                                 //   ],
        //                                 // ),
        //                               ],
        //                             ),
        //                           ),
        //                         )
        //                       ],
        //                     ),
        //                   )
        //                 : SizedBox(),
        //             currentIndex == 2
        //                 ? Container(
        //                     height: getHeight(255),
        //                     padding: EdgeInsets.all(getWidth(15)),
        //                     child:
        //                         // rentList.length>0?
        //                         ListView.builder(
        //                             itemCount: tempList.length,
        //                             // rentList[0].carCategories == "1" ? rentList[0].hoursData!.length
        //                             // : rentList[1].hoursData!.length,
        //                             shrinkWrap: true,
        //                             scrollDirection: Axis.horizontal,
        //                             itemBuilder: (context, index) {
        //                               return vehicleCardBike(
        //                                   tempList[index], index);
        //                               //   InkWell(
        //                               //   onTap: () {
        //                               //     setState(() {
        //                               //       timeIndex = index;
        //                               //     });
        //                               //   },
        //                               //   child: Container(
        //                               //     margin: EdgeInsets.only(right: getWidth(5)),
        //                               //     height: getHeight(150),
        //                               //     // width: getWidth(110),
        //                               //     padding: EdgeInsets.all(getWidth(10)),
        //                               //     decoration: boxDecoration(
        //                               //         bgColor: timeIndex == index
        //                               //             ? MyColorName.primaryLite
        //                               //                 .withOpacity(0.1)
        //                               //             : Colors.transparent,
        //                               //         radius: 5,
        //                               //         color: MyColorName.colorTextPrimary),
        //                               //     child: Column(
        //                               //       crossAxisAlignment: CrossAxisAlignment.start,
        //                               //       mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //       children: [
        //                               //         text(
        //                               //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
        //                               //           fontSize: 8.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         Image.asset(
        //                               //           rentList[index].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
        //                               //           height: getHeight(50),
        //                               //           width: getWidth(50),
        //                               //           fit: BoxFit.fill,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         text(
        //                               //           rentList[0].hoursData![0].hours.toString()+" Minutes",
        //                               //           fontSize: 10.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         // boxHeight(5),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //               MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //              "₹"+rentList[0].hoursData![0].fixedAmount.toString(),
        //                               //               fontSize: 9.sp,
        //                               //               fontFamily: fontMedium,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             boxWidth(5),
        //                               //             text(
        //                               //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //           ],
        //                               //         ),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             // text(
        //                               //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
        //                               //             //   + "kms",
        //                               //             //   fontSize: 7.sp,
        //                               //             //   fontFamily: fontRegular,
        //                               //             //   textColor: MyColorName.appbarBg,
        //                               //             // ),
        //                               //           ],
        //                               //         ),
        //                               //       ],
        //                               //     ),
        //                               //   ),
        //                               // )
        //                               //     :  InkWell(
        //                               //       onTap: () {
        //                               //         setState(() {
        //                               //           timeIndex = index;
        //                               //         });
        //                               //       },
        //                               //       child: Container(
        //                               //         margin: EdgeInsets.only(right: getWidth(5)),
        //                               //         height: getHeight(150),
        //                               //         // width: getWidth(110),
        //                               //         padding: EdgeInsets.all(getWidth(10)),
        //                               //         decoration: boxDecoration(
        //                               //             bgColor: timeIndex == index
        //                               //                 ? MyColorName.primaryLite
        //                               //                 .withOpacity(0.1)
        //                               //                 : Colors.transparent,
        //                               //             radius: 5,
        //                               //             color: MyColorName.colorTextPrimary),
        //                               //         child: Column(
        //                               //           crossAxisAlignment: CrossAxisAlignment.start,
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               rentList[1].carModel!=null?rentList[1].carModel.toString():"Auto",
        //                               //               fontSize: 8.sp,
        //                               //               fontFamily: fontMedium,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             boxHeight(10),
        //                               //             Image.asset(
        //                               //               rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
        //                               //               height: getHeight(50),
        //                               //               width: getWidth(50),
        //                               //               fit: BoxFit.fill,
        //                               //             ),
        //                               //             boxHeight(10),
        //                               //             text(
        //                               //               rentList[1].hoursData![index].hours.toString()+" Minutes",
        //                               //               fontSize: 10.sp,
        //                               //               fontFamily: fontMedium,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             // boxHeight(5),
        //                               //             Row(
        //                               //               mainAxisAlignment:
        //                               //               MainAxisAlignment.spaceBetween,
        //                               //               children: [
        //                               //                 text(
        //                               //                   "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
        //                               //                   fontSize: 9.sp,
        //                               //                   fontFamily: fontMedium,
        //                               //                   textColor: MyColorName.appbarBg,
        //                               //                 ),
        //                               //                 boxWidth(5),
        //                               //                 text(
        //                               //                   "₹"+rentList[1].ratePerHour.toString() + "/mins",
        //                               //                   fontSize: 7.sp,
        //                               //                   fontFamily: fontRegular,
        //                               //                   textColor: MyColorName.appbarBg,
        //                               //                 ),
        //                               //               ],
        //                               //             ),
        //                               //             Row(
        //                               //               mainAxisAlignment:
        //                               //               MainAxisAlignment.spaceBetween,
        //                               //               children: [
        //                               //                 text(
        //                               //                   "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
        //                               //                   fontSize: 7.sp,
        //                               //                   fontFamily: fontRegular,
        //                               //                   textColor: MyColorName.appbarBg,
        //                               //                 ),
        //                               //                 // text(
        //                               //                 //   "after "+rentList[0].hoursData![index].fixedKm.toString()
        //                               //                 //   + "kms",
        //                               //                 //   fontSize: 7.sp,
        //                               //                 //   fontFamily: fontRegular,
        //                               //                 //   textColor: MyColorName.appbarBg,
        //                               //                 // ),
        //                               //               ],
        //                               //             ),
        //                               //           ],
        //                               //         ),
        //                               //       ),
        //                               //     )
        //                               // : SizedBox.shrink();
        //                               // :  rentList[0].carCategories == "2" ?
        //                               // InkWell(
        //                               //   onTap: () {
        //                               //     setState(() {
        //                               //       timeIndex = index;
        //                               //     });
        //                               //   },
        //                               //   child: Container(
        //                               //     margin: EdgeInsets.only(right: getWidth(5)),
        //                               //     height: getHeight(150),
        //                               //     // width: getWidth(110),
        //                               //     padding: EdgeInsets.all(getWidth(10)),
        //                               //     decoration: boxDecoration(
        //                               //         bgColor: timeIndex == index
        //                               //             ? MyColorName.primaryLite
        //                               //             .withOpacity(0.1)
        //                               //             : Colors.transparent,
        //                               //         radius: 5,
        //                               //         color: MyColorName.colorTextPrimary),
        //                               //     child: Column(
        //                               //       crossAxisAlignment: CrossAxisAlignment.start,
        //                               //       mainAxisAlignment:
        //                               //       MainAxisAlignment.spaceBetween,
        //                               //       children: [
        //                               //         text(
        //                               //           rentList[0].carModel!=null?rentList[0].carModel.toString():"Auto",
        //                               //           fontSize: 8.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         Image.asset(
        //                               //           rentList[0].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
        //                               //           height: getHeight(50),
        //                               //           width: getWidth(50),
        //                               //           fit: BoxFit.fill,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         text(
        //                               //           rentList[0].hoursData![index].hours.toString()+" Minutes",
        //                               //           fontSize: 10.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         // boxHeight(5),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               "₹"+rentList[0].hoursData![index].fixedAmount.toString(),
        //                               //               fontSize: 9.sp,
        //                               //               fontFamily: fontMedium,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             boxWidth(5),
        //                               //             text(
        //                               //               "₹"+rentList[0].ratePerHour.toString() + "/mins",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //           ],
        //                               //         ),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               "₹"+'${rentList[0].ratePerHour.toString()}/hrs after '+rentList[0].hoursData![index].fixedKm.toString() + "Kms",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             // text(
        //                               //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
        //                               //             //   + "kms",
        //                               //             //   fontSize: 7.sp,
        //                               //             //   fontFamily: fontRegular,
        //                               //             //   textColor: MyColorName.appbarBg,
        //                               //             // ),
        //                               //           ],
        //                               //         ),
        //                               //       ],
        //                               //     ),
        //                               //   ),
        //                               // )
        //                               //     :  InkWell(
        //                               //   onTap: () {
        //                               //     setState(() {
        //                               //       timeIndex = index;
        //                               //     });
        //                               //   },
        //                               //   child: Container(
        //                               //     margin: EdgeInsets.only(right: getWidth(5)),
        //                               //     height: getHeight(150),
        //                               //     // width: getWidth(110),
        //                               //     padding: EdgeInsets.all(getWidth(10)),
        //                               //     decoration: boxDecoration(
        //                               //         bgColor: timeIndex == index
        //                               //             ? MyColorName.primaryLite
        //                               //             .withOpacity(0.1)
        //                               //             : Colors.transparent,
        //                               //         radius: 5,
        //                               //         color: MyColorName.colorTextPrimary),
        //                               //     child: Column(
        //                               //       crossAxisAlignment: CrossAxisAlignment.start,
        //                               //       mainAxisAlignment:
        //                               //       MainAxisAlignment.spaceBetween,
        //                               //       children: [
        //                               //         text(
        //                               //           rentList[1].carModel!=null?rentList[1].carModel.toString():"Auto",
        //                               //           fontSize: 8.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         Image.asset(
        //                               //           rentList[1].carModel!=null?"assets/cars/car2.png":"assets/cars/car1.png",
        //                               //           height: getHeight(50),
        //                               //           width: getWidth(50),
        //                               //           fit: BoxFit.fill,
        //                               //         ),
        //                               //         boxHeight(10),
        //                               //         text(
        //                               //           rentList[1].hoursData![index].hours.toString()+" Minutes",
        //                               //           fontSize: 10.sp,
        //                               //           fontFamily: fontMedium,
        //                               //           textColor: MyColorName.appbarBg,
        //                               //         ),
        //                               //         // boxHeight(5),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               "₹"+rentList[1].hoursData![index].fixedAmount.toString(),
        //                               //               fontSize: 9.sp,
        //                               //               fontFamily: fontMedium,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             boxWidth(5),
        //                               //             text(
        //                               //               "₹"+rentList[1].ratePerHour.toString() + "/mins",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //           ],
        //                               //         ),
        //                               //         Row(
        //                               //           mainAxisAlignment:
        //                               //           MainAxisAlignment.spaceBetween,
        //                               //           children: [
        //                               //             text(
        //                               //               "₹"+'${rentList[1].ratePerHour.toString()}/hrs after '+rentList[1].hoursData![index].fixedKm.toString() + "Kms",
        //                               //               fontSize: 7.sp,
        //                               //               fontFamily: fontRegular,
        //                               //               textColor: MyColorName.appbarBg,
        //                               //             ),
        //                               //             // text(
        //                               //             //   "after "+rentList[0].hoursData![index].fixedKm.toString()
        //                               //             //   + "kms",
        //                               //             //   fontSize: 7.sp,
        //                               //             //   fontFamily: fontRegular,
        //                               //             //   textColor: MyColorName.appbarBg,
        //                               //             // ),
        //                               //           ],
        //                               //         ),
        //                               //       ],
        //                               //     ),
        //                               //   ),
        //                               // );
        //                             })
        //                     // :SizedBox(),
        //                     )
        //                 : SizedBox(),
        //             Container(
        //               height: 60,
        //               margin: EdgeInsets.all(10),
        //               child: TextFormField(
        //                 controller: pickupCon,
        //                 readOnly: true,
        //                 onTap: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => PlacePicker(
        //                         apiKey: Platform.isAndroid
        //                             ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
        //                             : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
        //                         onPlacePicked: (result) {
        //                           if (currentIndex == 3) {
        //                             latitude = result.geometry!.location.lat;
        //                             longitude = result.geometry!.location.lng;
        //                             pickupCon.text =
        //                                 result.formattedAddress.toString();
        //                             if (result.formattedAddress
        //                                     .toString()
        //                                     .split(",")
        //                                     .length >
        //                                 2) {
        //                               List<String> cityList = result
        //                                   .formattedAddress
        //                                   .toString()
        //                                   .split(",");
        //                               setState(() {
        //                                 pickupCityCon.text =
        //                                     cityList[cityList.length - 3];
        //                               });
        //                             }
        //                             /* getAddress(latitude, longitude)
        //                                 .then((value) {
        //                               if (!value.first.city
        //                                   .toString()
        //                                   .contains("pricing"))
        //                                 setState(() {
        //                                   pickupCityCon.text =
        //                                       value.first.city.toString();
        //                                 });
        //                             });*/
        //                           } else {
        //                             setState(() {
        //                               pickupCon.text =
        //                                   result.formattedAddress.toString();
        //                               latitude = result.geometry!.location.lat;
        //                               longitude = result.geometry!.location.lng;
        //                             });
        //                           }
        //
        //                           Navigator.of(context).pop();
        //                         },
        //                         initialPosition: LatLng(latitude, longitude),
        //                         useCurrentLocation: true,
        //                       ),
        //                     ),
        //                   );
        //                 },
        //                 decoration: InputDecoration(
        //                   labelText: getTranslated(context, "PICKUP_LOCATION"),
        //                   filled: true,
        //                   suffixIcon: currentIndex == 3
        //                       ? Text(pickupCityCon.text)
        //                       : null,
        //                   fillColor: Colors.white,
        //                 ),
        //               ),
        //             ),
        //             currentIndex != 2
        //                 ? Container(
        //                     height: 60,
        //                     margin: EdgeInsets.all(10),
        //                     child: TextFormField(
        //                       controller: dropCon,
        //                       readOnly: true,
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                             builder: (context) => PlacePicker(
        //                               apiKey: Platform.isAndroid
        //                                   ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
        //                                   : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
        //                               onPlacePicked: (result) {
        //                                 print(result.formattedAddress);
        //                                 if (currentIndex == 3) {
        //                                   dropLatitude =
        //                                       result.geometry!.location.lat;
        //                                   dropLongitude =
        //                                       result.geometry!.location.lng;
        //                                   dropCon.text = result.formattedAddress
        //                                       .toString();
        //                                   if (result.formattedAddress
        //                                           .toString()
        //                                           .split(",")
        //                                           .length >
        //                                       2) {
        //                                     List<String> cityList = result
        //                                         .formattedAddress
        //                                         .toString()
        //                                         .split(",");
        //                                     setState(() {
        //                                       dropCityCon.text =
        //                                           cityList[cityList.length - 3];
        //                                     });
        //                                   }
        //                                   /*getAddress(
        //                                           dropLatitude, dropLongitude)
        //                                       .then((value) {
        //                                     if (!value.first.city
        //                                         .toString()
        //                                         .contains("pricing"))
        //                                       setState(() {
        //                                         dropCityCon.text =
        //                                             value.first.city.toString();
        //                                       });
        //                                   });*/
        //                                 } else {
        //                                   setState(() {
        //                                     dropCon.text = result
        //                                         .formattedAddress
        //                                         .toString();
        //                                     dropLatitude =
        //                                         result.geometry!.location.lat;
        //                                     dropLongitude =
        //                                         result.geometry!.location.lng;
        //                                   });
        //                                 }
        //                                 Navigator.of(context).pop();
        //                                 //  getBookInfo();
        //                                 // getRides("3");
        //                               },
        //                               initialPosition: dropLatitude != 0
        //                                   ? LatLng(dropLatitude, dropLongitude)
        //                                   : LatLng(latitude, longitude),
        //                               useCurrentLocation: true,
        //                             ),
        //                           ),
        //                         );
        //                       },
        //                       decoration: InputDecoration(
        //                         labelText:
        //                             getTranslated(context, "DROP_LOCATION"),
        //                         suffixIcon: currentIndex == 3
        //                             ? Text(dropCityCon.text)
        //                             : null,
        //                         filled: true,
        //                         fillColor: Colors.white,
        //                       ),
        //                     ),
        //                   )
        //                 : SizedBox(),
        //             /*currentIndex != 2
        //           ? Container(
        //               color: theme.backgroundColor,
        //               padding: EdgeInsets.symmetric(horizontal: 20),
        //               height: 52,
        //               child: Row(
        //                 children: [
        //                   Text(
        //                     getTranslated(context, "PAYMENT_MODE")!,
        //                     style:
        //                         Theme.of(context).textTheme.bodyText1!.copyWith(
        //                               fontSize: 13.5,
        //                             ),
        //                   ),
        //                   Spacer(),
        //                   Container(
        //                     width: 1,
        //                     height: 28,
        //                     color: theme.hintColor,
        //                   ),
        //                   Spacer(),
        //                   PopupMenuButton(
        //                     child: Row(
        //                       children: [
        //                         Icon(
        //                           Icons.account_balance_wallet,
        //                           color: theme.primaryColor,
        //                           size: 20,
        //                         ),
        //                         SizedBox(width: 12),
        //                         Text(
        //                           paymentType != ""
        //                               ? paymentType
        //                               : getTranslated(context, 'WALLET')!,
        //                           style: theme.textTheme.button!.copyWith(
        //                               color: theme.primaryColor, fontSize: 15),
        //                         ),
        //                       ],
        //                     ),
        //                     onSelected: (val) {
        //                       setState(() {
        //                         paymentType = val.toString();
        //                       });
        //                     },
        //                     offset: Offset(0, -144),
        //                     color: theme.backgroundColor,
        //                     shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(8)),
        //                     itemBuilder: (BuildContext context) {
        //                       return [
        //                         PopupMenuItem(
        //                           value: getString(Strings.CASH)!,
        //                           child: Row(
        //                             children: [
        //                               Icon(Icons.credit_card_sharp),
        //                               SizedBox(width: 12),
        //                               Text(getTranslated(context, 'CASH')!),
        //                             ],
        //                           ),
        //                         ),
        //                         PopupMenuItem(
        //                           child: Row(
        //                             children: [
        //                               Icon(Icons.account_balance_wallet),
        //                               SizedBox(width: 12),
        //                               Text(getTranslated(context, 'WALLET')!),
        //                             ],
        //                           ),
        //                           value: getString(Strings.WALLET)!,
        //                         ),
        //                       ];
        //                     },
        //                   ),
        //                 ],
        //               ),
        //             )
        //           : SizedBox.shrink(),*/
        //             currentIndex == 3
        //                 ? Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: [
        //                         InkWell(
        //                           onTap: () {
        //                             setState(() {
        //                               sharing = false;
        //                             });
        //                           },
        //                           child: Row(
        //                             children: [
        //                               boxWidth(10),
        //                               Icon(
        //                                   !sharing
        //                                       ? Icons.radio_button_checked_sharp
        //                                       : Icons
        //                                           .radio_button_unchecked_sharp,
        //                                   color: Theme.of(context)
        //                                       .colorScheme
        //                                       .primary),
        //                               boxWidth(5),
        //                               text("Personal",
        //                                   fontFamily: fontMedium,
        //                                   fontSize: 10.sp,
        //                                   textColor: Theme.of(context)
        //                                       .colorScheme
        //                                       .primary),
        //                             ],
        //                           ),
        //                         ),
        //                         InkWell(
        //                           onTap: () {
        //                             if (latitude != 0 &&
        //                                 dropLatitude != 0 &&
        //                                 dropCon.text != "") {
        //                               setState(() {
        //                                 sharing = true;
        //                                 loadingButton = true;
        //                               });
        //                               getShareRide();
        //                             } else {
        //                               UI.setSnackBar(
        //                                   "Please Pick Both Location", context);
        //                             }
        //                           },
        //                           child: Row(
        //                             children: [
        //                               Icon(
        //                                   sharing
        //                                       ? Icons.radio_button_checked_sharp
        //                                       : Icons
        //                                           .radio_button_unchecked_sharp,
        //                                   color: Theme.of(context)
        //                                       .colorScheme
        //                                       .primary),
        //                               boxWidth(5),
        //                               text("Sharing",
        //                                   fontFamily: fontMedium,
        //                                   fontSize: 10.sp,
        //                                   textColor: Theme.of(context)
        //                                       .colorScheme
        //                                       .primary),
        //                               boxWidth(10),
        //                             ],
        //                           ),
        //                         ),
        //                       ],
        //                     ))
        //                 : SizedBox(),
        //             currentIndex == 3 && sharing
        //                 ? Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: text(
        //                         shareRideList.length > 0
        //                             ? "Similar Sharing Rides"
        //                             : "No Similar Rides Available",
        //                         fontFamily: fontMedium,
        //                         fontSize: 10.sp,
        //                         isCentered: true,
        //                         textColor: shareRideList.length > 0
        //                             ? Theme.of(context).primaryColor
        //                             : Colors.redAccent))
        //                 : SizedBox(),
        //             currentIndex == 3 && sharing && shareRideList.length > 0
        //                 ? Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: ListView.builder(
        //                         shrinkWrap: true,
        //                         itemCount: shareRideList.length,
        //                         itemBuilder: (context, index) {
        //                           return shareRideList[index].pickupDate !=
        //                                       null &&
        //                                   shareRideList[index].pickupTime !=
        //                                       null
        //                               ? ListTile(
        //                                   leading: Icon(
        //                                     Icons.location_on_rounded,
        //                                     color: Colors.green,
        //                                   ),
        //                                   shape: RoundedRectangleBorder(
        //                                       borderRadius:
        //                                           BorderRadius.circular(8.0),
        //                                       side: BorderSide(
        //                                           color: Colors.grey)),
        //                                   title: Text(
        //                                     "${shareRideList[index].pickupCity}-${shareRideList[index].dropCity}",
        //                                     style: TextStyle(
        //                                         fontWeight: FontWeight.w700),
        //                                   ),
        //                                   subtitle: Text(
        //                                     shareRideList[index].pickupDate !=
        //                                                 null &&
        //                                             shareRideList[index]
        //                                                     .pickupTime !=
        //                                                 null
        //                                         ? "${shareRideList[index].pickupDate} ${shareRideList[index].pickupTime}"
        //                                         : "",
        //                                     style: TextStyle(
        //                                         fontWeight: FontWeight.w400,
        //                                         fontSize: 10),
        //                                   ),
        //                                   trailing: InkWell(
        //                                     onTap: () {
        //                                       showRide(shareRideList[index]);
        //                                     },
        //                                     child: Container(
        //                                       width: 30.w,
        //                                       margin: EdgeInsets.symmetric(
        //                                           vertical: 5, horizontal: 16),
        //                                       height: 5.h,
        //                                       decoration: boxDecoration(
        //                                           radius: 5,
        //                                           bgColor: Theme.of(context)
        //                                               .primaryColor),
        //                                       child: Center(
        //                                           child: text(
        //                                               "Join ₹${shareRideList[index].amount}",
        //                                               fontFamily: fontMedium,
        //                                               fontSize: 10.sp,
        //                                               isCentered: true,
        //                                               textColor: Colors.white)),
        //                                     ),
        //                                   ),
        //                                 )
        //                               : SizedBox();
        //                         }),
        //                   )
        //                 : SizedBox(),
        //             currentIndex == 3 && sharing
        //                 ? Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: text(getTranslated(context, "ONLY")!,
        //                         fontFamily: fontMedium,
        //                         fontSize: 10.sp,
        //                         isCentered: true,
        //                         textColor: Colors.redAccent))
        //                 : SizedBox(),
        //             bookingDate != null
        //                 ? Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: text(
        //                         "${getTranslated(context, "BOOKING_DATE")} : " +
        //                             getDate(bookingDate.toString()),
        //                         fontFamily: fontMedium,
        //                         fontSize: 10.sp,
        //                         textColor:
        //                             Theme.of(context).colorScheme.primary))
        //                 : SizedBox(),
        //           /*  currentIndex != 3 && isFirstUser == "0"
        //                 ? Center(
        //                     child: Container(
        //                       padding: EdgeInsets.all(getWidth(10)),
        //                       color: Colors.white,
        //                       child: AnimatedTextKit(
        //                         animatedTexts: [
        //                           ColorizeAnimatedText(
        //                             "Get special offer on your first ride",
        //                             textStyle: colorizeTextStyle,
        //                             colors: colorizeColors,
        //                           ),
        //                         ],
        //                         pause: Duration(milliseconds: 100),
        //                         isRepeatingAnimation: true,
        //                         totalRepeatCount: 100,
        //                         onTap: () {
        //                           print("Tap Event");
        //                         },
        //                       ),
        //                     ),
        //                   )
        //                 : const SizedBox.shrink(),*/
        //             Padding(
        //               padding: const EdgeInsets.all(8.0),
        //               child: Row(
        //                 mainAxisAlignment: currentIndex == 1 ||
        //                         currentIndex == 3 ||
        //                         currentIndex == 2
        //                     ? MainAxisAlignment.spaceEvenly
        //                     : MainAxisAlignment.center,
        //                 children: [
        //                   InkWell(
        //                     onTap: () async {
        //                       bool status  = await getBookInfo();
        //                       if(status){
        //
        //                       }
        //
        //                       if (bookModel != null &&
        //                           (getDifference() || getDayDifference())) {
        //                         UI.setSnackBar(
        //                             "you have a booking in an hour or same day",
        //                             context);
        //                         return;
        //                       }
        //                       if (rideList.isNotEmpty) {
        //                         return;
        //                       }
        //                       if (currentIndex == 2) {
        //                         if (bookingDate == null) {
        //                           UI.setSnackBar(
        //                               "Please Select Date and Time", context);
        //                         } else {
        //                           showRental();
        //                         }
        //                       } else if (currentIndex == 1 &&
        //                               bookingDate == null ||
        //                           currentIndex == 3 && bookingDate == null) {
        //                         UI.setSnackBar(
        //                             "Please Select Date and Time", context);
        //                         return;
        //                       } else if (latitude != 0 && dropLatitude != 0) {
        //                         var result = await Navigator.push(
        //                             context,
        //                             MaterialPageRoute(
        //                                 builder: (context) => ChooseCabPage(
        //                                       LatLng(latitude, longitude),
        //                                       LatLng(
        //                                           dropLatitude, dropLongitude),
        //                                       pickupCon.text,
        //                                       pickupCityCon.text,
        //                                       dropCityCon.text,
        //                                       dropCon.text,
        //                                       paymentType,
        //                                       bookingDate != null
        //                                           ? bookingDate
        //                                           : null,
        //                                       currentIndex == 3
        //                                           ? sharing
        //                                               ? "Share"
        //                                               : "Personal"
        //                                           : "",
        //                                     )));
        //                         print(result);
        //                         if (result == "yes") {
        //                           setState(() {
        //                             bookingDate = null;
        //                             dropCon.text = "";
        //                           });
        //                           getLocation();
        //                           getBookInfo();
        //                           var result1 = await Navigator.push(
        //                               context,
        //                               MaterialPageRoute(
        //                                   builder: (context) =>
        //                                       MyRidesPage("1")));
        //                           if (result1 != null) {
        //                             getBookInfo();
        //                           }
        //                         } else if (result == "yes1") {
        //                           setState(() {
        //                             bookingDate = null;
        //                             dropCon.text = "";
        //                           });
        //                           getLocation();
        //                           getBookInfo();
        //                           var result2 = await Navigator.push(
        //                               context,
        //                               MaterialPageRoute(
        //                                   builder: (context) =>
        //                                       InterCityRidePage("1")));
        //                           if (result2 != null) {
        //                             getBookInfo();
        //                           }
        //                         } else if (result == "yes2") {
        //                           getCurrentInfo(first: true);
        //                           getRides("3");
        //                           getBookInfo();
        //                         }
        //                       } else {
        //                         UI.setSnackBar(
        //                             "Please Pick Both Location", context);
        //                       }
        //                     },
        //                     child: Container(
        //                       width: 75.w,
        //                       height: 6.h,
        //                       decoration: boxDecoration(
        //                           radius: 10,
        //                           bgColor: Theme.of(context).primaryColor),
        //                       child: Center(
        //                           child: currentIndex == 2 || currentIndex == 3
        //                               ? loadingRental || loadingButton
        //                                   ? CircularProgressIndicator(
        //                                       color: Colors.white,
        //                                     )
        //                                   : text(
        //                                       getTranslated(
        //                                           context, "CONTINUE")!,
        //                                       fontFamily: fontMedium,
        //                                       fontSize: 12.sp,
        //                                       textColor: Colors.white)
        //                               : text(
        //                                   getTranslated(context, "CONTINUE")!,
        //                                   fontFamily: fontMedium,
        //                                   fontSize: 12.sp,
        //                                   textColor: Colors.white)),
        //                     ),
        //                   ),
        //                   currentIndex == 1 ||
        //                           currentIndex == 3 ||
        //                           currentIndex == 2
        //                       ? InkWell(
        //                           onTap: () {
        //                             DatePicker.showDateTimePicker(context,
        //                                 showTitleActions: true,
        //                                 onChanged: (date) {
        //                               print('change $date in time zone ' +
        //                                   date.timeZoneOffset.inHours
        //                                       .toString());
        //                             }, onConfirm: (date) {
        //                               setState(() {
        //                                 bookingDate = date;
        //                                 bookngDat = bookingDate.toString();
        //                               });
        //                               bookingTime =
        //                                   DateFormat('HH:mm:ss').format(date);
        //                               print(
        //                                   'confirm $date -----$bookingTime -----$bookngDat');
        //                             },
        //                                 currentTime: DateTime.now(),
        //                                 minTime: DateTime.now()
        //                                     .subtract(Duration(hours: 1)),
        //                                 maxTime: DateTime.now()
        //                                     .add(Duration(days: 3)));
        //                           },
        //                           child: Container(
        //                             decoration: boxDecoration(
        //                                 radius: 10,
        //                                 color: Theme.of(context).primaryColor),
        //                             height: 6.h,
        //                             width: 6.h,
        //                             child: Icon(
        //                               Icons.calendar_today_outlined,
        //                               color: Theme.of(context).primaryColor,
        //                               size: 20.sp,
        //                             ),
        //                           ),
        //                         )
        //                       : SizedBox()
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     : SizedBox(),
      ),
    );
  }

  getDifference() {
    String date = bookModel!.pickupDate.toString();
    DateTime temp = DateTime.parse(date);
    //  print(temp);
    //print(date);
    if (temp.day == DateTime.now().day) {
      if (bookModel!.pickupTime != null) {
        String time = bookModel!.pickupTime.toString().split(" ")[0];
        int i = 0;
        if (bookModel!.pickupTime.toString().split(" ").length > 1 &&
            bookModel!.pickupTime.toString().split(" ")[1].toLowerCase() ==
                "pm") {
          i = 12;
        }
        // print(time);
        if (time != "") {
          DateTime temp = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              int.parse(time.split(":")[0]) + i,
              int.parse(time.split(":")[1]));
          /* print("check" + temp.difference(DateTime.now()).inHours.toString());
        print(temp);
        print(DateTime.now());
        print(temp.difference(DateTime.now()).inHours);
        print(1 > temp.difference(DateTime.now()).inHours);*/
          return 1 > temp.difference(DateTime.now()).inHours;
        }
        return true;
      } else {
        return true;
      }
    } else {
      print(false);
      return false;
    }
  }

  getDayDifference() {
    String date = bookModel!.pickupDate.toString();
    DateTime temp1 = DateTime.parse(date);
    print(temp1);
    print(date);
    String time = bookModel!.pickupTime.toString().split(" ")[0];
    int i = 0;
    if (bookModel!.pickupTime.toString().split(" ").length > 1 &&
        bookModel!.pickupTime.toString().split(" ")[1].toLowerCase() == "pm") {
      i = 12;
    }
    print("time$time");
    if (time != "" && bookingDate != null) {
      DateTime temp = DateTime(temp1.year, temp1.month, temp1.day,
          int.parse(time.split(":")[0]) + i, int.parse(time.split(":")[1]));
      print(bookingDate);
      print("day" + temp.difference(bookingDate!).inDays.toString());
      print(temp);
      print(DateTime.now());
      print(temp.difference(bookingDate!).inHours.abs());
      print(1 > temp.difference(bookingDate!).inHours);
      return temp.difference(bookingDate!).inDays == 0 &&
          temp.difference(bookingDate!).inHours.abs() < 12;
    } else {
      print("day" + temp1.difference(DateTime.now()).inDays.toString());
      return false;
    }
    /*else {
      print(false);
      return false;
    }*/
  }

  showRide(ShareRideModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "CONFIRM_RIDE")!,
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
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
                          child: text(pickupCon.text,
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
                          child: text(dropCon.text,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          "assets/cars/car2.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      text("₹" + model.amount!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "PAYMENT_MODE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(model.transaction!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "DISTANCE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(model.km! + " Km",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "TAXES")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("₹" + model.gstAmount!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "SURGE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("₹" + model.surgeAmount!,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  /*promoDiscount != "0"
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "PROMO")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("-₹" + promoDiscount,
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  )
                      : SizedBox(),*/
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "TOTAL")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(
                          "₹" +
                              (double.parse(model.surgeAmount!) +
                                      double.parse(model.gstAmount!) +
                                      double.parse(model.amount!))
                                  .toStringAsFixed(2),
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  model.cancelCharge != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text(
                                "${getTranslated(context, "CANCEL_CHARGE")} : ",
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                            text("₹" + model.cancelCharge.toString(),
                                fontSize: 10.sp,
                                fontFamily: fontMedium,
                                textColor: Colors.black),
                          ],
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "RIDE_TYPE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text("Share",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text("${getTranslated(context, "BOOKING_DATE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      Expanded(
                          child: text("${model.pickupDate} ${model.pickupTime}",
                              fontSize: 10.sp,
                              fontFamily: fontMedium,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration:
                              boxDecoration(radius: 5, bgColor: Colors.grey),
                          child: Center(
                              child: text(getTranslated(context, "CANCEL")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          //print("this is schedule time ${bookingDate!.hour} : ${bookingDate!.minute}");
                          if (totalBal.isNegative) {
                            setState(() {
                              saveStatus = true;
                            });
                            UI.setSnackBar(
                                "You have negative balance, Please update wallet",
                                context);
                          } else {
                            addInterCityRides(model);
                          }

                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child: Center(
                              child: text(getTranslated(context, "CONFIRM")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  DateTime? bookingDate;
  String? bookngDat;
  String? bookingTime;
  DateTime? returnDate;
  String? retrnDat;
  String? returnTime;
  MyRideModel? model1;
  MyRideModel? bookModel;
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
  Future<bool> getBookInfo() async {
    try {
      setState(() {
        saveStatus = false;
        bookModel = null;
      });
      Map params = {
        "user_id": curUserId,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "payment/get_user_booking_details"), params);
      setState(() {
        saveStatus = true;
      });
      if (response['status'] && response["data"].length > 0) {
        var v = response["data"][0];
        setState(() {
          //currentIndex = 0;
          bookModel = MyRideModel.fromJson(v);
        });
        return true;
        //print(data);
      } else {
        return false;
        // UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
      return false;
    }
  }

  getCurrentInfo({bool first = false}) async {
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
        setState(() {
          model1 = MyRideModel.fromJson(v);
        });
        var result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => RideBookedPage(model1!)));
        if (result != null && result) {
          setState(() {
            saveStatus = false;
          });
          // getRidess("3", first: true);
          getBookInfo();
        }
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

  showRental() {
    /* surge = 0;
    gst = 0;
    gst = ((double.parse(rideList[_currentCar].gst)*double.parse(rideList[_currentCar].intailrate))/100).roundToDouble();
    if(!rideList[_currentCar].serge.contains("Not")&&rideList[_currentCar].surge_charge.length>0){
      if(rideList[_currentCar].surge_charge[0]['time_on_off'].toString()!="CLOSED"){
        surge = (double.parse(rideList[_currentCar].surge_charge[0]['amount'].toString())).roundToDouble();
      }else{
        surge = 0;
      }
    }*/
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(getWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text(getTranslated(context, "CONFIRM_RIDE")!,
                      fontSize: 10.sp,
                      fontFamily: fontMedium,
                      textColor: Colors.black),
                  Divider(),
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
                          child: text(pickupCon.text,
                              fontSize: 9.sp,
                              fontFamily: fontRegular,
                              textColor: Colors.black)),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          vehicleType == 0
                              ? "assets/cars/car1.png"
                              : "assets/cars/car2.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      text(
                          vehicleType == 0
                              ? "Auto"
                              : carRentList[timeIndex].carModel != null
                                  ? carRentList[timeIndex].carModel.toString()
                                  : "Car",
                          fontSize: 10.sp,
                          fontFamily: fontRegular,
                          textColor: Colors.black),
                      // text(
                      //     "₹" + rentList[0].hoursData![timeIndex].fixedAmount!,
                      //     fontSize: 10.sp,
                      //     fontFamily: fontMedium,
                      //     textColor: Colors.black),
                    ],
                  ),
                  boxHeight(10),
                  Divider(),
                  // boxHeight(10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     text("${getTranslated(context, "PAYMENT_MODE")} : ",
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //     text(paymentType,
                  //         fontSize: 10.sp,
                  //         fontFamily: fontMedium,
                  //         textColor: Colors.black),
                  //   ],
                  // ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        'Start Time - ${DateFormat.jm().format(bookingDate!)}',
                        // getTranslated(context, "START_NOW")!,
                        fontSize: 9.sp,
                        fontFamily: fontMedium,
                        textColor: MyColorName.appbarBg,
                      ),
                      text(
                        "${getTranslated(context, "END_TIME")} - ${DateFormat.jm().format(bookingDate!.add(Duration(minutes: int.parse(tempList[bikeIndex].hoursData![tempList[bikeIndex].selectedIndex!].hours.toString()))))}",
                        fontSize: 9.sp,
                        fontFamily: fontMedium,
                        textColor: MyColorName.appbarBg,
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "TOTAL")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(
                          double.parse(tempList[bikeIndex]
                                  .hoursData![
                                      tempList[bikeIndex].selectedIndex!]
                                  .fixedAmount
                                  .toString())
                              .toStringAsFixed(2),
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("${getTranslated(context, "CANCEL_CHARGE")} : ",
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black),
                      text(
                          "₹" +
                              tempList[bikeIndex]
                                  .cancellationCharges
                                  .toString(),
                          fontSize: 10.sp,
                          fontFamily: fontMedium,
                          textColor: Colors.black)
                    ],
                  ),
                  boxHeight(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context1);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FindingRidePage()));
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration:
                              boxDecoration(radius: 5, bgColor: Colors.grey),
                          child: Center(
                              child: text(getTranslated(context, "CANCEL")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            loadingRental = true;
                          });
                          Navigator.pop(context1);
                          // if(totalBal > 0){
                          addRides();
                          // }else{

                          //   UI.setSnackBar("User not allowed! wallet balance is low", context);
                          // }
                        },
                        child: Container(
                          width: 30.w,
                          height: 5.h,
                          decoration: boxDecoration(
                              radius: 5,
                              bgColor: Theme.of(context).primaryColor),
                          child: Center(
                              child: text(getTranslated(context, "CONFIRM")!,
                                  fontFamily: fontMedium,
                                  fontSize: 10.sp,
                                  isCentered: true,
                                  textColor: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  addInterCityRides(ShareRideModel model) async {
    try {
      setState(() {
        saveStatus = false;
        loadingButton = true;
      });
      Map params = {
        "user_id": curUserId,
        "booking_id": model.id,
        "pickup_address": pickupCon.text,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "drop_address": dropCon.text,
        "share_user_id": model.userId,
        "drop_latitude": dropLatitude.toString(),
        "drop_longitude": dropLongitude.toString(),
      };
      print(params);
      //  return;
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/share_ride_user"), params);
      setState(() {
        saveStatus = true;
        loadingButton = false;
      });
      if (response['status']) {
        getBookInfo();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InterCityRidePage(
                      "1",
                    )));
        UI.setSnackBar("Booking Confirmed", context);
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
        loadingRental = false;
      });
    }
  }

  addRides() async {
    try {
      setState(() {
        saveStatus = false;
        loadingRental = true;
      });

      Map params = {
        "user_id": curUserId,
        "username": name,
        "pickup_address": pickupCon.text,
        "drop_address": dropCon.text,
        "latitude": latitude.toString(),
        "pickup_date": DateFormat("yyyy-MM-dd").format(bookingDate!),
        "distance": tempList[bikeIndex]
            .hoursData![tempList[bikeIndex].selectedIndex!]
            .fixedKm
            .toString(),
        "extra_time_charge": tempList[bikeIndex].ratePerHour.toString(),
        "admin_commission": tempList[bikeIndex].adminCommission.toString(),
        "extra_km_charge": tempList[bikeIndex].ratePerKm.toString(),
        "longitude": longitude.toString(),
        "taxi_type": vehicleType == 0 ? "Auto" : "Car",
        "cancel_charge": tempList[bikeIndex].cancellationCharges.toString(),
        "hours": tempList[bikeIndex]
            .hoursData![tempList[bikeIndex].selectedIndex!]
            .hours
            .toString(),

        "start_time":
            //bookingTime.toString(),
            DateFormat("HH:mm").format(bookingDate!),
        "end_time": DateFormat("HH:mm").format(bookingDate!.add(Duration(
            minutes: int.parse(tempList[bikeIndex]
                .hoursData![tempList[bikeIndex].selectedIndex!]
                .hours
                .toString())))),
        "delivery_type": vehicleType == 0 ? "1" : "2",
        //rentList[timeIndex].cartype!=""&&rentList[timeIndex].cartype!="Auto"?"2":"1",
        "taxi_id": tempList[bikeIndex].cabId,
        "amount": tempList[bikeIndex]
            .hoursData![tempList[bikeIndex].selectedIndex!]
            .fixedAmount
            .toString(),
        "paid_amount": tempList[bikeIndex]
            .hoursData![tempList[bikeIndex].selectedIndex!]
            .fixedAmount
            .toString()
      };
      /*Map params = {
    "user_id": curUserId,
    "username": name,
    "pickup_address": pickupCon.text,
    "latitude": latitude.toString(),
    "pickup_date": DateFormat("yyyy-MM-dd").format(bookingDate!),
    "distance":
    ? tempList[bikeIndex].hoursData![tempList[bikeIndex].selectedIndex!].fixedKm.toString()
        : carRentList[0].hoursData![timeIndex].fixedKm.toString(),
    "extra_time_charge": vehicleType == 0
    ? bikeRentList[0].ratePerHour.toString()
        : carRentList[0].ratePerHour.toString(),
    "admin_commission": vehicleType == 0
    ? bikeRentList[0].adminCommission.toString()
        : carRentList[0].adminCommission.toString(),
    "extra_km_charge": vehicleType == 0
    ? bikeRentList[0].ratePerKm.toString()
        : carRentList[0].ratePerKm.toString(),
    "longitude": longitude.toString(),
    "taxi_type": vehicleType == 0 ? "Auto" : carRentList[timeIndex].cartype,
    "cancel_charge": vehicleType == 0
    ? bikeRentList[0].cancellationCharges.toString()
        : carRentList[timeIndex].cancellationCharges.toString(),
    "hours": vehicleType == 0
    ? bikeRentList[0].hoursData![bikeIndex].hours.toString()
        : carRentList[timeIndex].hours.toString(),
    "start_time":
    //bookingTime.toString(),
    DateFormat("HH:mm").format(bookingDate!),
    "end_time": vehicleType == 0
    ? DateFormat("HH:mm").format(bookingDate!.add(Duration(
    minutes: int.parse(
    bikeRentList[0].hoursData![bikeIndex].hours.toString()))))
        : DateFormat.jm().format(bookingDate!.add(Duration(
    minutes: int.parse(
    bikeRentList[timeIndex].hoursData![0].hours.toString())))),
    "delivery_type": vehicleType == 0 ? "1" : "2",
    //rentList[timeIndex].cartype!=""&&rentList[timeIndex].cartype!="Auto"?"2":"1",
    "taxi_id": vehicleType == 0
    ? bikeRentList[0].cabId
        : carRentList[timeIndex].cabId,
    "amount": vehicleType == 0
    ? bikeRentList[0].hoursData![bikeIndex].fixedAmount.toString()
        : carRentList[0].hoursData![timeIndex].fixedAmount.toString(),
    "paid_amount": vehicleType == 0
    ? bikeRentList[0].hoursData![bikeIndex].fixedAmount.toString()
        : carRentList[0].hoursData![timeIndex].fixedAmount.toString()
    };*/
      print(params);
      // return;
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/rental_booking_trip"), params);
      setState(() {
        saveStatus = true;
        loadingRental = false;
      });
      if (response['status']) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RentalRides(
                      selected: false,
                    )));
        UI.setSnackBar("Booking Confirmed", context);
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
        loadingRental = false;
      });
    }
  }
}
