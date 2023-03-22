import 'dart:developer' show log;
import 'dart:typed_data' show Uint8List, Float32List;

import 'package:camera/camera.dart' show CameraImage;
import 'package:native_opencv/native_opencv.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' show Image, decodeJpgFile;

import '../providers/progress_indicator_provider.dart';

class SudokuDetector {
  late NativeOpenCV _nativeOpenCV;
  late InterpreterOptions _interpreterOptions;
  late Interpreter _interpreter;

  SudokuDetector() {
    _nativeOpenCV = NativeOpenCV();
    _interpreterOptions = InterpreterOptions();
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

  Future<Uint8List?> _preprocess(String filePath) async {
    Image? imgTemp = await decodeJpgFile(filePath);
    if (imgTemp == null) return null;

    var imgBytes = imgTemp.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();
    return imgAsList;
  }

  Future<int> _getPredictions(Uint8List imgAsList) async {
    // since the image is jpg so we will have RGB channels we have to take it's gray scale
    List resultBytes = List.filled(70 * 70, 0, growable: false);

    int index = 0;

    for (int i = 0; i < imgAsList.length; i += 3) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      // since the model will do the normalization we don't have to normalize b/w 0 & 1
      resultBytes[index] = (r + g + b) / 3.0;
      index++;
    }

    var input = resultBytes.reshape([1, 70, 70, 1]);
    var output = List.filled(10, 0, growable: false).reshape([1, 10]);

    _interpreter.run(input, output);

    double highestProp = 0.0;
    int digitPred = -1;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProp) {
        highestProp = output[0][i];
        digitPred = i;
      }
    }
    return digitPred;
  }

  Future<List<int>> getBoxes(
    String outputPath,
    ProgressIndicatorProvider progressIndicatorProvider,
  ) async {
    List<int> predictions = [];
    _interpreter = await Interpreter.fromAsset(
      'model/model_v2.tflite',
      options: _interpreterOptions,
    );

    _nativeOpenCV.extractBoxes(outputPath);

    // TODO: warn if the images doesn't exist(happens when user deletes it)
    for (int i = 0; i < 81; i++) {
      Uint8List? imgAsList = await _preprocess("$outputPath/$i.jpg");
      if (imgAsList == null) {
        log('null $i');
        continue;
      }

      predictions.add(await _getPredictions(imgAsList));
      progressIndicatorProvider.predictedNewBox();
    }

    _interpreter.close();

    return predictions;
  }
}
