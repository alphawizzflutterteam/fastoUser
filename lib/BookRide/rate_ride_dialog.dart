import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/Locale/locale.dart';
import 'package:pristine_andaman/Locale/strings_enum.dart';
import 'package:pristine_andaman/Model/intercity_model.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

import '../bottom_nav_screen.dart';

class RateRideDialog extends StatefulWidget {
  MyRideModel model;
  bool check, from;
  RateRideDialog(this.model, {this.check = false, this.from = false});
  @override
  _RateRideDialogState createState() => _RateRideDialogState();
}

class _RateRideDialogState extends State<RateRideDialog> {
  double rating = 0.0;
  String paymentType = "";
  getWallet() async {
    try {
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.getAPICall(
        Uri.parse(baseUrl1 + "users/getWallet/${curUserId}"),
      );

      if (response['status']) {
        var data = response["transactions"];

        print(data);
        walletAmount = double.parse(response['amount'].toString());
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWallet();
  }

  TextEditingController desCon = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Dialog(
      child: WillPopScope(
        onWillPop: () async {
          if (!widget.check) {
            Navigator.popUntil(
              context,
              ModalRoute.withName('/'),
            );
          } else {
            Navigator.pop(context);
          }

          /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SearchLocationPage()),
              (route) => false);*/
          // return Future.value();
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /*Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/'),
                        );
                        */
                /*Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchLocationPage()),
                          (route) => false);*/ /*
                      },
                    ),
                  ),
                ),*/
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.model.driverImage.toString(),
                                  height: 72,
                                  width: 72,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${widget.model.driverName}',
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(fontSize: 18, letterSpacing: 1.2),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${widget.model.taxiType}',
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(fontSize: 12),
                            ),
                            Text(
                              '${widget.model.car_no}',
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, 'RIDE_FARE')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 18),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\u{20B9} ${widget.model.finalAmount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            SizedBox(height: 24),
                            Text(
                              getTranslated(context, 'PAYMENT_VIA')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 18),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  paymentType != ""
                                      ? '${paymentType}'
                                      : "${widget.model.transaction}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text(
                    getTranslated(context, 'RIDE_INFO')!,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.hintColor, fontSize: 16.5),
                  ),
                  trailing: Text('${widget.model.km} km',
                      style: theme.textTheme.bodyMedium),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                  ),
                  title: Text(
                    '${widget.model.pickupAddress}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.navigation,
                    color: theme.primaryColor,
                  ),
                  title: Text(
                    '${widget.model.dropAddress}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                !widget.model.transaction.toString().contains("Wait") ||
                        paymentType != ""
                    ? Column(
                        children: [
                          Center(
                            child: Text(
                                getTranslated(context, 'RATE_YOUR_RIDE')!,
                                style: theme.textTheme.bodyMedium!
                                    .copyWith(color: theme.hintColor)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: RatingBar(
                              initialRating: rating,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 36,
                              ratingWidget: RatingWidget(
                                full: Icon(
                                  Icons.star,
                                  color: AppTheme.primaryColor,
                                ),
                                half: Icon(
                                  Icons.star_half_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                                empty: Icon(
                                  Icons.star_border_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              itemPadding: EdgeInsets.zero,
                              onRatingUpdate: (rating1) {
                                print(rating1);
                                setState(() {
                                  rating = rating1;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          EntryField(
                            controller: desCon,
                            hint: getTranslated(context, 'ADD_COMMENT'),
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(
                  height: 20,
                ),
                !widget.check
                    ? Container(
                        color: theme.colorScheme.background,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 52,
                        child: Row(
                          children: [
                            Text(
                              "Select " +
                                  getTranslated(context, "PAYMENT_MODE")!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 13.5,
                                  ),
                            ),
                            Spacer(),
                            Container(
                              width: 1,
                              height: 28,
                              color: theme.hintColor,
                            ),
                            Spacer(),
                            PopupMenuButton(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    paymentType != "" ? paymentType : "Select",
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                        color: theme.primaryColor,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              onSelected: (val) {
                                setState(() {
                                  paymentType = val.toString();
                                  status = false;
                                });
                              },
                              offset: Offset(0, -144),
                              color: theme.colorScheme.background,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: getString(Strings.CASH)!,
                                    child: Row(
                                      children: [
                                        Icon(Icons.credit_card_sharp),
                                        SizedBox(width: 12),
                                        Text(getTranslated(context, 'CASH')!),
                                      ],
                                    ),
                                  ),
                                  // PopupMenuItem(
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(Icons.account_balance_wallet),
                                  //       SizedBox(width: 12),
                                  //       Text(getTranslated(context, 'WALLET')!),
                                  //     ],
                                  //   ),
                                  //   value: getString(Strings.WALLET)!,
                                  // ),
                                  // PopupMenuItem(
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(Icons.account_balance_wallet),
                                  //       SizedBox(width: 12),
                                  //       Text("Online"),
                                  //     ],
                                  //   ),
                                  //   value: "Online",
                                  // ),
                                ];
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 20,
                ),
                !status
                    ? CustomButton(
                        onTap: () {
                          if (!widget.check && paymentType == "") {
                            Common().toast("Select Payment Method");
                            // UI.setSnackBar("Select Payment Method", context);
                            return;
                          }
                          if (!widget.check &&
                              paymentType == "Wallet" &&
                              walletAmount <
                                  double.parse(widget.model.amount!)) {
                            Common().toast("Insufficient Balance");
                            //UI.setSnackBar("Insufficient Balance", context);
                            return;
                          }
                          setState(() {
                            status = true;
                          });
                          // if (paymentType == "Online") {
                          //   KhaltiPayHelper khaltiPay = new KhaltiPayHelper(
                          //       widget.model.amount!, context, (result) {
                          //     if (result != "error") {
                          //       rateOrder(widget.model.driverId,
                          //           widget.model.bookingId);
                          //     } else {
                          //       setState(() {
                          //         status = false;
                          //       });
                          //     }
                          //   });
                          //   setState(() {
                          //     status = true;
                          //   });
                          //   khaltiPay.init();
                          // } else {
                          //   rateOrder(
                          //       widget.model.driverId, widget.model.bookingId);
                          // }
                        },
                        textColor: Colors.white,
                        text: widget.check
                            ? getTranslated(context, 'SUBMIT')
                            : "Pay \u{20B9}${widget.model.finalAmount}",
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool status = false;
  rateOrder(driverId, bookingId) async {
    await App.init();
    Map param = {
      "driver_id": driverId,
      "comments": desCon.text == "" ? "No Comments" : desCon.text,
      "booking_id": bookingId,
      "rating": rating.toString(),
      "user_id": curUserId,
      // "payment_type": paymentType,
    };
    if (!widget.check) {
      param['payment_type'] = paymentType;
    }
    Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "payment/AddReviews"), param);
    setState(() {
      status = false;
    });
    if (response['status']) {
      if (!widget.check) {
        UI.setSnackBar(response['message'], context, color: Colors.green);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BottomNavScreen()));

        // if (widget.from) {
        //   Navigator.pop(context, true);
        // } else {
        //   Navigator.popUntil(
        //     context,
        //     ModalRoute.withName('/'),
        //   );
        // }
      } else {
        UI.setSnackBar(response['message'], context);

        Navigator.pop(context);
      }
    }
  }
}

class RateRideDialog1 extends StatefulWidget {
  IntercityRideModel model;

  RateRideDialog1(this.model);
  @override
  _RateRideDialog1State createState() => _RateRideDialog1State();
}

class _RateRideDialog1State extends State<RateRideDialog1> {
  double rating = 0.0;
  TextEditingController desCon = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imagePath + widget.model.driverImage.toString(),
                                height: 72,
                                width: 72,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${widget.model.driverName}',
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 18, letterSpacing: 1.2),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${widget.model.taxiType}',
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 12),
                          ),
                          Text(
                            '${widget.model.car_no}',
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, 'RIDE_FARE')!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\u{20B9} ${widget.model.amount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          SizedBox(height: 24),
                          Text(
                            getTranslated(context, 'PAYMENT_VIA')!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 18),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('${widget.model.transaction}')
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: Text(
                  getTranslated(context, 'RIDE_INFO')!,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.hintColor, fontSize: 16.5),
                ),
                trailing: Text('${widget.model.km} km',
                    style: theme.textTheme.bodyMedium),
              ),
              ListTile(
                horizontalTitleGap: 0,
                leading: Icon(
                  Icons.location_on,
                  color: theme.primaryColor,
                ),
                title: Text(
                  '${widget.model.pickupAddress}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                horizontalTitleGap: 0,
                leading: Icon(
                  Icons.navigation,
                  color: theme.primaryColor,
                ),
                title: Text(
                  '${widget.model.dropAddress}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(getTranslated(context, 'RATE_YOUR_RIDE')!,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.hintColor)),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: RatingBar(
                  initialRating: rating,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 36,
                  ratingWidget: RatingWidget(
                    full: Icon(
                      Icons.star,
                      color: AppTheme.primaryColor,
                    ),
                    half: Icon(
                      Icons.star_half_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    empty: Icon(
                      Icons.star_border_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  itemPadding: EdgeInsets.zero,
                  onRatingUpdate: (rating1) {
                    print(rating1);
                    setState(() {
                      rating = rating1;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              EntryField(
                controller: desCon,
                hint: getTranslated(context, 'ADD_COMMENT'),
              ),
              SizedBox(
                height: 20,
              ),
              !status
                  ? CustomButton(
                      onTap: () {
                        setState(() {
                          status = true;
                        });
                        rateOrder(
                            widget.model.driverId, widget.model.bookingId);
                      },
                      text: getTranslated(context, 'SUBMIT'),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool status = false;
  rateOrder(driverId, bookingId) async {
    await App.init();
    Map param = {
      "driver_id": driverId,
      "comments": desCon.text == "" ? "No Comments" : desCon.text,
      "booking_id": bookingId,
      "rating": rating.toString(),
      "user_id": curUserId,
    };
    Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "payment/AddReviews"), param);
    setState(() {
      status = false;
    });
    UI.setSnackBar(response['message'], context);
    if (response['status']) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNavScreen()));
      // Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(builder: (context) => SearchLocationPage()),
      //         (route) => false);
      // Navigator.popUntil(
      //   context,
      //   ModalRoute.withName('/'),
      // );
    }
  }
}
