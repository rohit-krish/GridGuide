import 'dart:math';

import 'package:flutter/material.dart';

class ClickButton extends StatelessWidget {
  final double screenWidth;
  final IconData iconData;
  final Function onTap;
  const ClickButton(this.iconData, this.screenWidth, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: screenWidth * .12,
        width: screenWidth * .12,
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Center(
          child: Container(
            height: screenWidth * .097,
            width: screenWidth * .097,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(iconData, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

// Icons.camera