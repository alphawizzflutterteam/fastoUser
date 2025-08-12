import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

import '../../Model/support_model.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController _controller = TextEditingController();
  ApiBaseHelper apiBase = new ApiBaseHelper();
  double totalBal = 0;
  double minimumBal = 0;
  bool isNetwork = false;
  bool saveStatus = false;
  addContact() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": curUserId.toString(),
        "email": email.toString(),
        "name": name.toString(),
        "description": _controller.text.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Contact/contact_email"), params);
      setState(() {
        saveStatus = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context);
        back(context);
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

  List<SupportData> supportList = [];
  getSupportList() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Contact/get_support_lists"), params);

      supportList = (response['data'] as List)
          .map((e) => SupportData.fromJson(e))
          .toList();
      print('lenght--->${supportList.length}');
      setState(() {
        saveStatus = false;
      });
      // if (response['status']) {
      //   UI.setSnackBar(response['message'], context);
      //   back(context);
      // } else {
      //   UI.setSnackBar(response['message'], context);
      // }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getSupportList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Support Management',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      // drawer: AppDrawer(false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SizedBox(height: 32),
            // Row(
            //    children: [
            //      Expanded(
            //        child: CustomButton(
            //          icon: Icons.call,
            //          text: context.getString(Strings.CALL_US),
            //          color: theme.cardColor,
            //          textColor: theme.primaryColor,
            //        ),
            //      ),
            //      Expanded(
            //        child: CustomButton(
            //          icon: Icons.email,
            //          text: context.getString(Strings.EMAIL_US),
            //        ),
            //      ),
            //    ],
            //  ),
            // SizedBox(height: 20),
            // EntryField(
            //   label: "Email ID",
            //   initialValue: contactEmail,
            //   readOnly: true,
            // ),
            // SizedBox(height: 20),
            // EntryField(
            //   label: "Contact No.",
            //   initialValue: contactNo,
            //   readOnly: true,
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: Text(
                getTranslated(context, 'WRITE_US')!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                getTranslated(context, 'DESC_YOUR_ISSUE')!,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.hintColor),
              ),
            ),
            SizedBox(height: 20),
            EntryField(
              label: getTranslated(context, 'YOUR_EMAIL'),
              initialValue: email,
              readOnly: true,
            ),
            SizedBox(height: 20),
            EntryField(
              controller: _controller,
              label: getTranslated(context, 'DESC_YOUR_ISSUE')!,
            ),

            // ListView.builder(
            //   shrinkWrap: true,
            //   itemCount: supportList.length,
            //   itemBuilder: (context, index) {
            //     return Padding(
            //       padding: const EdgeInsets.only(left: 12,right: 12),
            //       child: Card(
            //         elevation: 5,
            //         child: Container(
            //           child: Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Name'),
            //                     Text('${supportList[index].name}',style: TextStyle(color:MyColorName.textColor),),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Email'),
            //                     Text('${supportList[index].email}',style: TextStyle(color:MyColorName.textColor),),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Text('Description'),
            //                     Text('${supportList[index].description}',style: TextStyle(color:MyColorName.textColor),),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // )
          ],
        ),
      ),
      bottomNavigationBar: !saveStatus
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                textColor: Colors.white,
                text: getTranslated(context, 'SUBMIT'),
                onTap: () {
                  if (_controller.text == "") {
                    UI.setSnackBar(
                        getTranslated(context, "FILL_DESC")!, context);
                    return;
                  }
                  addContact();
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
