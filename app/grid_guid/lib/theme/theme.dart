import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade800,
      contentTextStyle: TextStyle(color: Colors.grey.shade100),
    ),
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey.shade900,
    fontFamily: 'PTSans',
    appBarTheme: AppBarTheme(
      titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey.shade900,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );
  static final lightTheme = ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade300,
      contentTextStyle: TextStyle(color: Colors.grey.shade900)
    ),
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey.shade100,
    fontFamily: 'PTSans',
    appBarTheme: AppBarTheme(
      titleTextStyle: const TextStyle(fontSize: 23, color: Colors.black),
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black,
      backgroundColor: Colors.grey.shade100,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
