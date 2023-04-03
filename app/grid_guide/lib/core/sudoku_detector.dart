import 'dart:isolate';
import 'dart:typed_data' show Uint8List, Float32List;
import 'package:camera/camera.dart' show CameraImage;
import 'package:native_opencv/native_opencv.dart';

late _SudokuDetector _detector;
late SendPort _toMainThread;

class Request {
  int reqId;
  String method;
  dynamic params;
  Request({required this.reqId, required this.method, this.params});
}

class Response {
  int reqId;
  dynamic data;
  Response({required this.reqId, required this.data});
}

void init(SendPort toMainThread) {
  _detector = _SudokuDetector();
  _toMainThread = toMainThread;
  ReceivePort fromMainThread = ReceivePort();
  fromMainThread.listen(_handleMessage);
  _toMainThread.send(fromMainThread.sendPort);
}

void _handleMessage(data) {
  if (data is Request) {
    dynamic res;
    switch (data.method) {
      case 'detectBoard':
        var image = data.params['image'] as CameraImage;
        var rotation = data.params['rotation'] as int;
        res = _detector.detectBoard(image, rotation);
        break;
      case 'dispose':
        _detector.dispose();
        break;
      case 'extractBoxes':
        var outputPath = data.params['outputPath'] as String;
        _detector.extractBoxes(outputPath);
        break;
    }
    _toMainThread.send(Response(reqId: data.reqId, data: res));
  }
}

class _SudokuDetector {
  late NativeOpenCV _nativeOpenCV;
  _SudokuDetector() {
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
}
