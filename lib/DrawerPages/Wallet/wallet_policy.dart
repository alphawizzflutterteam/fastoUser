import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pristine_andaman/Model/policy_model.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

import '../../utils/new_utils/common_ui.dart';

class WalletPolicy extends StatefulWidget {
  @override
  _WalletPolicyState createState() => _WalletPolicyState();

  const WalletPolicy();
}

class _WalletPolicyState extends State<WalletPolicy> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getRules();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  List<PolicyModel> ruleList = [];
  getRules() async {
    await App.init();
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        Map data = {
          "user_id": curUserId,
        };
        var res = await http
            .get(Uri.parse(baseUrl1 + "Authentication/wallet_request_policy"));
        print(res.body);
        Map response = jsonDecode(res.body);
        print(response);
        setState(() {
          loading = false;
        });
        if (response['status']) {
          setState(() {
            ruleList.add(PolicyModel.fromJson(response['data']));
          });
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Wallet Request Policy',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ruleList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                Common.getString1(ruleList[index].title),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: UI.commonButton(
                                        title:
                                            "Convenience Fee - \u{20B9}${ruleList[index].convenienceFee}",
                                        loading: false,
                                        fontSize: 12.0,
                                        onPressed: null),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: UI.commonButton(
                                        title:
                                            "Due Duration - ${ruleList[index].paybleMonth} Month",
                                        loading: false,
                                        fontSize: 12.0,
                                        // bgColor: Colors.white,
                                        //  fontColor: MyColorName.mainColor,
                                        onPressed: null),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                Common.getString1(
                                  ruleList[index].description,
                                ),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
          if (loading) CircularProgressIndicator(color: Colors.black),
        ],
      ),
    );
  }
}
