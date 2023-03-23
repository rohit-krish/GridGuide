import 'dart:typed_data' show Uint8List, Float32List;

import 'package:camera/camera.dart' show CameraImage;
import 'package:native_opencv/native_opencv.dart';

class SudokuDetector {
  late NativeOpenCV _nativeOpenCV;

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

  void extractBoxes(String outputPath) {
    _nativeOpenCV.extractBoxes(outputPath);
  }

  void augmentResults(
    List<int> solvedNumbers,
    List<int> unvalidFlag,
    String outputPath,
  ) {
    _nativeOpenCV.augmentResults(solvedNumbers, unvalidFlag, outputPath);
  }
}
