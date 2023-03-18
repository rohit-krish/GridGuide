import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guid/core/sudoku_detector.dart';
import 'package:image/image.dart' as img;

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

  getSolution(Uint8List bytes, BuildContext context) {
    if (bbox.isEmpty) {
      // TODO: show a snackbar which says didn't detect the board
      return;
    }

    // isSolutionButtonClicked = true; TODO: uncomment it
    _imageBytes = bytes;

    var _bbox = bbox.map((e) => e.toInt()).toList(growable: false);

    log('decoding image...');
    img.Image? image = img.decodeImage(_imageBytes);
    log('decoded');
    // var cropped = img.copyCrop(image!, x: x, y: y, width: width, height: height);
    img.drawRect(
      image!,
      x1: _bbox[0] * 2,
      y1: _bbox[1] * 2,
      x2: _bbox[6] * 2,
      y2: _bbox[7] * 2,
      color: img.ColorRgb8(255, 0, 0),
    );


    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return Scaffold(
          body: Center(
            child: Image.memory(Uint8List.fromList(img.encodePng(image))),
          ),
        );
      }),
    );
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
  bool isSnackBarShown = false;
  bool isSolutionButtonClicked = false;

  late CameraImage _image;
  late Uint8List _imageBytes;

  final _snackBar = const SnackBar(
    content: Text('Take new picture if detection is not correct'),
    duration: Duration(seconds: 5),
  );

  void showSnackBar(BuildContext context) {
    isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
