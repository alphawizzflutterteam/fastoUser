import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pristine_andaman/DrawerPages/Settings/rules.dart';
import 'package:pristine_andaman/Locale/strings_enum.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';

class FAQs {
  final Strings title;
  final Strings subtitle;

  FAQs(this.title, this.subtitle);
}

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
    getFaq();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  List<RuleModel> ruleList = [];
  getFaq() async {
    await App.init();
    isNetwork = await isNetworkAvailable();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "user_id": curUserId,
        };
        var res = await http.get(Uri.parse(baseUrl + "needhelp"));
        Map response = jsonDecode(res.body);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        if (response['status']) {
          for (var v in response['need_help']) {
            setState(() {
              ruleList
                  .add(new RuleModel(v['id'], v['title'], v['description']));
            });
          }
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
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
          getTranslated(context, "FAQS") ?? "FAQs",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),

      //drawer: AppDrawer(false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                getTranslated(context, 'READ_FAQS')!,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.hintColor),
              ),
            ),
            SizedBox(height: 20),
            ruleList.length > 0
                ? Container(
                    color: theme.colorScheme.background,
                    padding: EdgeInsets.only(top: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ruleList.length,
                      itemBuilder: (context, index) => Container(
                        decoration: boxDecoration(radius: 10, showShadow: true),
                        margin: EdgeInsets.all(getWidth(10)),
                        child: ExpansionTile(
                          tilePadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          title: Text(
                            getString1(ruleList[index].title),
                            style: theme.textTheme.bodyMedium,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                getString1(ruleList[index].description),
                              ),
                            )
                          ],
                          expandedAlignment: Alignment.centerLeft,
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ],
        ),
      ),
    );
  }
}
