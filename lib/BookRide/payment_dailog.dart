import 'package:flutter/material.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/row_item.dart';
import 'package:pristine_andaman/Locale/locale.dart';
import 'package:pristine_andaman/Locale/strings_enum.dart';
import 'package:pristine_andaman/Model/my_ride_model.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/colors.dart';
import 'package:pristine_andaman/utils/common.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

class PaymentDialog extends StatefulWidget {
  MyRideModel model;
  final bool from;
  PaymentDialog(this.model, {this.from = false});
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  double rating = 0.0;
  TextEditingController desCon = new TextEditingController();
  String paymentType = "Cash";
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
              Divider(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                child: Row(
                  children: [
                    RowItem(
                        'Extra Payment',
                        '\u{20B9}${widget.model.add_on_charge}',
                        Icons.account_balance_wallet),
                    Spacer(),
                    RowItem('Extra Time', ' ${widget.model.add_on_time}/min.',
                        Icons.timer),
                    Spacer(),
                    RowItem('Extra KM', '${widget.model.add_on_distance}/km.',
                        Icons.drive_eta),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (!widget.from)
                Container(
                  color: theme.colorScheme.background,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 52,
                  child: Row(
                    children: [
                      Text(
                        "Select " + getTranslated(context, "PAYMENT_MODE")!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                              paymentType != ""
                                  ? paymentType
                                  : getTranslated(context, 'WALLET')!,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.primaryColor, fontSize: 15),
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
                ),
              SizedBox(
                height: 20,
              ),
              if (!widget.from)
                !status
                    ? CustomButton(
                        color: MyColorName.primaryLite,
                        onTap: () {
                          if (paymentType == "Cash") {
                            setState(() {
                              status = true;
                            });
                            payOrder(widget.model.bookingId,
                                "order_${getRandomString(6)}");
                          } else {
                            // KhaltiPayHelper khaltiPay = new KhaltiPayHelper(
                            //     widget.model.amount!, context, (result) {
                            //   if (result != "error") {
                            //     payOrder(widget.model.bookingId, result);
                            //   } else {
                            //     setState(() {
                            //       status = false;
                            //     });
                            //   }
                            // });
                            setState(() {
                              status = true;
                            });
                            // khaltiPay.init();
                            /*RazorPayHelper razorPay = new RazorPayHelper(
                                widget.model.amount!, context, (result) {
                              if (result != "error") {
                                payOrder(widget.model.bookingId, result);
                              } else {
                                setState(() {
                                  status = false;
                                });
                              }
                            });
                            setState(() {
                              status = true;
                            });
                            razorPay.init();*/
                          }
                        },
                        text: "Pay \u{20B9}${widget.model.amount}",
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
  payOrder(bookingId, result) async {
    await App.init();
    Map param = {
      "user_id": curUserId,
      "booking_id": bookingId,
      "paymenttype": paymentType.toString(),
      "order_id": result.toString(),
    };
    Map response = await apiBase.postAPICall(
        Uri.parse(baseUrl1 + "payment/paid_status"), param);
    setState(() {
      status = false;
    });
    UI.setSnackBar(response['message'], context);
    if (response['status']) {
      Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      );
      /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SearchLocationPage()),
          (route) => false);*/
    }
  }
}
