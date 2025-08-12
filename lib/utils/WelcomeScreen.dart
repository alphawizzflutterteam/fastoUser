import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pristine_andaman/utils/widget.dart';
import 'package:sizer/sizer.dart';

import '../Auth/Login/UI/login_page.dart';
import 'common.dart';
import 'constant.dart';

class WelComeScreen extends StatefulWidget {
  const WelComeScreen({Key? key}) : super(key: key);

  @override
  _WelComeScreenState createState() => _WelComeScreenState();
}

class _WelComeScreenState extends State<WelComeScreen> {
  List<MainModel> bannerList = [
    MainModel(
        "1",
        "Pristine Andaman allows users to easily set their preferred drop-off location, making their trip booking process quicker and more convenient",
        "assets/introimage1.png",
        Color(0xfffffff),
        "CHOOSE DESTINATION",
        "",
        "",
        1),
    MainModel(
        "2",
        "Effortlessly book your trip and reach your destination with ease using Pristine Andaman - Your reliable transportation partner",
        "assets/introimage2.png",
        Color(0xfffffff),
        "BOOK RIDE",
        "",
        "",
        1),
    MainModel(
        "3",
        "Your journey with trip starts here. Sit back, relax, and enjoy the trip",
        "assets/introimage3.png",
        Color(0xfffffff),
        "",
        "",
        "",
        1),
  ];

  CarouselSliderController carouselController = CarouselSliderController();

  int current = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: getWidth(390),
          child: Column(
            children: [
              Container(
                width: getWidth(390),
                child: CarouselSlider(
                  carouselController: carouselController,
                  options: CarouselOptions(
                    height: getHeight(650),
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    scrollPhysics: AlwaysScrollableScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() {
                        current = index;
                      });
                    },
                  ),
                  items: bannerList.map((MainModel e) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          e.image,
                          fit: BoxFit.fill,
                          width: getWidth(300),
                          height: getHeight(300),
                        ),
                        boxHeight(30),
                        text(
                          e.url,
                          fontWeight: FontWeight.bold,
                          textColor: Color(0xff722BEA),
                          isLongText: true,
                          fontSize: 24.sp,
                          isCentered: true,
                        ),
                        Padding(
                          padding: EdgeInsets.all(getWidth(25)),
                          child: text(
                            e.title,
                            fontFamily: fontMedium,
                            textColor: Colors.black,
                            // justify: true,
                            isLongText: true,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(20), vertical: getHeight(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bannerList.map((e) {
                      int index = bannerList
                          .indexWhere((element) => element.id == e.id);
                      return Container(
                        height: 10,
                        width: 10,
                        margin: EdgeInsets.only(right: 7),
                        decoration: boxDecoration(
                          bgColor: index == current
                              ? Color(0xff722BEA)
                              : Colors.purple.withOpacity(0.3),
                          radius: 10,
                        ),
                      );
                    }).toList(),
                  ),
                  InkWell(
                    onTap: () async {
                      if (current != 2) {
                        carouselController.nextPage();
                      } else {
                        await App.init();
                        App.localStorage.setBool("first", true);
                        navigateBackScreen(context, LoginPage());
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidth(25), vertical: getHeight(8)),
                      decoration: boxDecoration(
                        radius: 10.sp,
                        showShadow: true,
                        //  color: current == 2 ? Colors.black : Color(0xff722BEA),
                        // width: 3,
                        bgColor: Colors.black,
                      ),
                      child: Center(
                        child: text(
                          current != 2 ? "Next" : "NEXT",
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryModel {
  String id, name, image;

  CategoryModel(this.id, this.name, this.image);
}

class TimeModel {
  String id, name, price, km, perKm;

  TimeModel(this.id, this.name, this.price, this.km, this.perKm);
}

class MainModel {
  String id, title, image;
  Color color;
  String url, count, url1;
  int totalCount;
  MainModel(this.id, this.title, this.image, this.color, this.url, this.url1,
      this.count, this.totalCount);
}
