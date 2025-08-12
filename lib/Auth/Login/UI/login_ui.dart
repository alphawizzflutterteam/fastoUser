import 'dart:async';
import 'dart:ffi';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pristine_andaman/Auth/Registration/UI/registration_page.dart';
import 'package:pristine_andaman/Auth/Registration/UI/registration_ui.dart';
import 'package:pristine_andaman/Auth/Verification/UI/verification_page.dart';
import 'package:pristine_andaman/Auth/login_navigator.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/colors.dart';
import '../../../utils/widget.dart';
import 'login_interactor.dart';

class LoginUI extends StatefulWidget {
  final LoginInteractor loginInteractor;

  LoginUI(this.loginInteractor);

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final TextEditingController _numberController = TextEditingController();
  TextEditingController emailCon = new TextEditingController();
  TextEditingController passCon = new TextEditingController();
  String isoCode = '';
  bool otpOnOff = false;
  dynamic choose = "pass";
  bool obscure = true;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedRadio = 1;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height,
                //   decoration: BoxDecoration(
                //     color: AppTheme.secondaryColor,
                //   ),
                // child: Align(
                //   alignment: Alignment.bottomCenter,
                //   child: GestureDetector(
                //       onTap: () {
                //         navigateScreen(context, RegistrationUI("", "", ""));
                //       },
                //       child: Padding(
                //         padding: const EdgeInsets.only(bottom: 40.0),
                //         child: Text(
                //           'Don’t have an account? Sign Up',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       )),
                // ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: (MediaQuery.of(context).size.height) / 1.0,//past 1.5
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover, // responsive full screen
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 110,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/splashLogo.png',
                            scale: 1.5,
                          )
                          // SizedBox(width: 10),
                          // Text(
                          //   "Pristine\nAndaman",
                          //   style: TextStyle(
                          //       fontSize: 28, color: AppTheme.primaryColor),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) - 45,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /*Text(
                              'Enter your 1',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                             */
                            _selectedRadio == 1
                                ? Text('Login to Your Account',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500))
                                : Text('Email Address',
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500)),
                            // _selectedRadio == 1
                            //     ? Text('We will send you a confirmation code')
                            //     : Text('Enter the below fields'),

                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: RadioListTile(
                            //         title: Text(
                            //           'Mobile',
                            //           style: TextStyle(fontSize: 14),
                            //         ),
                            //         value: 1,
                            //         activeColor: AppTheme.primaryColor,
                            //         contentPadding: EdgeInsets.zero,
                            //         visualDensity:
                            //             VisualDensity(horizontal: -4.0),
                            //         groupValue: _selectedRadio,
                            //         onChanged: (value) {
                            //           setState(() {
                            //             _selectedRadio = value as int;
                            //           });
                            //         },
                            //       ),
                            //     ),
                            //     Expanded(
                            //       child: RadioListTile(
                            //         title: Text(
                            //           'Email',
                            //           style: TextStyle(fontSize: 14),
                            //         ),
                            //         value: 2,
                            //         activeColor: AppTheme.primaryColor,
                            //         visualDensity:
                            //             VisualDensity(horizontal: -4.0),
                            //         contentPadding: EdgeInsets.zero,
                            //         groupValue: _selectedRadio,
                            //         onChanged: (value) {
                            //           setState(() {
                            //             _selectedRadio = value as int;
                            //           });
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            SizedBox(
                              height: 24,
                            ),
                            //Text("+91"),
                            if (_selectedRadio == 1)
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _numberController,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Number';
                                  } else if (value.length < 10) {
                                    return "Please enter valid number";
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  fillColor: MyColorName.colorBg1,
                                  isDense: true,
                                  hintText: "Enter Number",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    margin: EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: MyColorName.colorBg1,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                      ),
                                      border: Border.all(width: 2,color: MyColorName.greyBorder)
                                    ),
                                    child: Text(
                                      '+91',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            if (_selectedRadio == 2) ...[
                              CustomTextField(
                                HintText: 'Enter Email',
                                controller: _emailController,
                                keyboardtype: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                controller: _passwordController,
                                keyboardtype: TextInputType.visiblePassword,
                                isObscured: obscure,
                                HintText: "Password",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'min length must be 8';
                                  }
                                  return null;
                                },
                                suffixicon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (obscure) {
                                        obscure = false;
                                      } else {
                                        obscure = true;
                                      }
                                    });
                                  },
                                  icon: obscure
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                ),
                              ),
                            ],
                            SizedBox(
                              height: 20,
                            ),
                            _selectedRadio == 2
                                ? SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_emailController.text == "") {
                                          UI.setSnackBar(
                                              "Please Enter Valid Mobile Number",
                                              context);
                                          return;
                                        }
                                        if (_passwordController.text == "") {
                                          UI.setSnackBar(
                                              "Please Enter Password", context);
                                          return;
                                        }
                                        setState(() {
                                          loading = true;
                                        });
                                        loginUser();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.secondaryColor,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Center(
                                        child: !loading
                                            ? text("LOGIN",
                                                // getTranslated(context, "CONTINUE")!,
                                                fontFamily: fontMedium,
                                                fontSize: 12.sp,
                                                textColor: Colors.white)
                                            : CircularProgressIndicator(
                                                color: Colors.white),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // if(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!)!=null){
                                        //   UI.setSnackBar(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!).toString(), context);
                                        //   return;
                                        // }
                                        if (_numberController.text == "" ||
                                            _numberController.text.length !=
                                                10) {
                                          UI.setSnackBar(
                                              "Please Enter Valid Mobile Number",
                                              context);
                                          return;
                                        }

                                        setState(() {
                                          loading = true;
                                        });
                                        loginWithMobile();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.secondaryColor,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Center(
                                        child: !loading
                                            ? text("SEND OTP",
                                                // getTranslated(context, "CONTINUE")!,
                                                fontFamily: fontMedium,
                                                fontSize: 12.sp,
                                                textColor: Colors.white)
                                            : CircularProgressIndicator(
                                                color: Colors.white),
                                      ),
                                    ),
                                  ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 24),
                                  child: Row(
                                    children: [
                                      Text(
                                            "Don't have account? ",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight
                                                .w500),),
                                      InkWell(
                                        onTap: () {

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                      RegisterPage(null)));
                                        },
                                        child: Text(
                                          "Create Account",
                                          // 'Login',
                                          style: TextStyle(
                                              color: AppTheme.secondaryColor,
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight
                                                  .w500),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    //   Scaffold(
    //   body: SingleChildScrollView(
    //     child: Stack(
    //       alignment: Alignment.center,
    //       children: [
    //         AuthBg(),
    //         Padding(
    //           padding: EdgeInsets.only(
    //             left: 16,
    //             right: 16,
    //             top: 48,
    //           ),
    //           child: Card(
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(20),
    //             ),
    //             elevation: 8,
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(
    //                   horizontal: 16.0, vertical: 40),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     'Enter phone number\n& password',
    //                     style: TextStyle(
    //                       fontSize: 24,
    //                       fontWeight: FontWeight.w900,
    //                       color: Colors.black,
    //                     ),
    //                   ),
    //                   // SizedBox(height: 12),
    //                   // Text(
    //                   //   'We will send you a confirmation code',
    //                   //   style: TextStyle(
    //                   //     fontSize: 14,
    //                   //     fontWeight: FontWeight.w600,
    //                   //     color: Colors.black54,
    //                   //   ),
    //                   // ),
    //                   SizedBox(height: 24),
    //
    //                   // mobile field
    //                   TextFormField(
    //                     controller: _numberController,
    //                     decoration: InputDecoration(
    //                       hintText: getTranslated(context, 'ENTER_PHONE'),
    //                       hintStyle:
    //                           TextStyle(color: Color(0xff666666), fontSize: 14),
    //                       fillColor: Color(0xfff5f5f5),
    //                       contentPadding: EdgeInsets.symmetric(
    //                           vertical: 16, horizontal: 12),
    //                       border: OutlineInputBorder(
    //                         borderSide: BorderSide(color: Color(0xffe1e1e1)),
    //                         borderRadius: BorderRadius.circular(8),
    //                       ),
    //                     ),
    //                     keyboardType: TextInputType.phone,
    //                     // maxLength: 10,
    //                   ),
    //
    //                   SizedBox(height: 10),
    //
    //                   // pass field
    //                   TextFormField(
    //                     controller: passCon,
    //                     keyboardType: TextInputType.visiblePassword,
    //                     obscureText: obscure,
    //                     decoration: InputDecoration(
    //                       suffixIcon: IconButton(
    //                         icon: Icon(
    //                           obscure ? Icons.visibility : Icons.visibility_off,
    //                           color: Color(0xff666666),
    //                           size: 20,
    //                         ),
    //                         onPressed: () {
    //                           setState(() {
    //                             obscure = !obscure;
    //                           });
    //                         },
    //                       ),
    //                       hintText: getTranslated(context, "PASSWORD")!,
    //                       hintStyle:
    //                           TextStyle(color: Color(0xff666666), fontSize: 14),
    //                       fillColor: Color(0xfff5f5f5),
    //                       contentPadding: EdgeInsets.symmetric(
    //                           vertical: 16, horizontal: 12),
    //                       border: OutlineInputBorder(
    //                         borderSide: BorderSide(color: Color(0xffe1e1e1)),
    //                         borderRadius: BorderRadius.circular(8),
    //                       ),
    //                     ),
    //                     // maxLength: 10,
    //                   ),
    //
    //                   SizedBox(height: 24),
    //
    //                   SizedBox(
    //                     width: double.infinity,
    //                     child: ElevatedButton(
    //                       onPressed: () async {
    //                         // if(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!)!=null){
    //                         //   UI.setSnackBar(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!).toString(), context);
    //                         //   return;
    //                         // }
    //                         if (_numberController.text == "" ||
    //                             _numberController.text.length != 10) {
    //                           UI.setSnackBar(
    //                               "Please Enter Valid Mobile Number", context);
    //                           return;
    //                         }
    //                         if (passCon.text == "" || passCon.text.length < 5) {
    //                           UI.setSnackBar(
    //                               getTranslated(context, "ENTER_PASSWORD")!,
    //                               context);
    //                           return;
    //                         }
    //                         setState(() {
    //                           loading = true;
    //                         });
    //                         loginUser();
    //                       },
    //                       style: ElevatedButton.styleFrom(
    //                         backgroundColor: AppTheme.secondaryColor,
    //                         padding: EdgeInsets.symmetric(vertical: 16),
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                       ),
    //                       child: Center(
    //                         child: !loading
    //                             ? text("LOGIN",
    //                                 // getTranslated(context, "CONTINUE")!,
    //                                 fontFamily: fontMedium,
    //                                 fontSize: 12.sp,
    //                                 textColor: Colors.white)
    //                             : CircularProgressIndicator(
    //                                 color: Colors.white),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //
    //           // Container(
    //           //   height: 600,
    //           //   child: Column(
    //           //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //           //     children: [
    //           //       Spacer(flex: 2),
    //           //       Padding(
    //           //         padding: EdgeInsets.symmetric(horizontal: 24),
    //           //         child: Text(
    //           //             getTranslated(context, 'ENTER_YOUR')! +
    //           //                 '\n' +
    //           //                 "Mobile Number and Password",
    //           //             style: theme.textTheme.headline4!
    //           //                 .copyWith(fontSize: 20, color: Colors.white)),
    //           //       ),
    //           //       Spacer(),
    //           //       Container(
    //           //         height: MediaQuery.of(context).size.height * 0.7,
    //           //         color: theme.backgroundColor,
    //           //         child: Column(
    //           //           crossAxisAlignment: CrossAxisAlignment.center,
    //           //           children: [
    //           //             Spacer(),
    //           //             // chooseType(),
    //           //             // EntryField(
    //           //             //   controller: emailCon,
    //           //             //   keyboardType: TextInputType.emailAddress,
    //           //             //   label: getTranslated(context,'EMAIL_ADD'),
    //           //             // ),
    //           //             EntryField(
    //           //               maxLength: 10,
    //           //               keyboardType: TextInputType.phone,
    //           //               controller: _numberController,
    //           //               label: getTranslated(context, 'ENTER_PHONE'),
    //           //             ),
    //           //             EntryField(
    //           //               //  initialValue: name.toString(),
    //           //               controller: passCon,
    //           //               keyboardType: TextInputType.visiblePassword,
    //           //               label: getTranslated(context, "PASSWORD")!,
    //           //               obscureText: obscure,
    //           //               suffixIcon: IconButton(
    //           //                 icon: Icon(
    //           //                   obscure
    //           //                       ? Icons.visibility
    //           //                       : Icons.visibility_off,
    //           //                   color: MyColorName.primaryLite,
    //           //                 ),
    //           //                 onPressed: () {
    //           //                   setState(() {
    //           //                     obscure = !obscure;
    //           //                   });
    //           //                 },
    //           //               ),
    //           //             ),
    //           //             Row(
    //           //               mainAxisAlignment: MainAxisAlignment.end,
    //           //               children: [
    //           //                 InkWell(
    //           //                   onTap: () {
    //           //                     navigateScreen(context, ForgetScreen());
    //           //                   },
    //           //                   child: Padding(
    //           //                     padding: const EdgeInsets.symmetric(
    //           //                         horizontal: 15.0, vertical: 5),
    //           //                     child: text(
    //           //                         getTranslated(context, "FORGOT")!,
    //           //                         fontFamily: fontMedium,
    //           //                         fontSize: 12.sp,
    //           //                         textColor: Colors.black),
    //           //                   ),
    //           //                 ),
    //           //               ],
    //           //             ),
    //           //             Spacer(flex: 1),
    //           //             Padding(
    //           //               padding: const EdgeInsets.only(
    //           //                   left: 12.0, right: 12),
    //           //               child: Row(
    //           //                 mainAxisAlignment:
    //           //                 MainAxisAlignment.spaceBetween,
    //           //                 children: [
    //           //                   InkWell(
    //           //                     onTap: () async {
    //           //                       // if(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!)!=null){
    //           //                       //   UI.setSnackBar(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!).toString(), context);
    //           //                       //   return;
    //           //                       // }
    //           //                       if (_numberController.text == "" ||
    //           //                           _numberController.text.length !=
    //           //                               10) {
    //           //                         UI.setSnackBar(
    //           //                             "Please Enter Valid Mobile Number",
    //           //                             context);
    //           //                         return;
    //           //                       }
    //           //                       if (passCon.text == "" ||
    //           //                           passCon.text.length < 5) {
    //           //                         UI.setSnackBar(
    //           //                             getTranslated(
    //           //                                 context, "ENTER_PASSWORD")!,
    //           //                             context);
    //           //                         return;
    //           //                       }
    //           //                       setState(() {
    //           //                         loading = true;
    //           //                       });
    //           //                       loginUser();
    //           //                     },
    //           //                     child: Container(
    //           //                       width: 50.w - 30,
    //           //                       height: 6.h,
    //           //                       decoration: boxDecoration(
    //           //                           radius: 10,
    //           //                           bgColor:
    //           //                           Theme.of(context).primaryColor),
    //           //                       child: Center(
    //           //                           child: !loading
    //           //                               ? text("LOGIN",
    //           //                               // getTranslated(context, "CONTINUE")!,
    //           //                               fontFamily: fontMedium,
    //           //                               fontSize: 12.sp,
    //           //                               textColor: Colors.white)
    //           //                               : CircularProgressIndicator()),
    //           //                     ),
    //           //                   ),
    //           //                   InkWell(
    //           //                     onTap: () async {
    //           //                       navigateScreen(context,
    //           //                           RegistrationUI("", "", ""));
    //           //                     },
    //           //                     child: Container(
    //           //                       width: 50.w - 30,
    //           //                       height: 6.h,
    //           //                       decoration: boxDecoration(
    //           //                           radius: 10,
    //           //                           bgColor:
    //           //                           Theme.of(context).primaryColor),
    //           //                       child: Center(
    //           //                           child: !loading
    //           //                               ? text("REGISTER",
    //           //                               // getTranslated(context, "CONTINUE")!,
    //           //                               fontFamily: fontMedium,
    //           //                               fontSize: 12.sp,
    //           //                               textColor: Colors.white)
    //           //                               : CircularProgressIndicator()),
    //           //                     ),
    //           //                   ),
    //           //                 ],
    //           //               ),
    //           //             ),
    //           //             Spacer(flex: 1),
    //           //           ],
    //           //         ),
    //           //       ),
    //           //     ],
    //           //   ),
    //           // ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.only(top: 680),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 "Don’t have an account? ",
    //                 style: TextStyle(
    //                     fontWeight: FontWeight.w600, color: Colors.white),
    //               ),
    //               InkWell(
    //                 onTap: () async {
    //                   navigateScreen(context, RegistrationUI("", "", ""));
    //                 },
    //                 child: Text(
    //                   "Sign Up",
    //                   style: TextStyle(
    //                     fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget chooseType() {
    return Row(
      children: [
        Row(
          children: [
            Radio(
                value: "pass",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                  });
                }),
            Text(getTranslated(context, "EMAIL")!),
          ],
        ),
        Row(
          children: [
            Radio(
                value: "otp",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                    otpOnOff = true;
                  });
                }),
            Text(getTranslated(context, "MOBILE")!),
          ],
        )
      ],
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;

  loginUser() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        print("temp = $tempRefer");
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}');
        Map data;
        data = {
          "user_email": _emailController.text.toString(),
          "pass": _passwordController.text,
          "fcm_id": fcmToken.toString(),
          "device_id": androidInfo.id.toString(),
        };
        print("login with email and password $data");
        Map response =
            await apiBase.postAPICall(Uri.parse(baseUrl + "userlogin"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        UI.setSnackBar(msg, context);
        if (response['status']) {
          App.localStorage
              .setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          Navigator.popAndPushNamed(context, "/");
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        } else {}
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

  loginWithMobile() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        print("temp = $tempRefer");
        Map data;
        data = {
          "user_phone": _numberController.text.trim().toString(),
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
          UI.setSnackBar(msg, context, color: Colors.green);
          App.localStorage
              .setString("userId", response['data']['id'].toString());
          curUserId = response['data']['id'].toString();
          print("OTP ==== ${response['data']['otp'].toString()}");
          print("heeer reponse ${response}");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationPage(
                _numberController.text.trim().toString(),
                response['data']['otp'].toString(),
                isRegister: response['is_registered'],
              ),
            ),
          );
        } else {
          UI.setSnackBar(msg, context, color: Colors.red);
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

  // loginFb() async {
  //   await App.init();
  //   isNetwork = await isNetworkAvailable();
  //   if (isNetwork) {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();
  //     print("login out fun");
  //     UserCredential data = await signInWithFacebook();
  //     print("login fun");
  //     print(data.additionalUserInfo!.profile.toString());
  //     print(data.user!.uid);
  //     var newData = data.additionalUserInfo!.profile;
  //     String myName = newData!["given_name"].toString();
  //     String myEmail = newData["email"].toString();
  //     Map params = {
  //       "name": myName,
  //       "email": myEmail,
  //       "app_id": packageName,
  //       "google_login": "1",
  //     };
  //     var response = await apiBase.postAPICall(
  //         Uri.parse(baseUrl + "social_login"), params);
  //     setState(() {
  //       selected = !selected;
  //     });
  //     bool error = response["error"];
  //     String? msg = response["message"];
  //     UI.setSnackBar("Google Login Successfully", context);
  //     if (!error) {
  //     } else {}
  //   } else {
  //     UI.setSnackBar("No Internet", context);
  //   }
  // }

  GoogleSignIn googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>[
      'email',
    ],
  );
  bool selected = true;

  googleLogin() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();
      print("login out fun");
      UserCredential data = await signInWithGoogle();
      print("login fun");
      print(data.additionalUserInfo!.profile.toString());
      print(data.user!.uid);
      var newData = data.additionalUserInfo!.profile;
      String myName = newData!["given_name"].toString();
      String myEmail = newData["email"].toString();
      Map params = {
        "name": myName,
        "email": myEmail,
        "app_id": packageName,
        "google_login": "1",
      };
      var response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/social_login"), params);
      setState(() {
        selected = !selected;
      });
      bool error = response["status"];
      String? msg = response["message"];

      if (error) {
        UI.setSnackBar("Google Login Successfully", context);
        App.localStorage
            .setString("userId", response['data'][0]['id'].toString());
        curUserId = response['data'][0]['id'].toString();
        Navigator.popAndPushNamed(context, "/");
        //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
      } else {
        navigateScreen(context, RegistrationUI("", myName, myEmail));
      }
    } else {
      UI.setSnackBar("No Internet", context);
    }
  }

  // final fbLogin = FacebookLogin();
  final _firebaseAuth = FirebaseAuth.instance;

  // Future<UserCredential> signInWithFacebook() async {
  //   final fb = FacebookLogin();
  //   final response = await fb.logIn(permissions: [
  //     FacebookPermission.publicProfile,
  //     FacebookPermission.email,
  //   ]);
  //   switch (response.status) {
  //     case FacebookLoginStatus.success:
  //       final accessToken = response.accessToken;
  //       final userCredential = await _firebaseAuth.signInWithCredential(
  //         FacebookAuthProvider.credential(accessToken!.token),
  //       );
  //       return userCredential;
  //     case FacebookLoginStatus.cancel:
  //       throw FirebaseAuthException(
  //         code: 'ERROR_ABORTED_BY_USER',
  //         message: 'Sign in aborted by user',
  //       );
  //     case FacebookLoginStatus.error:
  //       throw FirebaseAuthException(
  //         code: 'ERROR_FACEBOOK_LOGIN_FAILED',
  //         message: response.error!.developerMessage!,
  //       );
  //     default:
  //       throw UnimplementedError();
  //   }
  // }

