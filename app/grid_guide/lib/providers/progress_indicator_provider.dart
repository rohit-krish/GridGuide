import 'package:flutter/material.dart';

class ProgressIndicatorProvider with ChangeNotifier {
  int _currentPredictedBox = 0;
  double currentPercent = 0.0;
  void predictedNewBox() {
    _currentPredictedBox = ++_currentPredictedBox;
    currentPercent = (_currentPredictedBox * 100) / 81;
    notifyListeners();
  }

  void doneCurrentPrediction() {
    _currentPredictedBox = 0;
    currentPercent = 0.0;
    notifyListeners();
  }
}
