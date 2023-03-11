// import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:native_opencv/native_opencv.dart';

class SudokuDetector {
  NativeOpenCV? _nativeOpenCV;

  SudokuDetector() {
    _nativeOpenCV = NativeOpenCV();
  }

  void dispose() {
    if (_nativeOpenCV != null) {
      _nativeOpenCV!.dispose();
    }
  }

  Float32List? detect(CameraImage image, int rotation) {
    if (_nativeOpenCV == null) return null;
    
    var planes = image.planes;
    Uint8List yBuffer = planes[0].bytes;
    Uint8List uBuffer = planes[1].bytes;
    Uint8List vBuffer = planes[2].bytes;


    var res = _nativeOpenCV!.detect(image.width, image.height, rotation, yBuffer, uBuffer, vBuffer);
    return res;
  }
}
