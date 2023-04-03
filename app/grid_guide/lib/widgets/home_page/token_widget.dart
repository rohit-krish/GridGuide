import 'package:flutter/material.dart';

class TokenWidget extends StatelessWidget {
  final double width;
  final int tokensLeft;
  final Function onTapFunc;
  const TokenWidget({
    required this.tokensLeft,
    required this.width,
    required this.onTapFunc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapFunc(),
      child: SizedBox(
        height: width * .2,
        width: width * .2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .02),
          child: LayoutBuilder(builder: (context, constrains) {
            return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                '$tokensLeft',
                style: TextStyle(
                  fontSize: constrains.maxWidth * .3,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: constrains.maxWidth * .03),
              Icon(
                Icons.token_outlined,
                size: constrains.maxWidth * .5,
                color: Colors.orange,
              ),
            ]);
          }),
        ),
      ),
    );
  }
}
