import 'dart:typed_data' show Uint8List;

import 'package:image/image.dart' show Image, decodeJpgFile;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../providers/progress_indicator_provider.dart';

var _interpreterOptions = InterpreterOptions();
late Interpreter _interpreter;

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

  for (int i = 0; i < 81; i++) {
    Uint8List? imgAsList = await _preprocess("$outputPath/$i.jpg");
    if (imgAsList == null) {
      continue;
    }

    predictions.add(await _getPredictions(imgAsList));

    progressIndicatorProvider.predictedNewBox();
  }

  _interpreter.close();

  return predictions;
}
