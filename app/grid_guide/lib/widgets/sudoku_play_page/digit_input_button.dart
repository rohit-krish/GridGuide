import 'package:flutter/material.dart';

import '../../theme/digit_input_button_widget_theme.dart';

class DigitInputButton extends StatelessWidget {
  final String labelText;
  final Function onPressedFunc;
  const DigitInputButton(this.labelText, this.onPressedFunc, {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Container(
      width: width * .14,
      height: width * .14,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: getWhichBackGroundColorToDisplay(isDarkMode),
          boxShadow: [
            BoxShadow(
                blurRadius: 10.0,
                color: getWhichShadowColorToDisplay(isDarkMode))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextButton(
          onPressed: () => onPressedFunc(),
          child: FittedBox(
            child: Text(
              labelText,
              style: TextStyle(
                  fontSize: width * .07,
                  fontWeight: FontWeight.w500,
                  color: getWhichFontColorToDisplay(isDarkMode)),
            ),
          ),
        ),
      ),
    );
  }
}
