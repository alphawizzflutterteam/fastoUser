import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pristine_andaman/Auth/login_navigator.dart';
import 'package:pristine_andaman/BookRide/choose_cab_page.dart';
import 'package:pristine_andaman/BookRide/finding_ride_page.dart';
import 'package:pristine_andaman/BookRide/search_location_page.dart';
import 'package:pristine_andaman/DrawerPages/ContactUs/contact_us_page.dart';
import 'package:pristine_andaman/DrawerPages/Profile/profile_page.dart';
import 'package:pristine_andaman/DrawerPages/PromoCode/promo_code_page.dart';
import 'package:pristine_andaman/DrawerPages/ReferEarn/refer_earn.dart';
import 'package:pristine_andaman/DrawerPages/Rides/my_rides_page.dart';
import 'package:pristine_andaman/DrawerPages/Settings/settings_page.dart';
import 'package:pristine_andaman/DrawerPages/Wallet/send_to_bank_page.dart';
import 'package:pristine_andaman/DrawerPages/Wallet/wallet_page.dart';
import 'package:pristine_andaman/DrawerPages/faq_page.dart';

import '../bottom_nav_screen.dart';

class PageRoutes {
  static const String loginNavigator = 'login_navigator';
  static const String searchLocationPage = 'search_location_page';
  static const String chooseCabPage = 'choose_cab_page';
  static const String findingRidePage = 'finding_ride_page';
  static const String rideBookedPage = 'ride_booked_page';
  static const String profilePage = 'profile_page';
  static const String myRidesPage = 'my_rides_page';
  static const String rideInfoPage = 'ride_info_page';
  static const String walletPage = 'wallet_page';
  static const String referPage = 'refer_earn';
  static const String promoCodePage = 'promo_code_page';
  static const String contactUsPage = 'contact_us_page';
  static const String faqPage = 'faq_page';
  static const String sendToBankPage = 'send_to_bank_page';
  static const String settingsPage = 'settings_page';

  Map<String, WidgetBuilder> routes() {
    return {
      loginNavigator: (context) => LoginNavigator(),
      searchLocationPage: (context) => BottomNavScreen(),
      chooseCabPage: (context) => ChooseCabPage(LatLng(0, 0), LatLng(0, 0), "",
          "", "", "", "", null, "", "", '', '', ''),
      findingRidePage: (context) =>
          FindingRidePage(LatLng(0, 0), LatLng(0, 0), "", "", "", "", "", ""),
      //rideBookedPage: (context) => RideBookedPage(),
      profilePage: (context) => ProfilePage(),
      myRidesPage: (context) => MyRidesPage("3"),
      rideInfoPage: (context) => MyRidesPage("3"),
      walletPage: (context) => WalletPage(),
      referPage: (context) => ReferEarn(),
      promoCodePage: (context) => PromoCodePage(),
      contactUsPage: (context) => ContactUsPage(),
      faqPage: (context) => FaqPage(),
      sendToBankPage: (context) => SendToBankPage(),
      settingsPage: (context) => SettingsPage(),
    };
  }
}
