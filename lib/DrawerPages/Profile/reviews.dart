import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pristine_andaman/Model/review_model.dart';
import 'package:pristine_andaman/Routes/page_routes.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

import '../../Theme/style.dart';

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = true;
  List<ReviewModel> reviewList = [];
  String path = "";
  getReview(type) async {
    try {
      setState(() {
        loading = true;
      });
      Map params = {
        "user_id": curUserId,
        "type": type,
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "Payment/get_user_review"), params);
      setState(() {
        loading = false;
        reviewList.clear();
      });
      if (response['status']) {
        print(response['data']);
        for (var v in response['data']) {
          setState(() {
            reviewList.add(ReviewModel.fromJson(v));
          });
        }
        path = response['image_path'];
        print(path + reviewList[0].userImage.toString());
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar("Something Went Wrong", context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReview("1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //drawer: AppDrawer(false),
      appBar: AppBar(
        title: Text(
          getTranslated(context, "RATING") ?? "My Rating",
        ),
      ),
      body: ListView(
        children: [
          /*   Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                getString(Strings.CURRENT_RATINGS)!.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 18),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppTheme.ratingsColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rating,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(fontSize: 24),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: AppTheme.starColor,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '${reviewList.length} ' + getString(Strings.PEOPLE_RATED)!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Theme.of(context).hintColor),
                  )
                ],
              ),
            ),*/
          SizedBox(
            height: 30,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              "Recent Rating",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          !loading
              ? reviewList.length > 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviewList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, PageRoutes.rideInfoPage),
                        child: Container(
                          decoration:
                              boxDecoration(radius: 10, showShadow: true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: getWidth(80),
                                        height: getWidth(80),
                                        child: Image.network(
                                          path +
                                              reviewList[index]
                                                  .userImage
                                                  .toString(),
                                          width: getWidth(80),
                                          height: getWidth(80),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reviewList[index].username.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          getDate1(reviewList[index].time),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: AppTheme.ratingsColor,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                reviewList[index]
                                                    .rating
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(fontSize: 14),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.star,
                                                color: AppTheme.starColor,
                                                size: 14,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 16, bottom: 12),
                                color: Theme.of(context).colorScheme.background,
                                child: Text(
                                  reviewList[index].comment.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: text("No Review",
                          fontFamily: fontMedium,
                          fontSize: 12.sp,
                          textColor: Colors.black),
                    )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