/*   Future signInFB() async {
    final FacebookLoginResult result = await fbLogin.logIn(["email","public_profile"]);
    print(result.errorMessage);
    print(result.status);
    print(result.accessToken);
    final String token = result.accessToken!.token;
    final response = await     get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}'));
    final profile = jsonDecode(response.body);
    print(profile);
    return profile;
  }*/

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    print(googleAuth?.idToken);
    // Once signed in, return the UserCredential
    var data = await FirebaseAuth.instance.signInWithCredential(credential);
    return data;
  }
}

// child: Column(
//   crossAxisAlignment: CrossAxisAlignment.stretch,
//   children: [
//     Spacer(flex: 2),
//     Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24),
//       child: Text(
//           getTranslated(context, 'ENTER_YOUR')! +
//               '\n' +
//               "Mobile Number and Password",
//           style: theme.textTheme.headline4!.copyWith(fontSize: 20,color: Colors.white)),
//     ),
//     Spacer(),
//     Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       color: theme.backgroundColor,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Spacer(),
//           // chooseType(),
//           // EntryField(
//           //   controller: emailCon,
//           //   keyboardType: TextInputType.emailAddress,
//           //   label: getTranslated(context,'EMAIL_ADD'),
//           // ),
//           EntryField(
//             maxLength: 10,
//             keyboardType: TextInputType.phone,
//             controller: _numberController,
//             label: getTranslated(context, 'ENTER_PHONE'),
//           ),
//           EntryField(
//             //  initialValue: name.toString(),
//             controller: passCon,
//             keyboardType: TextInputType.visiblePassword,
//             label: getTranslated(context, "PASSWORD")!,
//             obscureText: obscure,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 obscure ? Icons.visibility : Icons.visibility_off,
//                 color: MyColorName.primaryLite,
//               ),
//               onPressed: () {
//                 setState(() {
//                   obscure = !obscure;
//                 });
//               },
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               InkWell(
//                 onTap: () {
//                   navigateScreen(context, ForgetScreen());
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 15.0, vertical: 5),
//                   child: text(getTranslated(context, "FORGOT")!,
//                       fontFamily: fontMedium,
//                       fontSize: 12.sp,
//                       textColor: Colors.black),
//                 ),
//               ),
//             ],
//           ),
//           Spacer(flex: 1),
//           Padding(
//             padding: const EdgeInsets.only(left: 12.0, right: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: () async {
//                     // if(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!)!=null){
//                     //   UI.setSnackBar(validateEmail(emailCon.text, getTranslated(context, "VALID_EMAIL")!,getTranslated(context, "VALID_EMAIL")!).toString(), context);
//                     //   return;
//                     // }
//                     if (_numberController.text == "" ||
//                         _numberController.text.length != 10) {
//                       UI.setSnackBar(
//                           "Please Enter Valid Mobile Number",
//                           context);
//                       return;
//                     }
//                     if (passCon.text == "" ||
//                         passCon.text.length < 5) {
//                       UI.setSnackBar(
//                           getTranslated(context, "ENTER_PASSWORD")!,
//                           context);
//                       return;
//                     }
//                     setState(() {
//                       loading = true;
//                     });
//                     loginUser();
//                   },
//                   child: Container(
//                     width: 50.w - 30,
//                     height: 6.h,
//                     decoration: boxDecoration(
//                         radius: 10,
//                         bgColor: Theme.of(context).primaryColor),
//                     child: Center(
//                         child: !loading
//                             ? text("LOGIN",
//                                 // getTranslated(context, "CONTINUE")!,
//                                 fontFamily: fontMedium,
//                                 fontSize: 12.sp,
//                                 textColor: Colors.white)
//                             : CircularProgressIndicator()),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     navigateScreen(
//                         context, RegistrationUI("", "", ""));
//                   },
//                   child: Container(
//                     width: 50.w - 30,
//                     height: 6.h,
//                     decoration: boxDecoration(
//                         radius: 10,
//                         bgColor: Theme.of(context).primaryColor),
//                     child: Center(
//                         child: !loading
//                             ? text("REGISTER",
//                                 // getTranslated(context, "CONTINUE")!,
//                                 fontFamily: fontMedium,
//                                 fontSize: 12.sp,
//                                 textColor: Colors.white)
//                             : CircularProgressIndicator()),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Spacer(flex: 1),
//          /* Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               boxWidth(40),
//               Expanded(child: Divider()),
//               boxWidth(10),
//               text(getTranslated(context, "OR")!,
//                   fontFamily: fontMedium,
//                   fontSize: 12.sp,
//                   textColor: Colors.black),
//               boxWidth(10),
//               Expanded(child: Divider()),
//               boxWidth(40),
//             ],
//           ),*/
//           Spacer(flex: 1),
//          /* Container(
//             child: Row(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     loginFb();
//                   },
//                   child: Image.asset(
//                     "assets/fb.png",
//                     width: 8.h,
//                     height: 8.h,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 5.w,
//                 ),
//                 InkWell(
//                   onTap: () {
//                     googleLogin();
//                   },
//                   child: Image.asset(
//                     "assets/google.png",
//                     width: 8.h,
//                     height: 8.h,
//                   ),
//                 ),
//               ],
//             ),
//           ),*/
//           Spacer(flex: 1),
//           // InkWell(
//           //   onTap: (){
//           //     navigateScreen(
//           //         context, RegistrationUI("","",""));
//           //   },
//           //   child: Padding(
//           //     padding: const EdgeInsets.symmetric(horizontal:15.0,vertical: 5),
//           //     child: Row(
//           //       mainAxisAlignment: MainAxisAlignment.center,
//           //       children: [
//           //         text(getTranslated(context, "ACCOUNT")!,
//           //             fontFamily: fontMedium,
//           //             fontSize: 12.sp,
//           //             textColor: Colors.black),
//           //         text(getTranslated(context, "REGISTER")!,
//           //             fontFamily: fontMedium,
//           //             fontSize: 12.sp,
//           //             under: true,
//           //             textColor: Colors.black),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           Spacer(flex: 1),
//           /*      !loading
//               ? CustomButton(
//                   onTap: () {
//                     if (_numberController.text == "" ||
//                         _numberController.text.length != 10) {
//                       UI.setSnackBar(
//                           "Please Enter Valid Mobile Number",
//                           context);
//                       return;
//                     }
//                     setState(() {
//                       loading = true;
//                     });
//                     loginUser();
//                   },
//                 )
//               : Container(
//                   width: 50,
//                   child:
//                       Center(child: CircularProgressIndicator())),*/
//         ],
//       ),
//     ),
//   ],
// )

class CustomTextField extends StatefulWidget {
  final String? HintText;
  final TextInputType? keyboardtype;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool? isObscured;
  final Widget? suffixicon;

  CustomTextField(
      {this.suffixicon,
      this.isObscured,
      this.validator,
      this.controller,
      this.HintText,
      this.keyboardtype});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        obscureText: widget.isObscured ?? false,
        keyboardType: widget.keyboardtype,
        controller: widget.controller,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          isDense: true,
          suffixIcon: widget.suffixicon,
          hintText: widget.HintText,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
