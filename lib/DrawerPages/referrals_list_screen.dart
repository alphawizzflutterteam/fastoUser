import 'dart:async';

import 'package:flutter/material.dart';

import '../Model/referral_model.dart';
import '../utils/ApiBaseHelper.dart';
import '../utils/Session.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/new_utils/ui.dart';

class ReferralListScreen extends StatefulWidget {
  const ReferralListScreen();

  @override
  State<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends State<ReferralListScreen> {
  ApiBaseHelper apiBase = new ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReferralList();
  }

  bool saveStatus = false;
  List<ReferralData> referralList = [];
  getReferralList() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "referral_code": refer,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Authentication/my_referrals"), params);

      referralList = (response['data'] as List)
          .map((e) => ReferralData.fromJson(e))
          .toList();
      print('lenght--->${referralList.length}');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Referrals',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            saveStatus
                ? SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.black)))
                : referralList.isEmpty
                    ? SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(child: Text('No Data Found')))
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: referralList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Card(
                              elevation: 5,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Name'),
                                          Text(
                                            '${referralList[index].username}',
                                            style: TextStyle(
                                                color: MyColorName.textColor),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Email'),
                                          Text(
                                            '${referralList[index].email}',
                                            style: TextStyle(
                                                color: MyColorName.textColor),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Mobile'),
                                          Text(
                                            '${referralList[index].mobile}',
                                            style: TextStyle(
                                                color: MyColorName.textColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
          ],
        ),
      ),
    );
  }
}
