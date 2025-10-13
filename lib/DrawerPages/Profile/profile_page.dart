import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

import '../../bottom_nav_screen.dart';

class ProfilePage extends StatefulWidget {
  bool? fromWhere;

  ProfilePage({this.fromWhere});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController mobileCon = TextEditingController();
  TextEditingController emerMobileCon = TextEditingController();
  TextEditingController genderCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController emerEmailCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  TextEditingController emerNameCon = TextEditingController();
  TextEditingController dobCon = TextEditingController();
  TextEditingController passCon = TextEditingController();
  List<String> gender = ["Male", "Female", "Other"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  DateTime startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2023));
    if (picked != null) {
      setState(() {
        startDate = picked;
        dobCon.text = DateFormat("yyyy-MM-dd").format(startDate);
      });
    }
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? persistentBottomSheetController1;

  showBottom1() async {
    persistentBottomSheetController1 =
        await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        decoration:
            boxDecoration(radius: 0, showShadow: true, color: Colors.white),
        padding: EdgeInsets.all(getWidth(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            boxHeight(20),
            text(getTranslated(context, "SELECT_GENDER")!,
                textColor: MyColorName.colorTextPrimary,
                fontSize: 12.sp,
                fontFamily: fontBold),
            boxHeight(20),
            Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: gender.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        persistentBottomSheetController1!.setState!(() {
                          genderCon.text = gender[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: genderCon.text == gender[index]
                            ? MyColorName.primaryLite.withOpacity(0.2)
                            : Colors.white,
                        padding: EdgeInsets.all(getWidth(10)),
                        child: text(gender[index].toString(),
                            textColor: MyColorName.colorTextPrimary,
                            fontSize: 10.sp,
                            fontFamily: fontMedium),
                      ),
                    );
                  }),
            ),
            boxHeight(40),
          ],
        ),
      );
    });
  }

  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> ProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
        maxHeight: 400);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  Future<void> ProfileImage1() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 400,
        maxHeight: 400);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  imagePick() {
    return Container(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                ProfileImage1();
              },
              child: const Row(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Camera",
                    style: TextStyle(fontSize: 19),
                  ),
                ],
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                ProfileImage();
              },
              child: Row(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    "assets/users/gallery.png",
                    height: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Gallery",
                    style: TextStyle(fontSize: 19),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !loading
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: CustomButton(
                  padding: EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.secondaryColor,
                  text: getTranslated(context, 'UPDATE'),
                  textColor: Colors.white,
                  onTap: () {
                    if (mobileCon.text == "" || mobileCon.text.length != 10) {
                      UI.setSnackBar(
                          "Please Enter Valid Mobile Number", context);
                      return;
                    }
                    if (validateField(nameCon.text, "Please Enter Full Name") !=
                        null) {
                      UI.setSnackBar("Please Enter Full Name", context);
                      return;
                    }
                    if (emailCon.text != "" &&
                        validateEmail(
                                emailCon.text,
                                getTranslated(context, "VALID_EMAIL")!,
                                getTranslated(context, "VALID_EMAIL")!) !=
                            null) {
                      UI.setSnackBar(
                          validateEmail(
                                  emailCon.text,
                                  getTranslated(context, "VALID_EMAIL")!,
                                  getTranslated(context, "VALID_EMAIL")!)
                              .toString(),
                          context);
                      return;
                    }
                    if (emerMobileCon.text.length > 0 &&
                        emerMobileCon.text.length != 10) {
                      UI.setSnackBar(
                          "Please Enter Valid Emergency Mobile Number",
                          context);
                      return;
                    }
                    if (emerEmailCon.text.length > 0 &&
                        validateEmail(
                                emerEmailCon.text,
                                getTranslated(context, "VALID_EMAIL")!,
                                getTranslated(context, "VALID_EMAIL")!) !=
                            null) {
                      UI.setSnackBar(
                          validateEmail(
                                  emerEmailCon.text,
                                  getTranslated(context, "VALID_EMAIL")!,
                                  getTranslated(context, "VALID_EMAIL")!)
                              .toString(),
                          context);
                      return;
                    }
                    // if (validateField(
                    //         genderCon.text, "Please Enter Gender") !=
                    //     null) {
                    //   UI.setSnackBar("Please Enter Gender", context);
                    //   return;
                    // }
                    // if (validateField(
                    //         dobCon.text, "Please Enter Date Of Birth") !=
                    //     null) {
                    //   UI.setSnackBar("Please Enter Date Of Birth", context);
                    //   return;
                    // }
                    // if (passCon.text == "" || passCon.text.length < 8) {
                    //   UI.setSnackBar(
                    //       getTranslated(context, "ENTER_PASSWORD")!,
                    //       context);
                    //   return;
                    // }
                    /*if (_image == null) {
                                UI.setSnackBar("Please Upload Photo", context);
                                return;
                              }*/
                    setState(() {
                      loading = true;
                    });
                    submitSubscription();
                  },
                ),
              ),
            )
          : Container(
              width: 50,
              height: 50,
              child: Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
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
          getTranslated(context, "MY_PROFILE") ?? "My Profile",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            // Padding(
            //   padding:
            //       EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            //   child: Text(
            //     getTranslated(context, 'YOUR_ACCOUNT_DETAILS')!,
            //     style: theme.textTheme.bodyText2!
            //         .copyWith(color: theme.hintColor, fontSize: 12),
            //   ),
            // ),
            // SizedBox(
            //   height: 60,
            // ),
            InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => imagePick(),
                  );
                  // requestPermission(context);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Picture Container
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: theme.hintColor,
                        borderRadius: BorderRadius.circular(182),
                        border: Border.all(
                          color: Colors.black, // border color
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(182),
                        child: _image == null
                            ? Image.network(
                                image,
                                height: 150,
                                width: 150,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                _image!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                    // Positioned Camera Icon
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                )),

            SizedBox(
              height: 10,
            ),
            Container(
              width: 160,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            EntryField(
              //  initialValue: name.toString(),
              controller: nameCon,
              keyboardType: TextInputType.name,
              label: getTranslated(context, 'FULL_NAME'),
              prefixIcon: Icons.person,
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              //initialValue: email.toString(),
              controller: emailCon,
              label: getTranslated(context, 'EMAIL_ADD'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              label: getTranslated(context, 'ENTER_PHONE'),
              // initialValue: mobile.toString(),
              controller: mobileCon,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.call,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Emergency Contact',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Poppins'),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 16,
            ),
            EntryField(
              //  initialValue: name.toString(),
              controller: emerNameCon,
              keyboardType: TextInputType.name,
              label: getTranslated(context, 'FULL_NAME'),
              prefixIcon: Icons.person,
            ),
            SizedBox(
              height: 10,
            ),
            EntryField(
              //initialValue: email.toString(),
              controller: emerEmailCon,
              label: getTranslated(context, 'EMAIL_ADD'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(
              height: 10,
            ),

            EntryField(
              label: getTranslated(context, 'ENTER_PHONE'),
              // initialValue: mobile.toString(),
              controller: emerMobileCon,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.call,
            ),

            SizedBox(
              height: 90,
            ),
            // gender.length > 0
            //     ? EntryField(
            //         maxLength: 10,
            //         readOnly: true,
            //         controller: genderCon,
            //         onTap: () {
            //           showBottom1();
            //         },
            //         label: getTranslated(context, "GENDER")!,
            //       )
            //     : SizedBox(),
            // EntryField(
            //   label: getTranslated(context, "DOB")!,
            //   controller: dobCon,
            //   readOnly: true,
            //   onTap: () {
            //     selectDate(context);
            //   },
            //   keyboardType: TextInputType.emailAddress,
            // ),
            /*  EntryField(
                            //  initialValue: name.toString(),
                            controller: passCon,
                            keyboardType: TextInputType.visiblePassword,
                            label: "Password",
                            obscureText: true,
                          ),*/
          ],
        ),
      ),
      // Stack(
      //   alignment: Alignment.bottomCenter,
      //   children: [
      //     SingleChildScrollView(
      //       child: Container(
      //         height: MediaQuery.of(context).size.height + 200,
      //         child: Stack(
      //           children: [
      //
      //             PositionedDirectional(
      //               top: 30,
      //               start: MediaQuery.of(context).size.width / 3 - 15,
      //               child: InkWell(
      //                 onTap: () {
      //                   showModalBottomSheet(
      //                     context: context,
      //                     builder: (context) => imagePick(),
      //                   );
      //                   // requestPermission(context);
      //                 },
      //                 child: Container(
      //                   height: 150,
      //                   width: 150,
      //                   decoration: BoxDecoration(
      //                     color: theme.hintColor,
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   alignment: Alignment.center,
      //                   child: ClipRRect(
      //                     borderRadius: BorderRadius.circular(10),
      //                     child: _image == null
      //                         ? Image.network(
      //                             image,
      //                             height: 150,
      //                             width: 150,
      //                             fit: BoxFit.fill,
      //                           )
      //                         : Image.file(
      //                             _image!,
      //                             height: 150,
      //                             width: 150,
      //                             fit: BoxFit.fill,
      //                           ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //     PositionedDirectional(
      //       start: 0,
      //       end: 0,
      //       child: !loading
      //           ? Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 16),
      //               child: CustomButton(
      //                 padding: EdgeInsets.all(16),
      //                 borderRadius: BorderRadius.circular(10),
      //                 color: AppTheme.secondaryColor,
      //                 text: getTranslated(context, 'UPDATE'),
      //                 textColor: Colors.white,
      //                 onTap: () {
      //                   if (mobileCon.text == "" ||
      //                       mobileCon.text.length != 10) {
      //                     UI.setSnackBar(
      //                         "Please Enter Valid Mobile Number", context);
      //                     return;
      //                   }
      //                   if (validateField(
      //                           nameCon.text, "Please Enter Full Name") !=
      //                       null) {
      //                     UI.setSnackBar("Please Enter Full Name", context);
      //                     return;
      //                   }
      //                   if (emailCon.text != "" &&
      //                       validateEmail(
      //                               emailCon.text,
      //                               getTranslated(context, "VALID_EMAIL")!,
      //                               getTranslated(context, "VALID_EMAIL")!) !=
      //                           null) {
      //                     UI.setSnackBar(
      //                         validateEmail(
      //                                 emailCon.text,
      //                                 getTranslated(context, "VALID_EMAIL")!,
      //                                 getTranslated(context, "VALID_EMAIL")!)
      //                             .toString(),
      //                         context);
      //                     return;
      //                   }
      //                   // if (validateField(
      //                   //         genderCon.text, "Please Enter Gender") !=
      //                   //     null) {
      //                   //   UI.setSnackBar("Please Enter Gender", context);
      //                   //   return;
      //                   // }
      //                   // if (validateField(
      //                   //         dobCon.text, "Please Enter Date Of Birth") !=
      //                   //     null) {
      //                   //   UI.setSnackBar("Please Enter Date Of Birth", context);
      //                   //   return;
      //                   // }
      //                   // if (passCon.text == "" || passCon.text.length < 8) {
      //                   //   UI.setSnackBar(
      //                   //       getTranslated(context, "ENTER_PASSWORD")!,
      //                   //       context);
      //                   //   return;
      //                   // }
      //                   /*if (_image == null) {
      //                       UI.setSnackBar("Please Upload Photo", context);
      //                       return;
      //                     }*/
      //                   setState(() {
      //                     loading = true;
      //                   });
      //                   submitSubscription();
      //                 },
      //               ),
      //             )
      //           : Container(
      //               width: 50,
      //               height: 50,
      //               child: Center(
      //                 child: CircularProgressIndicator(color:Colors.black),
      //               ),
      //             ),
      //     ),
      //   ],
      // ),
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;

  Future<void> submitSubscription() async {
    await App.init();

    ///MultiPart request
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(baseUrl1 + "Authentication/update_userprofile"),
        );
        Map<String, String> headers = {
          "token": App.localStorage.getString("token").toString(),
          "Content-type": "multipart/form-data"
        };
        if (_image != null) {
          request.files.add(
            http.MultipartFile(
              'user_image',
              _image!.readAsBytes().asStream(),
              _image!.lengthSync(),
              filename: path.basename(_image!.path),
              contentType: MediaType('image', 'jpeg,png'),
            ),
          );
          print("ok");
        }
        request.headers.addAll(headers);
        request.fields.addAll({
          "gender": genderCon.text,
          "dob": dobCon.text,
          "password": passCon.text,
          "user_id": curUserId.toString(),
          "user_fullname": nameCon.text,
          "user_phone": mobileCon.text,
          "user_email": emailCon.text.trim().toString(),
          'emergency_name': emerNameCon.text,
          'emergency_mobile': emerMobileCon.text,
          'emergency_gmail': emerEmailCon.text,
        });
        print("request: " + request.toString());
        var res = await request.send();
        print("This is response:" + res.toString());
        setState(() {
          loading = false;
        });
        print(res.statusCode);
        if (res.statusCode == 200) {
          final respStr = await res.stream.bytesToString();
          print(respStr.toString());
          Map data = jsonDecode(respStr.toString());
          if (data['status']) {
            // Navigator.popUntil(
            //   context,
            //   ModalRoute.withName('/'),
            // );
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavScreen()),
                (route) => false);
            UI.setSnackBar(data['message'].toString(), context);
          } else {
            UI.setSnackBar(data['message'].toString(), context);
          }
        }
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = true;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = true;
      });
    }
  }

  getProfile() async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response =
          await apiBase.postAPICall(Uri.parse(baseUrl + "get_profile"), params);

      if (response['status']) {
        var data = response["data"];
        print(data);
        setState(() {
          name = data['username'];
          mobile = data['mobile'];
          email = data['email'];
          gender1 = data['gender'].toString() ?? "";
          points = double.parse(data['point_value']);
          image = response['image_path'].toString() +
                  data['user_image'].toString() ??
              "";
          imagePath = response['image_path'].toString();
          isFirstUser = response['first_order'] ?? '';
          mobileCon.text = mobile;
          emailCon.text = email;
          nameCon.text = name;
          dobCon.text = dob;
          passCon.text = password;
          genderCon.text = gender1;
          emerMobileCon.text = emergencyMobile;
          emerEmailCon.text = emergencyEmail;
          emerNameCon.text = emergencyName;
        });
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }
}
