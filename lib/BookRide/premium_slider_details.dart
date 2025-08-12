import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:pristine_andaman/BookRide/select_location_screen.dart';
import 'package:pristine_andaman/utils/colors.dart';

import '../Components/custom_button.dart';
import '../Model/location_model.dart';
import '../Model/premium_slider_model.dart';
class PremiumSliderDetails extends StatefulWidget {
  PremiumSliderData? sliderData;
  LocationData? availableLocationList;
   PremiumSliderDetails({this.sliderData,required this.availableLocationList});

  @override
  State<PremiumSliderDetails> createState() => _PremiumSliderDetailsState();
}

class _PremiumSliderDetailsState extends State<PremiumSliderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:InkWell(
        onTap:  () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SelectLocationScreen(currentIndex: 1,selectCabType:'Scheduled Booking' ,availableLocationList: widget.availableLocationList)));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width/1.4,
            height: 50,
            decoration: BoxDecoration(
              color: MyColorName.secondary,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Center(child: Text('Schedule ',style: TextStyle(color: Colors.white,fontSize: 18))),
          
          ),
        ),
      ),

      appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
           'Travel Smart',
            style: TextStyle(color: Colors.black),
          ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Card(
              // shape: RoundedRectangleBorder(
              //   side: BorderSide(color: Colors.white70, width: 1),
              //   borderRadius: BorderRadius.circular(20),
              // ),
              elevation: 2,
              child: Container(
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width/1.1,
                  child: Image.network(widget.sliderData?.image ?? ''),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(parse(widget.sliderData?.title).body?.text ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(parse(widget.sliderData?.description).body?.text ?? '', style: TextStyle(fontSize: 14, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
