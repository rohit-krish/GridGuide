import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';

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
    var res = sudokuDetector.detect(image, camFrameRotation);

    if (res.isEmpty) return;

    bbox = res.map((x) => x * camFrameToScreenScale).toList(growable: false);
    bbox = sudokuDetector.reorder(bbox);

    notifyListeners();
  }

  void discardCurrentClickedImage() {
    isImageCaptureButttonClicked = false;
    bbox = List.empty();
    isSnackBarShown = false;
    notifyListeners();
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
  bool isSnackBarShown = false;





  final _snackBar = const SnackBar(
    content: Text('Take new picture if detection is not correct'),
    duration: Duration(seconds: 5),
  );

  void showSnackBar(BuildContext context) {
    isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
