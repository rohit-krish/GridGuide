import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';
import 'package:path_provider/path_provider.dart';

class CameraProvider with ChangeNotifier {
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
    bbox = sudokuDetector.reorder(bbox);

    notifyListeners();
  }

  void discardCurrentClickedImage() {
    isImageCaptureButttonClicked = false;
    bbox = List.empty();
    isSnackBarShown = false;
    isSolutionButtonClicked = false;
    notifyListeners();
  }

  getSolution(SudokuDetector sudokuDetector) async{
    if (bbox.isEmpty) {
      // TODO: show a snackbar which says didn't detect the board
      return;
    }

    // isSolutionButtonClicked = true; TODO: uncomment it
    Directory? tempDir  = await getExternalStorageDirectory();
    String path = tempDir!.path;
    log(path.toString());
    sudokuDetector.extractBoxes(path);
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
    isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
