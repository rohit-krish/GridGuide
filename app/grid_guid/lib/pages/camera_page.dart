import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:grid_guid/core/sudoku_detector.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/camera-page';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _camController;
  late SudokuDetector _sudokuDetector;
  int _camFrameRoatation = 0;
  int _lastRun = 0;


  @override
  void initState() {
    super.initState();
    _sudokuDetector = SudokuDetector();
    initCamera();
  }

  @override
  void dispose() {
    _camController?.dispose();
    _sudokuDetector.dispose();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _camController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    var idx =
        cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);

    if (idx < 0) {
      log("back camera not found");
      return;
    }

    var desc = cameras[idx];
    _camFrameRoatation = desc.sensorOrientation;

    _camController = CameraController(
      desc,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _camController!.initialize();
      await _camController!
          .startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      log('Error initializing camera, error: ${e.toString()}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) {
    // if (!mounted) return;
    if (!mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    // call the detector
    var res = _sudokuDetector.detect(image, _camFrameRoatation);
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    if (res == null || res.isEmpty) {
      return;
    } else {
      // log(res.toString());
      log("**************************************");
      log(res.toList(growable: false).toString());
      log("**************************************");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            CameraPreview(_camController!),
          ],
        ),
      ),
    );
  }
}
