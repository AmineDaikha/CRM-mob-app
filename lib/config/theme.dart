import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

final ThemeData customTheme = ThemeData(
  backgroundColor: white,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.white, // Set icon color to white
  ),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Avenir',
  textTheme: textTheme(),
  dialogBackgroundColor: Colors.white,
  primaryColor: Color(0xff049a9b),
);

ThemeData theme() {
  return ThemeData(
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // Set icon color to white
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Avenir',
    textTheme: textTheme(),
    primaryColor: Color(0xff049a9b),
  );
}

TextTheme textTheme() {
  return TextTheme(
    headline1: TextStyle(
        color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
    headline2: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    headline3: TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    headline4: TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
    headline5: TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
    headline6: TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
    bodyText1: TextStyle(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal),
    bodyText2: TextStyle(
        color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal),
  );
}
