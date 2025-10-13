import 'dart:async';

import 'package:flutter/material.dart';

import '../Model/support_model.dart';
import '../utils/ApiBaseHelper.dart';
import '../utils/Session.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/new_utils/ui.dart';
import 'ContactUs/contact_us_page.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen();

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  ApiBaseHelper apiBase = new ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSupportList();
  }

  bool saveStatus = false;
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
  Widget build(BuildContext context) {
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
          'Support',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColorName.primaryLite,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactUsPage(),
            ),
          ).then((value) {
            getSupportList();
          });
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            saveStatus
                ? SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.black)))
                : supportList.isEmpty
                    ? SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(child: Text('No Data Found')))
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: supportList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Card(
                              elevation: 5,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            supportList[index].status == '0'
                                                ? 'Open'
                                                : 'Close',
                                            style: TextStyle(
                                              color:
                                                  supportList[index].status ==
                                                          '0'
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Name'),
                                          Text(
                                            '${supportList[index].name}',
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
                                            '${supportList[index].email}',
                                            style: TextStyle(
                                                color: MyColorName.textColor),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Description'),
                                          Text(
                                            '${supportList[index].description}',
                                            style: TextStyle(
                                                color: MyColorName.textColor),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () {
                                            // Check if replyMessage is null or empty
                                            List<String> replies = [];
                                            bool hasReplies = supportList[index]
                                                        .replyMessage !=
                                                    null &&
                                                supportList[index]
                                                    .replyMessage!
                                                    .isNotEmpty;

                                            if (hasReplies) {
                                              replies = supportList[index]
                                                  .replyMessage!
                                                  .split('|');
                                            }

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Replies'),
                                                  content: hasReplies
                                                      ? Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: replies
                                                              .map((reply) =>
                                                                  ListTile(
                                                                    title: Text(
                                                                        'msg : ${reply}'),
                                                                  ))
                                                              .toList(),
                                                        )
                                                      : Text('No Replies'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Close'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('View Reply'),
                                        ),
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
