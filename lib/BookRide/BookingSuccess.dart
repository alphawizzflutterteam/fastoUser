import 'package:flutter/material.dart';
import 'package:pristine_andaman/BookRide/search_location_page.dart';
import 'package:pristine_andaman/utils/colors.dart';

import '../DrawerPages/Rides/my_rides_page.dart';

class BookingSuccess extends StatefulWidget {
  const BookingSuccess({Key? key}) : super(key: key);

  @override
  State<BookingSuccess> createState() => _BookingSuccessState();
}

class _BookingSuccessState extends State<BookingSuccess> {
  @override
  void initState() {
    super.initState();
    // Navigate to the next page after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyRidesPage("3"),),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MyColorName.primaryLite, MyColorName.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/users/Success.png"),
            SizedBox(height: 20),
            Text(
              'Booking Successful',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your cab book successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
