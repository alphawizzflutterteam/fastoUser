import 'package:flutter/cupertino.dart';

import '../../login_navigator.dart';
import 'verification_interactor.dart';
import 'verification_ui.dart';

class VerificationPage extends StatefulWidget {
  String mobile, otp;
  bool? isRegister;

  VerificationPage(this.mobile, this.otp, {this.isRegister});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    implements VerificationInteractor {
  @override
  Widget build(BuildContext context) {
    return VerificationUI(this, widget.mobile, widget.otp,isRegister: widget.isRegister,);
  }

  @override
  void notReceived() {
    Navigator.pushNamed(context, LoginRoutes.addMoney);
  }

  @override
  void verify() {
    Navigator.pushNamed(context, LoginRoutes.addMoney);
  }
}
