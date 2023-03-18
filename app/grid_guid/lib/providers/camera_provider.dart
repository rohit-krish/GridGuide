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

    int x = bbox[0].toInt();
    int y = bbox[1].toInt();
    int width = (bbox[2] - bbox[0]).toInt();
    int height = (bbox[5] - bbox[1]).toInt();

    // print(x);
    // print(y);
    // print(width);
    // print(height);
    print(bbox);
    print(x);
    print(y);
    print(width);
    print(height);

    log('decoding image...');
    img.Image? image = img.decodeImage(_imageBytes);
    log('decoded');
    // var cropped = img.copyCrop(image!, x: x, y: y, width: width, height: height);
    // img.drawRect(dst, x1: x1, y1: y1, x2: x2, y2: y2, color: color);

    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        body: Center(
          child: Image.memory(Uint8List.fromList(img.encodePng(image!))),
        ),
      );
    }));
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
