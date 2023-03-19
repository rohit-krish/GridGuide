import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:native_opencv/native_opencv.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SudokuDetector {
  late NativeOpenCV _nativeOpenCV;

  late List<double> sumPoints;
  late List<double> diffPoints;
  late List<double> res;

  SudokuDetector() {
    _nativeOpenCV = NativeOpenCV();
  }

  void dispose() {
    _nativeOpenCV.dispose();
  }

  Float32List detectBoard(CameraImage image, int rotation) {
    var planes = image.planes;
    Uint8List yBuffer = planes[0].bytes;
    Uint8List uBuffer = planes[1].bytes;
    Uint8List vBuffer = planes[2].bytes;

    var res = _nativeOpenCV.detectBoard(
      image.width,
      image.height,
      rotation,
      yBuffer,
      uBuffer,
      vBuffer,
    );
    return res;
  }

  Future<int> predict(List<int> box) async {
    var input = box.map((e) => e.toDouble()).toList().reshape([1, 70, 70, 1]);
    var output = List.filled(1 * 10, 0, growable: false).reshape([1, 10]);

    InterpreterOptions interpreterOptions = InterpreterOptions();

    try {
      Interpreter interpreter = await Interpreter.fromAsset(
        'model/model.tflite',
        options: interpreterOptions,
      );
      interpreter.run(input, output);
    } catch (e) {
      log(e.toString());
    }

    double hightestProb = 0;
    int digitPred = 1;
    print(output);

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > hightestProb) {
        hightestProb = output[0][i];
        digitPred = i;
      }
    }

    return digitPred;
  }

  void extractBoxes(String outputPath) {
    _nativeOpenCV.extractBoxes(outputPath);
  }
}
