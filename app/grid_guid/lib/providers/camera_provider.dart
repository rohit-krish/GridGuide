import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CameraProvider with ChangeNotifier {
  var done = SnackBar(
    content: Text('done!'),
    duration: Duration(seconds: 5),
  );

  void imageCaptureButtonClicked() {
    isImageCaptureButttonClicked = true;

    notifyListeners();
  }

  void detectBoard(
    CameraImage image,
    SudokuDetector sudokuDetector,
    int camFrameRotation,
    double camFrameToScreenScale,
  ) {
    _image = image;
    var res = sudokuDetector.detectBoard(_image, camFrameRotation);

    if (res.isEmpty) return;

    bbox = res.map((x) => x * camFrameToScreenScale).toList(growable: false);

    notifyListeners();
  }

  void discardCurrentClickedImage() {
    isImageCaptureButttonClicked = false;
    bbox = List.empty();
    isSnackBarShown = false;
    isSolutionButtonClicked = false;
    notifyListeners();
  }

  uploadToServer(BuildContext context) async {
    log('called uploadserver');
    Directory? tempDir = await getExternalStorageDirectory();
    String path = tempDir!.path;

    String url = 'http://192.168.43.21:5000/endpoint';

    for (int i = 0; i < 81; i++) {
      File boxFile = File('$path/$i.jpg');
      final bytes = await boxFile.readAsBytes();

      await http.post(Uri.parse(url), body: {'string': base64Encode(bytes)});
    }
    ScaffoldMessenger.of(context).showSnackBar(done);
  }

  getSolution(SudokuDetector sudokuDetector) async {
    if (bbox.isEmpty) {
      // TODO: show a snackbar which says didn't detect the board
      return;
    }

    isSolutionButtonClicked = true;

    Directory? tempDir = await getExternalStorageDirectory();
    String path = tempDir!.path;
    log(path.toString());
    sudokuDetector.getBoxes(path);
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
  bool isSnackBarShown = false;
  bool isSolutionButtonClicked = false;

  late CameraImage _image;

  final _snackBar = const SnackBar(
    content: Text('Take new picture if detection is not correct'),
    duration: Duration(seconds: 5),
  );

  void showSnackBar(BuildContext context) {
    // isSnackBarShown = true;
    // ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
