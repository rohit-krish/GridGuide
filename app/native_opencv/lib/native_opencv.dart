// ignore_for_file: camel_case_types

import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// load the c lib
final DynamicLibrary nativeLib = DynamicLibrary.open("libnative_opencv.so");

// C Functions signatures
typedef _c_detect_board = Pointer<Float> Function(Pointer<Uint8> bytes, Int32 width, Int32 height, Int32 rotation, Pointer<Int32> outCount);
typedef _c_get_boxes = Pointer<Int32> Function(Pointer<Int32> cnt);

// Dart Functions signatures
typedef _dart_detect_board = Pointer<Float> Function(Pointer<Uint8> bytes, int width, int height, int rotation, Pointer<Int32> outCount);
typedef _dart_get_boxes = Pointer<Int32> Function(Pointer<Int32> cnt);

// create dart functions that invoke the c functions
final _detectBoard = nativeLib.lookupFunction<_c_detect_board, _dart_detect_board>('detect_board');
final _getBoxes = nativeLib.lookupFunction<_c_get_boxes, _dart_get_boxes>('get_boxes');

class NativeOpenCV {
  Pointer<Uint8>? _imageBuffer;
  Pointer<Int32>? _contourBuffer;

  void dispose() {
    if (_imageBuffer != null) {
      malloc.free(_imageBuffer!);
    }

    if (_contourBuffer != null) {
      malloc.free(_contourBuffer!);
    }
  }

  Float32List detectBoard(
    int width,
    int height,
    int rotation,
    Uint8List yBuffer,
    Uint8List uBuffer,
    Uint8List vBuffer,
  ) {
    var ySize = yBuffer.lengthInBytes;
    var uSize = uBuffer.lengthInBytes;
    var vSize = vBuffer.lengthInBytes;
    var totalSize = ySize + uSize + vSize;

    _imageBuffer ??= malloc.allocate<Uint8>(totalSize);

    Uint8List bytes = _imageBuffer!.asTypedList(totalSize);
    bytes.setAll(0, yBuffer);
    bytes.setAll(ySize, vBuffer);
    bytes.setAll(ySize + vSize, uBuffer);

    Pointer<Int32> outCount = malloc.allocate<Int32>(1);

    var res = _detectBoard(_imageBuffer!, width, height, rotation, outCount);
    final count = outCount.value;

    malloc.free(outCount);

    return res.asTypedList(count);
  }

  Int32List getBoxes(List<int> contour) {
    _contourBuffer = malloc.allocate(sizeOf<Pointer<Int32>>() * contour.length);
    // log('created buffer');

    final bytes = _contourBuffer!.asTypedList(contour.length);
    bytes.setAll(0, contour);
    // log('populated data into the buffer');

    final res = _getBoxes(_contourBuffer!);
    // log('called c++ function');

    return res.asTypedList(4900 * 81);
  }
}
