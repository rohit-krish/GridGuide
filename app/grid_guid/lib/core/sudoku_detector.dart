import 'dart:developer';
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

  // save the port on which we will send messages to the main thread
  _toMainThread = toMainThread;

  // create a port on which the main thread can send us message and listen to it
  ReceivePort fromMainThread = ReceivePort();
  fromMainThread.listen(_handleMessage);

  // send the main thread the port on which it can send us messages
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
      case 'augmentResults':
        var solvedNumbers = data.params['solvedNumbers'] as List<int>;
        var unvalidFlag = data.params['unvalidFlag'] as List<int>;
        var outputPath = data.params['outputPath'] as String;
        _detector.augmentResults(solvedNumbers, unvalidFlag, outputPath);
        break;
      default:
        log('Unknown method: ${data.method}');
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

  void augmentResults(
    List<int> solvedNumbers,
    List<int> unvalidFlag,
    String outputPath,
  ) {
    _nativeOpenCV.augmentResults(solvedNumbers, unvalidFlag, outputPath);
  }
}
