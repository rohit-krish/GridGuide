import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
  void imageIsCaptured() {
    _isImageCaptured = true;
    notifyListeners();
  }

  bool _isImageCaptured = false;

  bool get isImageCaptured => _isImageCaptured;
}
