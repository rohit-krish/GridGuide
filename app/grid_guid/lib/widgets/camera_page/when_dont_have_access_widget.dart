import 'package:flutter/material.dart';

class WhenDontHaveAccessToCamera extends StatelessWidget {
  final double width;
  const WhenDontHaveAccessToCamera(this.width,{super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            Text(
              "Don't have access to camera\nProvide access to camera to get this feature.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: width * .05),
            ),
            const Spacer(),
            Image.asset(
              'assets/images/permission_error.png',
              width: width * .7,
            )
          ],
        ),
      ),
    );
  }
}
