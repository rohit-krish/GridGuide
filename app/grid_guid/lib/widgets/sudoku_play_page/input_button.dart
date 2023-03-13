import 'package:flutter/material.dart';

class InputButton extends StatelessWidget {
  final String labelText;
  final Function onPressedFunc;
  const InputButton(this.labelText, this.onPressedFunc, {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * .14,
      height: width * .14,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Colors.grey.shade300,
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => onPressedFunc(),
        child: FittedBox(
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: width * .07,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor.withAlpha(210),
            ),
          ),
        ),
      ),
    );
  }
}
