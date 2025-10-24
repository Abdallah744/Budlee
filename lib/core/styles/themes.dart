import 'package:budlee_app/core/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.red,
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.purple[50],
    titleTextStyle: TextStyle(
      color: Colors.deepOrange,
      fontSize: appBarTitleFontSize,
      fontWeight: appBarTitleFontWeight,
    ),
  ),
  scaffoldBackgroundColor: Colors.purple[50],
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.deepOrange[600],
    unselectedItemColor: Colors.blueGrey[600],
    backgroundColor: Colors.purple[50],
    elevation: 20,
  ),
  textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
);

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.red,
  scaffoldBackgroundColor: HexColor('333739'),
  appBarTheme: AppBarTheme(
    backgroundColor: HexColor('333739'),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.redAccent,
      fontSize: appBarTitleFontSize,
      fontWeight: appBarTitleFontWeight,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.redAccent,
    unselectedItemColor: Colors.white,
    backgroundColor: Colors.black87,
    elevation: 20,
  ),
  textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
);
