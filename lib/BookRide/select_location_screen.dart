import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:pristine_andaman/BookRide/choose_cab_page.dart';
import 'package:pristine_andaman/BookRide/choose_favorite_location.dart';
import 'package:sizer/sizer.dart';

import '../Components/entry_field.dart';
import '../Model/location_model.dart';
import '../Theme/style.dart';
import '../utils/Session.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/new_utils/MapScreen.dart';
import '../utils/new_utils/ui.dart';
import '../utils/widget.dart';

class SelectLocationScreen extends StatefulWidget {
  int currentIndex;
  String? selectCabType;
  LocationData? availableLocationList;
  SelectLocationScreen(
      {this.currentIndex = 0,
      this.selectCabType,
      required this.availableLocationList});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  TextEditingController pickupCon = new TextEditingController();
  TextEditingController dropCon = new TextEditingController();

  TextEditingController pickupCityCon = new TextEditingController();
  TextEditingController dropCityCon = new TextEditingController();

  FocusNode _pickFocusNode = FocusNode();
  FocusNode _dropFocusNode = FocusNode();

  DateTime? bookingDate;
  double dropLatitude = 0, dropLongitude = 0;
  String? bookingTime;
  String? bookngDat;
  String paymentType = "Cash";

  void _switchFocus() {
    if (_pickFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_dropFocusNode);
    } else {
      FocusScope.of(context).requestFocus(_pickFocusNode);
    }
  }

  @override
  void initState() {
    super.initState();
    _pickFocusNode.requestFocus();
    getUserCurrentLocation();
    // Future.delayed(Duration.zero, () {
    //   FocusScope.of(context).requestFocus(_pickFocusNode);
    // });
  }

  String lat = '';
  String long = '';
  String pincode = '';
  String _currentAddress = '';
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<void> getUserCurrentLocation() async {
    Position myPosition;
    List<Placemark> placemarks;

    bool isAllowed = await checkPermission();

    if (isAllowed) {
      try {
        // Try to get actual location
        myPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Fallback to default position (mock location)
        myPosition = Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 1.0,
          heading: 1.0,
          speed: 1.0,
          speedAccuracy: 1.0,
          altitudeAccuracy: 1.0,
          headingAccuracy: 1.0,
        );
        print("Error getting location: $e");
      }

      try {
        placemarks = await placemarkFromCoordinates(
          myPosition.latitude,
          myPosition.longitude,
        );

        print('${placemarks.first.postalCode}____________Dasdsad');

        _currentAddress =
            '${placemarks.first.name}, ${placemarks.first.subLocality}, ${placemarks.first.locality}';
        pincode = placemarks.first.postalCode ?? '';
        lat = myPosition.latitude.toString();
        long = myPosition.longitude.toString();
        pickupCon.text = _currentAddress;

        print("aajskdadajksdd $lat lng $long hffffff ${pickupCon.text}");
      } catch (e) {
        print("Error getting placemark: $e");
      }
    } else {
      // Handle permission not granted
      print("Location permission not granted.");
      // You can show a dialog/snackbar or request permission again here.
    }
  }

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable location service__');
      return false;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'please allow the location');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _geolocatorPlatform.openAppSettings();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    print(
        "asasdasd ${widget.availableLocationList!.radius} selecteinde ${widget.currentIndex}, cab stype ${widget.selectCabType}");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () async {
          if (pickupCon.text == '') {
            UI.setSnackBar("Please Select Pickup Location", context);
          } else if (dropCon.text == '') {
            UI.setSnackBar("Please Select Drop Location", context);
          } else if (widget.currentIndex == 1 && bookingDate == null) {
            UI.setSnackBar("Please Select Pickup Date", context);
          } else if (widget.currentIndex == 1 && bookingTime == null) {
            UI.setSnackBar("Please Select Pickup Time", context);
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
                  bookingDate != null
                      ? DateTime.parse(
                          '${DateFormat('yyyy-MM-dd').format(bookingDate!)} ${bookingTime}')
                      : null,
                  "",
                  widget.selectCabType.toString(),
                  '', //selectedHour
                  '', //returnDate
                  '', //returnTime
                  bookingTime: bookingTime,
                ),
              ),
            );
          }
        },
        child: Container(
          width: 300,
          height: 7.h,
          decoration:
              boxDecoration(radius: 10, bgColor: AppTheme.secondaryColor),
          child: Center(
              child: text(
                  // getTranslated(context, "CONTINUE")!,
                  "SEARCH RIDE",
                  fontFamily: fontMedium,
                  fontSize: 12.sp,
                  textColor: Colors.white)),
        ),
      ),
      appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            widget.currentIndex == 0 ? 'Current Booking' : 'Scheduled Booking',
            style: TextStyle(color: Colors.black),
          )),
      body: Column(
        children: [
          // pickup
          Container(
            // height: 60,
            // margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: EntryField(
                      node: _pickFocusNode,
                      controller: pickupCon,
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapSearchScreen()),
                        ).then((result) {
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              pickupCon.text = result['address'];
                              latitude = double.parse(result['lat'].toString());
                              longitude =
                                  double.parse(result['lng'].toString());
                            });
                          }
                        });
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Theme(
                        //       data: ThemeData(
                        //         primaryColor: Colors.red,
                        //         colorScheme: ColorScheme.light(
                        //           primary: Colors.red,
                        //           onPrimary: Colors.white,
                        //           secondary: Colors.redAccent,
                        //         ),
                        //         appBarTheme: AppBarTheme(
                        //           backgroundColor: Colors.red,
                        //           iconTheme: IconThemeData(color: Colors.white),
                        //         ),
                        //         buttonTheme: ButtonThemeData(
                        //           buttonColor: Colors.red,
                        //           textTheme: ButtonTextTheme.primary,
                        //         ),
                        //       ),
                        //       child: PlacePicker(
                        //         apiKey: Platform.isAndroid
                        //             ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                        //             : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                        //         onPlacePicked: (result) {
                        //           double selectedLat =
                        //               result.geometry!.location.lat;
                        //           double selectedLng =
                        //               result.geometry!.location.lng;
                        //           if (selectedLat == latitude &&
                        //               selectedLng == longitude) {
                        //             showLocationBottomSheet(context);
                        //             return;
                        //           }
                        //           bool isWithinRadius = calculateDistance(
                        //                   double.parse(widget
                        //                           .availableLocationList!
                        //                           .latitude ??
                        //                       ''),
                        //                   double.parse(widget
                        //                           .availableLocationList!
                        //                           .longitude ??
                        //                       ''),
                        //                   selectedLat,
                        //                   selectedLng) <
                        //               double.parse(widget
                        //                   .availableLocationList!.radius
                        //                   .toString());
                        //           if (isWithinRadius) {
                        //             setState(() {
                        //               pickupCon.text =
                        //                   result.formattedAddress.toString();
                        //               latitude = selectedLat;
                        //               longitude = selectedLng;
                        //             });
                        //             Navigator.of(context).pop();
                        //             _dropFocusNode.requestFocus();
                        //           } else {
                        //             showLocationBottomSheet(context);
                        //           }
                        //         },
                        //         initialPosition: LatLng(latitude, longitude),
                        //         useCurrentLocation: true,
                        //       ),
                        //     ),
                        //   ),
                        // );
                      },
                      label: getTranslated(context, "PICKUP_LOCATION"),
                      prefixIcon: Icons.location_on),
                ),
              ],
            ),
          ),

          // drop
          Container(
            // height: 60,
            // margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: EntryField(
                    node: _dropFocusNode,
                    controller: dropCon,
                    readOnly: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapSearchScreen(),
                        ),
                      ).then((result) {
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            dropCon.text = result['address'];
                            dropLatitude =
                                double.parse(result['lat'].toString());
                            dropLongitude =
                                double.parse(result['lng'].toString());
                          });
                        }
                      });
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Theme(
                      //       data: ThemeData(
                      //         primaryColor: Colors.red,
                      //         colorScheme: ColorScheme.light(
                      //           primary: Colors.red, // Primary color
                      //           onPrimary:
                      //               Colors.white, // Text/icon color on primary
                      //           secondary: Colors.redAccent, // Accent color
                      //         ),
                      //         appBarTheme: AppBarTheme(
                      //           backgroundColor:
                      //               Colors.red, // AppBar background color
                      //           iconTheme: IconThemeData(
                      //               color: Colors.white), // AppBar icons
                      //         ),
                      //         buttonTheme: ButtonThemeData(
                      //           buttonColor:
                      //               Colors.red, // Button background color
                      //           textTheme: ButtonTextTheme
                      //               .primary, // Button text color
                      //         ),
                      //       ),
                      //       child: PlacePicker(
                      //         apiKey: Platform.isAndroid
                      //             ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                      //             : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                      //         onPlacePicked: (result) {
                      //           double selectedLat =
                      //               result.geometry!.location.lat;
                      //           double selectedLng =
                      //               result.geometry!.location.lng;
                      //
                      //           // Check if the newly selected location is the same as the already selected one
                      //           if (selectedLat == dropLatitude &&
                      //               selectedLng == dropLongitude) {
                      //             showLocationBottomSheet(
                      //                 context); // Show bottom sheet instead of closing the map
                      //             return;
                      //           }
                      //
                      //           // Check if the selected location is within range of any available location
                      //           bool isWithinRadius = calculateDistance(
                      //                   double.parse(widget
                      //                           .availableLocationList!
                      //                           .latitude ??
                      //                       ''),
                      //                   double.parse(widget
                      //                           .availableLocationList!
                      //                           .longitude ??
                      //                       ''),
                      //                   selectedLat,
                      //                   selectedLng) <
                      //               double.parse(widget
                      //                   .availableLocationList!.radius
                      //                   .toString());
                      //           if (isWithinRadius) {
                      //             setState(() {
                      //               dropCon.text =
                      //                   result.formattedAddress.toString();
                      //               dropLatitude = selectedLat;
                      //               dropLongitude = selectedLng;
                      //             });
                      //
                      //             Navigator.of(context)
                      //                 .pop(); // Close the map only if the location is valid
                      //           } else {
                      //             showLocationBottomSheet(
                      //                 context); // Show bottom sheet instead of closing the map
                      //           }
                      //         },
                      //
                      //         // onPlacePicked: (result) {
                      //         //   print(result.formattedAddress);
                      //         //
                      //         //   setState(() {
                      //         //     dropCon.text =
                      //         //         result.formattedAddress.toString();
                      //         //     dropLatitude =
                      //         //         result.geometry!.location.lat;
                      //         //     dropLongitude =
                      //         //         result.geometry!.location.lng;
                      //         //   });
                      //         //
                      //         //   Navigator.of(context).pop();
                      //         //   // getBookInfo();
                      //         //   // getRides("3");
                      //         // },
                      //         initialPosition: dropLatitude != 0
                      //             ? LatLng(dropLatitude, dropLongitude)
                      //             : LatLng(latitude, longitude),
                      //         useCurrentLocation: true,
                      //       ),
                      //     ),
                      //   ),
                      // );
                    },
                    label: getTranslated(context, "DROP_LOCATION"),
                    prefixIcon: Icons.location_on,
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => ChooseFavoriteLocation(
                //             from: 1,
                //           ),
                //         )).then((value) {
                //       if (value != null) {
                //         dropCon.text = value[0];
                //         dropLatitude = value[1];
                //         dropLongitude = value[2];
                //         setState(() {});
                //       }
                //     });
                //   },
                //   child: Icon(
                //     Icons.favorite,
                //     color: Colors.red,
                //   ),
                // ),
                // SizedBox(
                //   width: 5,
                // )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                widget.currentIndex == 1
                    ? InkWell(
                        onTap: () async {
                          DateTime today = DateTime.now();
                          DateTime dayAfterTomorrow =
                              today.add(Duration(days: 1));

                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dayAfterTomorrow,
                            firstDate: dayAfterTomorrow,
                            lastDate: today.add(Duration(days: 14)),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor: Colors.white,
                                  colorScheme: ColorScheme.light(
                                    primary: MyColorName.primaryLite,
                                  ),
                                  dialogTheme: DialogTheme(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
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
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            print('Selected Date: $formattedDate');

                            TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dialogBackgroundColor: Colors.white,
                                    colorScheme: ColorScheme.light(
                                      primary: MyColorName.primaryLite,
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      dialBackgroundColor: Colors.white,
                                      hourMinuteTextColor:
                                          MyColorName.primaryLite,
                                      dialHandColor: MyColorName.primaryLite,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (selectedTime != null) {
                              final now = DateTime.now();
                              final selectedDateTime = DateTime(
                                bookingDate!.year,
                                bookingDate!.month,
                                bookingDate!.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );

                              final minAllowedBookingTime =
                                  now.add(Duration(hours: 24));

                              if (selectedDateTime
                                  .isBefore(minAllowedBookingTime)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "You can only book for 24 hours or more in advance."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              bookingTime = DateFormat('HH:mm:ss')
                                  .format(selectedDateTime);
                              print('Selected Time: $bookingTime');

                              setState(() {});
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: boxDecoration(
                            bgColor: Color(0xffF5F5F5),
                            radius: 8,
                            color: Color(0xffE1E1E1),
                          ),
                          height: 56,
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bookingDate == null
                                  ? Text(
                                      "Pickup Date",
                                      style: TextStyle(
                                        color: Color(0xff666666),
                                      ),
                                    )
                                  : Text(
                                      "${DateFormat('yyyy-MM-dd').format(bookingDate!)}",
                                      // "${getDate(bookingDate.toString())}",
                                      style:
                                          TextStyle(color: Color(0xff666666)),
                                    ),
                              SvgPicture.asset("assets/svg/Calendar.svg"),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                Spacer(),
                widget.currentIndex == 1
                    ? InkWell(
                        onTap: () async {
                          if (bookingDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Please select a booking date first."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor: Colors.white,
                                  colorScheme: ColorScheme.light(
                                    primary: MyColorName.primaryLite,
                                  ),
                                  timePickerTheme: TimePickerThemeData(
                                    dialBackgroundColor: Colors.white,
                                    hourMinuteTextColor:
                                        MyColorName.primaryLite,
                                    dialHandColor: MyColorName.primaryLite,
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
                            if (bookingDateTime
                                .isBefore(minAllowedBookingTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "You can only book for 24 hours or more in advance."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            bookingTime =
                                DateFormat('HH:mm:ss').format(bookingDateTime);
                            print('Selected Time: $bookingTime');
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: boxDecoration(
                            bgColor: Color(0xffF5F5F5),
                            radius: 8,
                            color: Color(0xffE1E1E1),
                          ),
                          height: 56,
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              bookingTime == null
                                  ? Text(
                                      "Pickup Time",
                                      style: TextStyle(
                                        color: Color(0xff666666),
                                      ),
                                    )
                                  : Text(
                                      "${bookingTime}",
                                      style:
                                          TextStyle(color: Color(0xff666666)),
                                    ),
                              Icon(
                                Icons.access_time_sharp,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              print('SADd${_pickFocusNode.hasFocus}');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseFavoriteLocation(
                      from: _pickFocusNode.hasFocus ? 0 : 1,
                    ),
                  )).then((value) {
                if (value != null) {
                  if (value[0] == 0) {
                    pickupCon.text = value[1];
                    FocusScope.of(context).requestFocus(_dropFocusNode);
                  } else {
                    dropCon.text = value[1];
                    dropLatitude = value[2];
                    dropLongitude = value[3];
                    setState(() {});
                  }
                }
              });
            },
            child: Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: MyColorName.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Favorite Locations',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  void showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/location_not_available.png',
                scale: 3,
              ),
              SizedBox(height: 10),
              Text(
                "Selected location is out of range!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColorName.primaryLite),
                child: Text("Got it!", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
