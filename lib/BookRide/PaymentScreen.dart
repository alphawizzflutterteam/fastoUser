import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../utils/ApiBaseHelper.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import 'BookingSuccess.dart';

class PaymentScreen extends StatefulWidget {
  String? bookingId, paymentType, amount;
  PaymentScreen({
    Key? key,
    this.bookingId,
    this.paymentType,
    this.amount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paymentCalculate();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  String? tranId;

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    tranId = response.paymentId.toString();
    Fluttertoast.showToast(msg: "Payment successfully");
    paymentBooking();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment cancelled by user");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Razorpay? _razorpay;

  int? pricerazorpayy;
  void openCheckout(amount) async {
    double res = double.parse(amount.toString());
    pricerazorpayy = int.parse(res.toStringAsFixed(0)) * 100;
    var options = {
      'key': 'rzp_test_eWu6niIBmIdUFK',
      'amount': "$pricerazorpayy",
      'name': 'Fasto',
      'image': 'assets/images/Group 165.png',
      'description': 'Fasto',
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  double? partPayment;

  paymentCalculate() {
    partPayment = double.parse(widget.amount.toString()) * 0.30;
    print(
        "part payment $partPayment amount is ${widget.amount} payemy type is ${widget.paymentType}");
  }

  String? _selectedPaymentMethod;

  bool saveStatus = true;
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;

  paymentBooking() async {
    try {
      setState(() {
        saveStatus = false;
      });
      var headers = {
        'Cookie': 'ci_session=027ff52a9eb672285c78ee8d9656c5514617b7d1'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://pristin.pristineandaman.com/api/booking/update_booking_payment'));
      request.fields.addAll({
        "user_id": curUserId.toString(),
        "id": widget.bookingId.toString(),
        'amount':
            '${widget.paymentType == "Part Payment" ? partPayment : widget.amount.toString()}',
        'transaction_id': tranId.toString(),
        'payment_mode': '${_selectedPaymentMethod.toString()}',
        'payment_type': _selectedPaymentMethod.toString() == 'Cash Payment'  ?   ''  :  '${widget.paymentType.toString()}'
      });
      print("schedule ride is ${request.fields}");
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        var finalResult = jsonDecode(result);
        if (finalResult['status'] == true) {
          Fluttertoast.showToast(msg: finalResult['message'].toString());
          setState(() {
            saveStatus = true;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BookingSuccess()));
        }
        Fluttertoast.showToast(msg: "${finalResult['message']}");
        setState(() {
          saveStatus = true;
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
    // try {
    //   setState(() {
    //     saveStatus = false;
    //   });
    //   Map params = {
    //     "user_id": curUserId,
    //     "id": widget.bookingId.toString(),
    //     'amount': widget.paymentType == "Part Payment"
    //         ? partPayment
    //         : widget.amount.toString(),
    //     'transaction_id': '478979879846513165',
    //     'payment_mode': '${_selectedPaymentMethod.toString()}',
    //     'payment_type': '${widget.paymentType.toString()}'
    //   };
    //   print("schedule ride is $params");
    //   Map response = await apiBase.postAPICall(Uri.parse(baseUrl1 + "booking/update_booking_payment"), params);
    //   setState(() {
    //     saveStatus = true;
    //   });
    //   if (response['status']) {
    //     Navigator.push(
    //         context, MaterialPageRoute(builder: (context) => BookingSuccess()));
    //     UI.setSnackBar(response['message'], context);
    //   } else {
    //     UI.setSnackBar(response['message'], context);
    //   }
    // } on TimeoutException catch (_) {
    //   UI.setSnackBar(getTranslated(context, "WRONG")!, context);
    //   setState(() {
    //     saveStatus = true;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Payment Type',
          style: TextStyle(fontSize: 17,color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // _buildPaymentOption('Cash Payment', 'assets/users/cash.png'),
            _buildPaymentOption('Cash Payment', 'assets/cash.png'),
            _buildPaymentOption('Online Payment', 'assets/online.png'),
            _buildPaymentOption('Wallet', 'assets/wallet.png'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_selectedPaymentMethod == "Online Payment") {
                  openCheckout(
                    widget.paymentType == "Part Payment"
                        ? partPayment
                        : widget.amount.toString(),
                  );
                } else {
                  paymentBooking();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: MyColorName.secondary, // Button color
              ),
              child: Text(
                'CONTINUE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String iconPath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: MyColorName.greyBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.asset(
              iconPath, // Add your icons to the assets folder and define them in pubspec.yaml
              width: 40,
              height: 40,
            ),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: Radio<String>(
              value: title,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedPaymentMethod = title;
              });
            },
          ),
        ),
      ),
    );
  }
}
