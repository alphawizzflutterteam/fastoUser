import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pristine_andaman/Auth/Login/UI/login_page.dart';
import 'package:pristine_andaman/DrawerPages/Profile/profile_page.dart';
import 'package:pristine_andaman/DrawerPages/Rides/my_rides_page.dart';
import 'package:pristine_andaman/DrawerPages/faq_page.dart';
import 'package:pristine_andaman/DrawerPages/privacy_policy.dart';
import 'package:pristine_andaman/DrawerPages/support_screen.dart';
import 'package:pristine_andaman/DrawerPages/terms_conditions.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/new_utils/ui.dart';
import 'ReferEarn/refer_earn.dart';

class AppDrawer extends StatefulWidget {
  final bool fromHome;
  ValueChanged onResult;

  AppDrawer({this.fromHome = true, required this.onResult});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //addArray([1000, 100, 1000, 10, 100, 1, 5]);
    //getNumber();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;

  void addArray(List<int> arr) {
    int index = 0;
    int total = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i + 1 < arr.length && arr[i] < arr[i + 1] && index != i) {
        arr[i + 1] = arr[i + 1] - arr[i];
        index = i + 1;
        continue;
      } else {
        total += arr[i];
      }
    }
    print("Total = $total");
  }

  Future<void> _launchUrl(url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Shadow color
                          spreadRadius: 0, // No spread
                          blurRadius: 8, // Softness of shadow
                          offset: Offset(0, 4), // Shadow only downward
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IconButton(
                        //     icon: Icon(Icons.close),
                        //     color: Colors.white,
                        //     iconSize: 28,
                        //     onPressed: () => Navigator.pop(context)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 20, 4, 20),
                          child: Row(
                            children: [
                              Container(
                                height: 76,
                                width: 76,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(182),
                                  child: Image.network(
                                    image.toString(),
                                    height: 76,
                                    width: 76,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[
                                            300], // Placeholder background color
                                        child: Icon(
                                          Icons.person, // Avatar fallback icon
                                          size: 36,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 160,
                                    child: Text(name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium!
                                            .copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20)),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.call,
                                          color: Colors.black, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                          mobile != "" ? mobile.toString() : "",
                                          style: theme.textTheme.bodyMedium!
                                              .copyWith(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                    ],
                                  ),
                                  // SizedBox(height: 8),
                                  // Row(
                                  //   children: [
                                  //     Icon(
                                  //       Icons.edit,
                                  //       color: AppTheme.secondaryColor,
                                  //       size: 16,
                                  //     ),
                                  //     SizedBox(width: 4),
                                  //     Text(
                                  //       "Edit",
                                  //       style: TextStyle(
                                  //         fontSize: 14,
                                  //         color: AppTheme.secondaryColor,
                                  //       ),
                                  //     )
                                  //   ],
                                  // )
                                  /*   Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: AppTheme.ratingsColor,
                                    ),
                                    child: Row(
                                      children: [
                                        Text('4.2',
                                            style: TextStyle(fontSize: 12)),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          color: AppTheme.starColor,
                                          size: 10,
                                        )
                                      ],
                                    ),
                                  ),*/
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                // buildListTile(context, Icons.home, "HOME", () {
                //   if (widget.fromHome)
                //     Navigator.pop(context);
                //   else
                //     Navigator.popUntil(
                //       context,
                //       ModalRoute.withName('/'),
                //     );
                //   /*Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => SearchLocationPage()));*/
                // }),
                // buildListTile(context, Icons.person, "MY_PROFILE", () async {
                //   var result = await Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => ProfilePage()));
                //   if (result != null) {
                //     widget.onResult(result);
                //     Navigator.pop(context);
                //   }
                // }),
                buildListTile(
                    context, "assets/svg/TickSquare.svg", "My Bookings",
                    () async {
                  // Navigator.pop(context);
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRidesPage("3"),
                    ),
                  );
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),
                /*buildListTile(context, Icons.history, "INTERCITY", () async {

                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InterCityRidePage("3")));
                  if (result != null) {
                    widget.onResult(result);
                    Navigator.pop(context);
                  }
                }),*/
                // buildListTile(context, "assets/svg/Wallet.svg", "Wallet",
                //     () async {
                //   // Navigator.pop(context);
                //   var result = await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => WalletPage(),
                //     ),
                //   );
                //   if (result != null) {
                //     widget.onResult(result);
                //     Navigator.pop(context);
                //   }
                // }),
                // buildListTile(context, Icons.star, 'RATING', () async {
                //   // Navigator.pop(context);
                //   var result = await Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => ReviewsPage()),
                //   );
                //   if (result != null) {
                //     widget.onResult(result);
                //     Navigator.pop(context);
                //   }
                //   /*Navigator.popAndPushNamed(context, PageRoutes.reviewsPage);*/
                // }),
                /* buildListTile(context, Icons.local_offer, Strings.PROMO_CODE,
                        () {
                      Navigator.pop(context);
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> PromoCodePage()));
                    }),*/
                /*ListTile(
                  title: Text(
                    getTranslated(context, "RENTAL_RIDES")!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading:
                      Icon(Icons.location_on_outlined, color: Color(0xffF36B21)),
                  onTap: () async {
                    Navigator.pop(context);
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RentalRides(
                                selected: true,
                              )),
                    );

                  },
                ),*/
                // buildListTile(context, "assets/svg/Wallet.svg", "EMERGENCY_CALL", () {
                //   launch("tel://${userNumber}");
                // }),
                buildListTile(context, "assets/sos1.svg", "Sos", () {
                  if (emergencyMobile == '' && emergencyEmail == '') {
                    Fluttertoast.showToast(
                        msg:
                            'Please add emergency contact details in profile section');
                  } else {
                    sendSosRequest();
                    Navigator.pop(context);
                  }
                }),

                buildListTile(context, "assets/svg/Wallet.svg", "Refer & Earn",
                    () {
                  if (widget.fromHome)
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReferEarn()));
                  else
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReferEarn()));
                }),
                // buildListTile(context, "assets/svg/lock.svg", "Change Password",
                //     () {
                //   Navigator.pop(context);
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ChangePassword(),
                //     ),
                //   );
                // }),
                //  buildListTile(context, Icons.settings, "SETTINGS", () {
                //   Navigator.pop(context);
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => SettingsPage()));
                // }),
                buildListTile(
                    context, "assets/svg/privacypolicy.svg", "Privacy Policy",
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                  // Navigator.pop(context);
                  // _launchUrl("https://pristin.pristineandaman.com/privacy-policy");
                }),
                buildListTile(
                    context, "assets/svg/t&c.svg", "Terms and Conditions", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsConditions()));
                  // Navigator.pop(context);
                  // _launchUrl("https://pristin.pristineandaman.com/privacy-policy");
                }),
                // buildListTile(
                //     context, "assets/svg/t&c.svg", "Terms and Conditions", () {
                //   Navigator.pop(context);
                //   _launchUrl("https://pristin.pristineandaman.com/terms-conditions");
                // }),
                buildListTile(context, "assets/svg/faq.svg", "FAQS", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaqPage(),
                    ),
                  );
                }),
                buildListTile(context, "assets/svg/privacypolicy.svg",
                    "Support Management", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupportScreen(),
                    ),
                  );
                }),
                // buildListTile(
                //     context, "assets/svg/privacypolicy.svg", "Referrals", () {
                //   Navigator.pop(context);
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ReferralListScreen(),
                //     ),
                //   );
                // }),
                // buildListTile(context, Icons.logout, "LOGOUT", () {
                //   showDialog(
                //       context: context,
                //       barrierDismissible: false,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: Text(getTranslated(context, "LOGOUT")!),
                //           content: Text(getTranslated(context, "DO_LOGOUT")!),
                //           actions: <Widget>[
                //             ElevatedButton(
                //               child: Text('No'),
                //               style: ButtonStyle(
                //                 backgroundColor: MaterialStateProperty.all(
                //                     MyColorName.primaryLite),
                //               ),
                //               /*   textColor: Theme.of(context).colorScheme.primary,
                //                 shape: RoundedRectangleBorder(
                //                     side: BorderSide(color: Colors.transparent)),*/
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //             ),
                //             ElevatedButton(
                //                 child: Text('Yes'),
                //                 style: ButtonStyle(
                //                   backgroundColor: MaterialStateProperty.all(
                //                       MyColorName.primaryLite),
                //                 ),
                //                 /* shape: RoundedRectangleBorder(
                //                       side: BorderSide(color: Colors.transparent)),
                //                   textColor: Theme.of(context).colorScheme.primary,*/
                //                 onPressed: () async {
                //                   await App.init();
                //                   App.localStorage.clear();
                //                   Common.logoutApi();
                //                   //Common().toast("Logout");
                //                   Navigator.pushAndRemoveUntil(
                //                       context,
                //                       MaterialPageRoute(
                //                           builder: (context) => LoginPage()),
                //                       (route) => false);
                //                 }),
                //           ],
                //         );
                //       });
                // }),
                ListTile(
                  dense: true,
                  leading: SvgPicture.asset("assets/svg/logout.svg"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xff383838),
                    size: 20,
                  ),
                  title: Text(
                    getTranslated(context, "LOGOUT") ?? '',
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(getTranslated(context, "LOGOUT")!),
                            content: Text(getTranslated(context, "DO_LOGOUT")!),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('No'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      MyColorName.primaryLite),
                                ),
                                /*   textColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.transparent)),*/
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ElevatedButton(
                                  child: Text('Yes'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        MyColorName.primaryLite),
                                  ),
                                  /* shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.transparent)),
                                  textColor: Theme.of(context).colorScheme.primary,*/
                                  onPressed: () async {
                                    await App.init();
                                    App.localStorage.clear();
                                    Common.logoutApi();
                                    //Common().toast("Logout");
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                        (route) => false);
                                  }),
                            ],
                          );
                        });
                  },
                ),
                Divider(
                  color: Color(0xffD0D0D0),
                ),
                ListTile(
                  dense: true,
                  leading: SvgPicture.asset("assets/svg/delete.svg"),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xff383838),
                    size: 20,
                  ),
                  title: Text(
                    "Delete Account",
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Account"),
                            content: Text(
                                "Are You Sure You Wan't To Delete This Account"),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('No'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      MyColorName.primaryLite),
                                ),
                                /*   textColor: Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.transparent)),*/
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ElevatedButton(
                                  child: Text('Yes'),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        MyColorName.primaryLite),
                                  ),
                                  /* shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.transparent)),
                                      textColor: Theme.of(context).colorScheme.primary,*/
                                  onPressed: () async {
                                    deleteAccount();
                                  }),
                            ],
                          );
                        });
                  },
                ),

                // ListTile(
                //   dense: true,
                //   leading: SvgPicture.asset("assets/svg/logout.svg"),
                //   trailing: Icon(
                //     Icons.arrow_forward_ios,
                //     color: Color(0xff383838),
                //     size: 20,
                //   ),
                //   title: Text(
                //     getTranslated(context, "LOGOUT") ?? '',
                //     maxLines: 1,
                //     style: theme.textTheme.headline5!
                //         .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                //   ),
                //   onTap: () {
                //     showDialog(
                //         context: context,
                //         barrierDismissible: false,
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: Text(getTranslated(context, "LOGOUT")!),
                //             content: Text(getTranslated(context, "DO_LOGOUT")!),
                //             actions: <Widget>[
                //               ElevatedButton(
                //                 child: Text('No'),
                //                 style: ButtonStyle(
                //                   backgroundColor: MaterialStateProperty.all(
                //                       MyColorName.primaryLite),
                //                 ),
                //                 /*   textColor: Theme.of(context).colorScheme.primary,
                //                 shape: RoundedRectangleBorder(
                //                     side: BorderSide(color: Colors.transparent)),*/
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //               ElevatedButton(
                //                   child: Text('Yes'),
                //                   style: ButtonStyle(
                //                     backgroundColor: MaterialStateProperty.all(
                //                         MyColorName.primaryLite),
                //                   ),
                //                   /* shape: RoundedRectangleBorder(
                //                       side: BorderSide(color: Colors.transparent)),
                //                   textColor: Theme.of(context).colorScheme.primary,*/
                //                   onPressed: () async {
                //                     await App.init();
                //                     App.localStorage.clear();
                //                     Common.logoutApi();
                //                     //Common().toast("Logout");
                //                     Navigator.pushAndRemoveUntil(
                //                         context,
                //                         MaterialPageRoute(
                //                             builder: (context) =>
                //                                 VoiceAssistant()),
                //                         (route) => false);
                //                   }),
                //             ],
                //           );
                //         });
                //   },
                // ),

                // buildListTile(context, Icons.logout, "Delete", () {
                //   showDialog(
                //       context: context,
                //       barrierDismissible: false,
                //       builder: (BuildContext context) {
                //         return AlertDialog(
                //           title: Text(getTranslated(context, "LOGOUT")!),
                //           content: Text(getTranslated(context, "DO_LOGOUT")!),
                //           actions: <Widget>[
                //             ElevatedButton(
                //               child: Text('No'),
                //               style: ButtonStyle(
                //                 backgroundColor: MaterialStateProperty.all(
                //                     MyColorName.primaryLite),
                //               ),
                //               /*   textColor: Theme.of(context).colorScheme.primary,
                //                 shape: RoundedRectangleBorder(
                //                     side: BorderSide(color: Colors.transparent)),*/
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //             ),
                //             ElevatedButton(
                //                 child: Text('Yes'),
                //                 style: ButtonStyle(
                //                   backgroundColor: MaterialStateProperty.all(
                //                       MyColorName.primaryLite),
                //                 ),
                //                 /* shape: RoundedRectangleBorder(
                //                       side: BorderSide(color: Colors.transparent)),
                //                   textColor: Theme.of(context).colorScheme.primary,*/
                //                 onPressed: () async {
                //                   deleteAccount();
                //                 }),
                //           ],
                //         );
                //       });
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    // Get the address
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
    }
  }

  deleteAccount() async {
    var headers = {
      'Cookie': 'ci_session=75ee9527542eb2e2df46e91ccbae66763cdd828e'
    };
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://pristin.pristineandaman.com/api/Authentication/delete_user'));
    request.fields.addAll({'user_id': curUserId.toString()});
    print("User id in delete account ${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Fluttertoast.showToast(msg: "User Delete Successfully");
      App.localStorage.clear();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false);
    } else {
      print(response.reasonPhrase);
    }
  }

  buildListTile(BuildContext context, String icon, String title,
      [Function? onTap]) {
    var theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: SvgPicture.asset(icon),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Color(0xff383838),
            size: 20,
          ),
          title: Text(
            // getTranslated(context, title) ?? '',
            title,
            maxLines: 1,
            style: theme.textTheme.bodyMedium!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          onTap: onTap as void Function()?,
        ),
        Divider(
          color: Color(0xffD0D0D0),
        ),
      ],
    );
  }
}
