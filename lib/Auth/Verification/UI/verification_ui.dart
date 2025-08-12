import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pristine_andaman/bottom_nav_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:pristine_andaman/BookRide/search_location_page.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

import '../../../Components/auth_bg.dart';
import '../../../utils/colors.dart';
import '../../../utils/widget.dart';
import '../../Registration/UI/registration_ui.dart';
import 'verification_interactor.dart';

class VerificationUI extends StatefulWidget {
  final VerificationInteractor verificationInteractor;
  String mobile, otp;
  bool? isRegister;
  VerificationUI(this.verificationInteractor, this.mobile, this.otp,
      {this.isRegister});

  @override
  _VerificationUIState createState() => _VerificationUIState();
}

class _VerificationUIState extends State<VerificationUI> {
  final TextEditingController _otpController = TextEditingController();

  // @override
  // void dispose() {
  //   super.dispose();
  //   // _otpController.dispose();
  // }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Scaffold(
        //backgroundColor: Colors.white,
        // appBar: AppBar(
        //   leading: InkWell(
        //       onTap: () {
        //         Navigator.pop(context);
        //       },
        //       child: Icon(
        //         Icons.arrow_back_ios_new,
        //         color: Colors.black,
        //       )),
        //   elevation: 0,
        //   centerTitle: true,
        //   backgroundColor: Colors.white,
        //   title: Text(
        //     "OTP VERIFICATION",
        //     style: TextStyle(
        //         fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        //   ),
        // ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // AuthBg(),
                SizedBox(height: 142,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/splashLogo.png",
                      scale: 1.5,//4
                      // height: 80,
                    ),
                    // SizedBox(width: 12),
                    // Text(
                    //   "Pristine\nAndaman",
                    //   style: TextStyle(
                    //       fontSize: 28, color: AppTheme.primaryColor),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Enter 4 digit verification code sent to your phone number',textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,),
                ),
                SizedBox(height: 10),
                Text(
                  'An 4 digit OTP has been sent to',
                  style: TextStyle(fontSize: 16, color: MyColorName.textColor),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.mobile}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.otp}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    keyboardType: TextInputType.number,
                    controller: _otpController,
                    validator: (value) {
                      if (value!.length < 4) {
                        return "otp length must be 4";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: MyColorName.lightGrey,
                      disabledColor: MyColorName.lightGrey,
                      activeColor: MyColorName.lightGrey,
                      inactiveColor: MyColorName.lightGrey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    loginWithMobile();
                  },
                  child: Center(
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      )

                    // CustomButton(
                    //   onTap: () {},
                    //   text: "Resend Otp",
                    //   color: Colors.white,
                    //   textColor: AppTheme.primaryColor,
                    // ),
                  ),
                ),
                SizedBox(height: 10,),
                !loading
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_otpController.text == "" ||
                                _otpController.text.length != 4) {
                              UI.setSnackBar("Please Enter Valid Otp", context);
                              return;
                            }
                            if (_otpController.text != widget.otp) {
                              UI.setSnackBar("Wrong Otp", context);
                              return;
                            }
                            if (widget.isRegister == false) {
                              navigateScreen(context,
                                  RegistrationUI(widget.mobile, "", ""));
                            } else {
                              setState(() {
                                loading = true;
                              });
                              loginUser();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: !loading
                                ? text('VERIFY OTP',
                                    // getTranslated(context, "CONTINUE")!,
                                    fontFamily: fontMedium,
                                    fontSize: 12.sp,
                                    textColor: Colors.white)
                                : CircularProgressIndicator(
                                    color: Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        width: 50,
                        child: Center(child: CircularProgressIndicator())),
                SizedBox(
                  height: 10,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  loginWithMobile() async {
    loading = true;
    setState(() {});
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        print("temp = $tempRefer");
        Map data;
        data = {
          "user_phone": widget.mobile,
          "fcm_id": fcmToken.toString(),
        };
        print("login with mobile $data");
        Map response =
            await apiBase.postAPICall(Uri.parse(baseUrl + "user_login"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        if (response['status']) {
          UI.setSnackBar('Resend Otp Successfully', context,
              color: Colors.green);
          App.localStorage
              .setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          print("OTP ==== ${response['data']['otp'].toString()}");
          widget.otp = response['data']['otp'].toString();
          setState(() {});
        } else {
          UI.setSnackBar('Something went wrong', context, color: Colors.red);
        }
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = false;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = false;
      });
    }
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;
  loginUser() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_phone": widget.mobile.trim().toString(),
          "otp": widget.otp.toString(),
        };
        print('PrintData:_____${data}______');
        Map response =
            await apiBase.postAPICall(Uri.parse(baseUrl + "login"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        if (response['status']) {
          UI.setSnackBar(msg, context, color: Colors.green);

          App.localStorage
              .setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BottomNavScreen()));
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => SearchLocationPage()));
          // Navigator.popAndPushNamed(context, "/");
          //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        } else {
          UI.setSnackBar(
            msg,
            context,
          );
        }
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = false;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = false;
      });
    }
  }
}
