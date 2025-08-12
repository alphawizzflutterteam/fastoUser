import 'package:flutter/material.dart';
import 'package:pristine_andaman/Theme/style.dart';

class AuthBg extends StatelessWidget {
  const AuthBg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height / 1.7,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.transparent,
                // borderRadius: BorderRadius.only(
                //     bottomLeft: Radius.elliptical(200, 30),
                //     bottomRight: Radius.elliptical(200, 30))
                     ),
            child: Padding(
              padding: EdgeInsets.only(top: 70),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/splashLogo.png",
                        height: 200,

                      ),
                      // SizedBox(width: 12),
                      // Text(
                      //   "Pristine\nAndaman",
                      //   style: TextStyle(
                      //       fontSize: 28, color: AppTheme.primaryColor),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
