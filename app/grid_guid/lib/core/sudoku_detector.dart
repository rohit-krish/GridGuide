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

  int _argmin(List<double> pnt) {
    double minVal = pnt[0];
    int minArg = 0;

    for (int i = 0; i < 4; i++) {
      if (pnt[i] < minVal) {
        minVal = pnt[i];
        minArg = i;
      }
    }
    return minArg;
  }

  int _argmax(List<double> pnt) {
    double maxVal = pnt[0];
    int maxArg = 0;

    for (int i = 0; i < 4; i++) {
      if (pnt[i] > maxVal) {
        maxVal = pnt[i];
        maxArg = i;
      }
    }

    return maxArg;
  }

  List<double> reorder(List<double> bbox) {
    sumPoints = List.empty(growable: true);
    diffPoints = List.empty(growable: true);

    res = List.filled(8, 0, growable: false);

    for (int i = 0; i < 8; i += 2) {
      sumPoints.add(bbox[i + 1] + bbox[i]);
      diffPoints.add(bbox[i + 1] - bbox[i]);
    }

    // 0
    res[0] = bbox[_argmin(sumPoints) * 2];
    res[1] = bbox[(_argmin(sumPoints) * 2) + 1];

    // 1
    res[2] = bbox[_argmin(diffPoints) * 2];
    res[3] = bbox[(_argmin(diffPoints) * 2) + 1];

    // 2
    res[4] = bbox[_argmax(diffPoints) * 2];
    res[5] = bbox[(_argmax(diffPoints) * 2) + 1];

    // 3
    res[6] = bbox[_argmax(sumPoints) * 2];
    res[7] = bbox[(_argmax(sumPoints) * 2) + 1];

    return res;
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

  List<Uint8List> _transformBoxesToUint8List(List<int> wholeBoxes) {
    const oneBoxLimit = 4900;
    List<Uint8List> boxes = List.empty(growable: true);

    for (int i = 0; i < wholeBoxes.length; i += oneBoxLimit) {
      boxes.add(Uint8List.fromList(wholeBoxes.sublist(i, i + oneBoxLimit)));
    }

    return boxes;
  }

  List<List<int>> _transformBoxesToListOfInt(List<int> wholeBoxes) {
    const oneBoxLimit = 4900;
    List<List<int>> boxes = List.empty(growable: true);

    for (int i = 0; i < wholeBoxes.length; i += oneBoxLimit) {
      boxes.add(wholeBoxes.sublist(i, i + oneBoxLimit));
    }

    return boxes;
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

  getBoxes(List<int> bbox) async {
    List<int> wholeBoxes = _nativeOpenCV.getBoxes(bbox).toList(growable: false);
    // List<Uint8List> uint8boxes = _transformBoxesToUint8List(wholeBoxes);
    List<List<int>> intboxes = _transformBoxesToListOfInt(wholeBoxes);
    String completeContent = "";


    for (int i = 0; i < 4900; i += 70) {
      completeContent = "$completeContent\n${intboxes[0].sublist(i, i + 70).join(', ')}";
    }
    log(completeContent);

    // log("Prediction: ${await predict(intboxes[2])}");

    // log(box.reduce((value, element) => value>element ? value : element).toString());
    // saveImageToExternalStorage(boxes[0]);
  }
}
