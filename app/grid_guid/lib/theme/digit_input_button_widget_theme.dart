import 'package:flutter/material.dart';

Color getWhichBackGroundColorToDisplay(bool isDarkMode) {
  if (isDarkMode) {
    return Colors.grey.shade800;
  } else {
    return Colors.grey.shade100;
  }
}

Color getWhichShadowColorToDisplay(bool isDarkMode) {
  if (isDarkMode) {
    return Colors.grey.shade800;
  } else {
    return Colors.grey.shade300;
  }
}

Color getWhichFontColorToDisplay(bool isDarkMode) {
  if (isDarkMode) {
    return Colors.grey.shade300;
  } else {
    return Colors.black;
  }
}
