import 'package:flutter/material.dart';
import 'package:grid_guid/pages/camera_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Guid'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Camera'),
          onPressed: () {
            Navigator.of(context).pushNamed(CameraPage.routeName);
          },
        ),
      ),
    );
  }
}
