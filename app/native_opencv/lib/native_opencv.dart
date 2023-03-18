// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// load the c lib
final DynamicLibrary nativeLib = DynamicLibrary.open("libnative_opencv.so");

// C Functions signatures
typedef _c_detect_board = Pointer<Float> Function(Pointer<Uint8>, Int32, Int32, Int32, Pointer<Int32>);
typedef _c_extract_boxes = Void Function(Pointer<Utf8>);

// Dart Functions signatures
typedef _dart_detect_board = Pointer<Float> Function(Pointer<Uint8>, int, int, int, Pointer<Int32>);
typedef _dart_extract_boxes = void Function(Pointer<Utf8>);

// create dart functions that invoke the c functions
final _detectBoard = nativeLib.lookupFunction<_c_detect_board, _dart_detect_board>('detect_board');
final _extract_boxes = nativeLib.lookupFunction<_c_extract_boxes, _dart_extract_boxes>('extract_boxes');

class NativeOpenCV {
  Pointer<Uint8>? _imageBuffer;
  Pointer<Float>? _contourBuffer;

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

  void extractBoxes(String outputPath) {
    print(outputPath);
    _extract_boxes(outputPath.toNativeUtf8());
  }
}
