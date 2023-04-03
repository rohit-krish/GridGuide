import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import './sudoku_detector.dart' as sd;

class SudokuDetectorAsync {
  bool isSdThreadReady = false;
  late SendPort _toDetectorThread;
  final Map<int, Completer> _cbs = {};
  late Isolate _detectorThread;
  int _reqId = 0;
  SudokuDetectorAsync() {
    _initDetectionThread();
  }
  void _initDetectionThread() async {
    ReceivePort fromDetectorThread = ReceivePort();
    fromDetectorThread.listen(_handleMessage, onDone: () {
      isSdThreadReady = false;
    });
    _detectorThread = await Isolate.spawn(sd.init, fromDetectorThread.sendPort);
  }

  Future<Float32List?> detectBoard(CameraImage image, int rotation) {
    if (!isSdThreadReady) {
      return Future.value(null);
    }
    var reqId = ++_reqId;
    var res = Completer<Float32List?>();
    _cbs[reqId] = res;
    var msg = sd.Request(
      reqId: reqId,
      method: 'detectBoard',
      params: {'image': image, 'rotation': rotation},
    );
    _toDetectorThread.send(msg);
    return res.future;
  }

  void dispose() async {
    if (!isSdThreadReady) {
      return;
    }
    isSdThreadReady = false;
    var reqId = ++_reqId;
    var res = Completer();
    _cbs[reqId] = res;
    var msg = sd.Request(reqId: reqId, method: 'dispose');
    _toDetectorThread.send(msg);
    await res.future;
    _detectorThread.kill();
  }

  void extractBoxes(String outputPath) async {
    if (!isSdThreadReady) {
      return;
    }
    var reqId = ++_reqId;
    var res = Completer();
    _cbs[reqId] = res;
    var msg = sd.Request(
        reqId: reqId,
        method: 'extractBoxes',
        params: {'outputPath': outputPath});
    _toDetectorThread.send(msg);
    await res.future;
  }

  void _handleMessage(data) {
    if (data is SendPort) {
      _toDetectorThread = data;
      isSdThreadReady = true;
      return;
    }
    if (data is sd.Response) {
      var reqId = data.reqId;
      _cbs[reqId]?.complete(data.data);
      _cbs.remove(reqId);
      return;
    }
  }
}
