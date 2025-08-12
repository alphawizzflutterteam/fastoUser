// import 'dart:convert';
// import 'dart:math';
//
// import 'package:pristine_andaman/utils/common.dart';
// import 'package:pristine_andaman/utils/constant.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:pristine_andaman/utils/new_utils/ui.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // import 'package:khalti_flutter/khalti_flutter.dart';
//
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import 'Session.dart';
//
// String razorPayKey = "rzp_test_K7iUQiyMNy1FIT";
// String razorPaySecret = "Bb03yFC5dGa9lXTtLnF3qkXQ";
//
// class KhaltiPayHelper {
//   String amount;
//   String? orderId;
//   BuildContext context;
//   ValueChanged onResult;
//   Razorpay? _razorpay;
//   KhaltiPayHelper(this.amount, this.context, this.onResult);
//   static const _chars =
//       'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//   Random _rnd = Random();
//
//   String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
//       length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
//
//   init() {
//     orderId = "order_" + getRandomString(6);
//     print(mobile);
//     showDialog(
//         context: context,
//         builder: (ctx) {
//           return Dialog(
//             child: Container(
//               padding: EdgeInsets.all(getWidth(10)),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   KhaltiButton.wallet(
//                     config: PaymentConfig(
//                       amount: int.parse(amount) * 100, //in paisa
//                       productIdentity: orderId!,
//                       productName: 'Pristine Andaman',
//                       mobile: "9800000001",
//                       mobileReadOnly: false,
//                     ),
//                     onSuccess: onSuccess,
//                     onFailure: onFailure,
//                     onCancel: onCancel,
//                   ),
//                   KhaltiButton.eBanking(
//                     config: PaymentConfig(
//                       amount: int.parse(amount) * 100, //in paisa
//                       productIdentity: orderId!,
//                       productName: 'Pristine Andaman',
//                       mobile: "9800000001",
//                       mobileReadOnly: false,
//                     ),
//                     onSuccess: onSuccess,
//                     onFailure: onFailure,
//                     onCancel: onCancel,
//                   ),
//                   KhaltiButton.mBanking(
//                     config: PaymentConfig(
//                       amount: int.parse(amount) * 100, //in paisa
//                       productIdentity: orderId!,
//                       productName: 'Pristine Andaman',
//                       mobile: "9800000001",
//                       mobileReadOnly: false,
//                     ),
//                     onSuccess: onSuccess,
//                     onFailure: onFailure,
//                     onCancel: onCancel,
//                   ),
//                   KhaltiButton.connectIPS(
//                     config: PaymentConfig(
//                       amount: int.parse(amount) * 100, //in paisa
//                       productIdentity: orderId!,
//                       productName: 'Pristine Andaman',
//                       mobile: "9800000001",
//                       mobileReadOnly: false,
//                     ),
//                     onSuccess: onSuccess,
//                     onFailure: onFailure,
//                     onCancel: onCancel,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//     /*KhaltiScope.of(context).pay(
//       config: PaymentConfig(
//         amount: int.parse(amount), //in paisa
//         productIdentity: orderId!,
//         productName: 'Pristine Andaman',
//         mobile: '9800003001',
//         mobileReadOnly: false,
//       ),
//       preferences: [
//         PaymentPreference.khalti,
//       ],
//       onSuccess: onSuccess,
//       onFailure: onFailure,
//       onCancel: onCancel,
//     );*/
//   }
//
//   void onSuccess(PaymentSuccessModel success) {
//     Navigator.pop(context);
//     onResult(success.idx);
//     UI.setSnackBar("Payment Done", context);
//   }
//
//   void onFailure(PaymentFailureModel failure) {
//     Navigator.pop(context);
//     onResult("error");
//     UI.setSnackBar("Payment Failed", context);
//     debugPrint(
//       failure.toString(),
//     );
//   }
//
//   void onCancel() {
//     onResult("error");
//     UI.setSnackBar("Payment Cancelled", context);
//     debugPrint('Cancelled');
//   }
// }
