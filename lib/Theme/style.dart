import 'package:flutter/material.dart';
import 'package:pristine_andaman/utils/colors.dart';

class AppTheme {
  static String fontFamily = 'Poppins';
  //static Color primaryColor = Color(0xffDA0203); //123456
  static Color primaryColor = Color(0xff000000);
  // static Color primaryColor = Color(0xff2942A7); //123456
 // static Color secondaryColor = Color(0xff000000);
  static Color secondaryColor = Color(0xff7DBF04);
  // static Color secondaryColor = Color(0xff029752);
  static Color hintColor = Colors.black;
  static Color ratingsColor = Color(0xff51971B);
  static Color starColor = Color(0xffB6E025);


  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryColor,
    hintColor: hintColor,
    primaryColorLight: Colors.white,
    dividerColor: hintColor,
    cardColor: Color(0xff202020),
    useMaterial3: false,

    ///appBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: MyColorName.primaryLite,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
    ),

    ///icon theme
    iconTheme: IconThemeData(color: Colors.white),

    ///input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      floatingLabelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: primaryColor),
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
    ),

    ///text theme
    textTheme: TextTheme().apply(),
  );

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryColor,
    hintColor: hintColor,
    primaryColorLight: Colors.black,
    dividerColor: hintColor,
    iconTheme: IconThemeData(color: Colors.white),
    fontFamily: 'SofiaSans',
    cardColor: Colors.white,
    useMaterial3: false,

    ///appBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppTheme.primaryColor,
      titleTextStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: "SofiaSans",
          color: Colors.white),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
    ),

    ///input decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      floatingLabelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: primaryColor),
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
    ),

    ///text theme
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontSize: 18),
      bodyLarge: TextStyle(fontWeight: FontWeight.bold),
      displayLarge: TextStyle(color: Colors.black),
    ).apply(),
    // colorScheme: ColorScheme(background: Colors.white, brightness: Brightness.light, primary: primaryColor, onPrimary: ),
  );
}

/// NAME         SIZE  WEIGHT  SPACING
/// headline1    96.0  light   -1.5
/// headline2    60.0  light   -0.5
/// headline3    48.0  regular  0.0
/// headline4    34.0  regular  0.25
/// headline5    24.0  regular  0.0
/// headline6    20.0  medium   0.15
/// subtitle1    16.0  regular  0.15
/// subtitle2    14.0  medium   0.1
/// body1        16.0  regular  0.5   (bodyText1)
/// body2        14.0  regular  0.25  (bodyText2)
/// button       14.0  medium   1.25
/// caption      12.0  regular  0.4
/// overline     10.0  regular  1.5
