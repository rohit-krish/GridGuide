// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:grid_guid/pages/camera_page.dart';
import 'package:native_opencv/native_opencv.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final native_opencv = NativeOpenCV();

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
            // log("OpenCV version: ${native_opencv.cvVersion()}");
          },
        ),
      ),
    );
  }
}
