import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Assets/assets.dart';
import '../Auth/Login/UI/login_page.dart';
import '../BookRide/search_location_page.dart';
import '../bottom_nav_screen.dart';
import 'WelcomeScreen.dart';
import 'common.dart';
import 'constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double value = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    determinateIndicator();
    navigateToHome();
  }

  void determinateIndicator() {
    Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        if (value > 1) {
          print(value);
          timer.cancel();
          width = 80.w;
        } else {
          value = value + 0.05;
        }
      });
    });
  }

  navigateToHome() async {
    Timer(Duration(seconds: 3), () async {
      print('userid----->  ${App.localStorage.getString("userId")}');
      if (App.localStorage.getString("userId") != null) {
        curUserId = App.localStorage.getString("userId").toString();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SearchLocationPage(),
        //   ),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavScreen(),
          ),
        );
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => WelComeScreen()));
      } else {
        print("ccccccccsssssssssssssss ${App.localStorage.getBool("first")}");
        if (App.localStorage.getBool("first") != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        } else {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => WelComeScreen(),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        }
      }
    });
  }

  double width = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity, // make it full screen
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover, // responsive full screen
            ),
          ),

          //height: 200,
          //width: 300,
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage('assets/images/milksplash.png'),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          child: Center(
            child: Image.asset(
              Assets.splashLogo,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      // bottomNavigationBar:
    );
  }

  Future<void> _launchUrl(url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Widget privacyPolicyLinkAndTermsOfService() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Text.rich(
          TextSpan(
              text: 'By continuing, you agree to our\n',
              style: TextStyle(fontSize: 16, color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff722BEA),
                      decorationColor: Color(0xff722BEA),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("jhghaghh");
                        _launchUrl("https://idho.in/terms-conditions/");
                        // code to open / launch terms of service link here
                      }),
                TextSpan(
                    text: 'and ',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xff722BEA),
                              decorationColor: Color(0xff722BEA),
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchUrl(
                                  "https://idho.in/privacy-policy-for-users/");
                              // code to open / launch privacy policy link here
                            })
                    ])
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
