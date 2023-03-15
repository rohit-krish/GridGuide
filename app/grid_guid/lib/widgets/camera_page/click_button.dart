import 'package:flutter/material.dart';

class ClickButton extends StatelessWidget {
  final double screenWidth;
  final IconData iconData;
  final Function onTapFunc;
  final bool show;

  const ClickButton(
    this.iconData,
    this.screenWidth,
    this.onTapFunc, {
    this.show = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: show ? () => onTapFunc() : () {},
      child: Container(
        height: screenWidth * .12,
        width: screenWidth * .12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: show ? Colors.white70 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            height: screenWidth * .097,
            width: screenWidth * .097,
            decoration: BoxDecoration(
              color: show ? Colors.white70 : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              iconData,
              color: show ? Colors.black : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
