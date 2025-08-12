import 'package:intl/intl.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/Razorpay.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pristine_andaman/Model/plan_model.dart';

import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/common_ui.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

class PlanScreen extends StatefulWidget {
  final bool selected;
  const PlanScreen({this.selected = false});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool loading = true, network = false;
  String buyID = "";
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyPlan();
    getPlan();
  }

  Future getMyPlan() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': curUserId,
        'user_type': 'user',
      };

      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${baseUrl1}Authentication/my_current_plan"), param);
      if (response['status']) {
        Common.myPlanModel = MyPlanModel.fromJson(response['data']);
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
    setState(() {
      loading = false;
    });
  }

  List<PlanModel> planList = [];
  Future getPlan() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': curUserId,
        'type': 'user',
      };

      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${baseUrl1}Authentication/get_subscriptionplans"), param);
      planList.clear();
      if (response['status']) {
        for (var v in response['data']) {
          planList.add(PlanModel.fromJson(v));
        }
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
    setState(() {
      loading = false;
    });
  }

  Future buyPlan(String paymentId, PlanModel model) async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': curUserId,
        'user_type': 'user',
        'plan_id': model.id,
        'transaction_id': paymentId,
        'amount': model.price ?? '0',
        'payment_type': 'Razorpay',
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${baseUrl1}Authentication/plan_purchase"), param);
      if (response['status']) {
        getMyPlan();
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
    setState(() {
      buyID = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: Text("Subscriptions", style: TextStyle(fontSize: 16)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loading = true;
              });
              await getPlan();
              await getMyPlan();
            },
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  if (Common.myPlanModel != null)
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (Common.myPlanModel!.price ?? '0') + " Rs.",
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(color: Colors.white, fontSize: 20.0),
                          ),
                        ],
                      ),
                      tileColor: MyColorName.primaryDark,
                      trailing: Text(
                         (Common.myPlanModel!.type ?? '0'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                            color: Colors.white),
                      ),
                      title: Text("${Common.myPlanModel!.title}-Purchased",style: TextStyle(color: Colors.white),),
                      subtitle: Text(
                          "Ends on ${DateFormat("dd MMM yy").format(DateTime.parse(Common.myPlanModel!.endDate ?? '0000-00-00'))}",style: TextStyle(color: Colors.white),),
                    ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: planList.length,
                          padding: const EdgeInsets.all(4.0),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            PlanModel model = planList[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                      color: MyColorName.primaryDark)),
                              color: Colors.white,
                              margin: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    child: Container(
                                      height: 100,
                                      padding: const EdgeInsets.all(12.0),
                                      color: MyColorName.primaryDark,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  (model.price ?? '0') + " Rs.",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineLarge!
                                                      .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 20.0),
                                                ),
                                                Text(
                                                  " / " + (model.type ?? '0'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: UI.commonButton(
                                                title: model.title ?? '',
                                                onPressed: null,
                                                bgColor: Colors.white,
                                                fontColor:
                                                    MyColorName.primaryDark,
                                                borderColor:
                                                    MyColorName.primaryDark),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Html(
                                      data: model.description ?? "",
                                      style: {
                                        'p': Style(
                                          fontSize: FontSize(16),
                                        ),
                                        'li': Style(
                                          fontSize: FontSize(16),
                                        ),
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: Common.getWidth(50, context),
                                    child: UI.commonButton(
                                        title: "Get Started",
                                        loading: buyID == model.id,
                                        // bgColor: Colors.white,
                                        //  fontColor: MyColorName.mainColor,
                                        onPressed: () async {
                                          RazorPayHelper razorPay =
                                              new RazorPayHelper(
                                                  model.price ?? '1', context,
                                                  (result) {
                                            if (result != "error") {
                                              buyPlan(result, model);
                                            } else {
                                              setState(() {
                                                buyID = "";
                                              });
                                            }
                                          });
                                          setState(() {
                                            buyID = model.id ?? '';
                                          });
                                          razorPay.init();
                                        }),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            );
                          })),
                ],
              ),
            ),
          ),
          if (loading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
