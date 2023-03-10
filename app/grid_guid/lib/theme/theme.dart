import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey.shade900,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade900,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black,
      backgroundColor: Colors.grey.shade100,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade100,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
