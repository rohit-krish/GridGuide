import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';
import 'package:grid_guid/providers/progress_indicator_provider.dart';
import 'package:grid_guid/utils/camera_page/check_unvalid_places.dart';
import 'package:path_provider/path_provider.dart';

class CameraProvider with ChangeNotifier {
  void imageCaptureButtonClicked() {
    isImageCaptureButttonClicked = true;

    notifyListeners();
  }

  void solutionButtonClicked() {
    isSolutionButtonClicked = true;
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
    isDoneProcessing = false;
    notifyListeners();
  }

  augmentSolutions(
    SudokuDetector sudokuDetector,
    BuildContext context,
    ProgressIndicatorProvider progressIndicatorProvider,
  ) async {
    if (bbox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar("Couldn't detect, Take new picture!!"),
      );
      return;
    }

    // get boxes
    Directory? tempDir = await getExternalStorageDirectory();
    String path = tempDir!.path;
    List<int> boxDigits = await sudokuDetector.getBoxes(path, progressIndicatorProvider);
    List<int> unvalidPlaces = checkUnvalidPlaces(boxDigits);
    sudokuDetector.augmentResults(boxDigits, unvalidPlaces, path);

    //* PLAN
    /// check for each cell to know if it is valid or not using cpp script
    /// if all valid show the detection and solution
    /// if unvalid exist point out the unvalid and don't show the solution

    // find solution

    // augment

    isDoneProcessing = true;
    notifyListeners();
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
  bool isSnackBarShown = false;
  bool isSolutionButtonClicked = false;
  bool isDoneProcessing = false;

  late CameraImage _image;

  void showSnackBarAfterDetection(BuildContext context) {
    isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      getSnackBar('Take new picture if detection is not correct'),
    );
  }
}

SnackBar getSnackBar(String title) => SnackBar(
      content: Text(title),
      duration: const Duration(seconds: 5),
    );
