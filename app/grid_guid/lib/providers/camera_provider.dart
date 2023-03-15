import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';

class CameraProvider with ChangeNotifier {
  void imageCaptureButtonClicked() {
    isImageCaptureButttonClicked = true;

    notifyListeners();
  }

  void detect(
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
    notifyListeners();
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
}
