import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../widgets/camera_page/click_button.dart' show ClickButton;
import '../core/sudoku_detector.dart';
import '../core/detection_layer.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/camera-page';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _camController;
  late SudokuDetector _sudokuDetector;
  int _camFrameRotation = 0;
  List<double> _bbox = List.empty();
  int _lastRun = 0;
  double _camFrameToScreenScale = 0;

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
    _camFrameRotation = desc.sensorOrientation;

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

    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) {
    if (!mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    if (_camFrameToScreenScale == 0) {
      var w = (_camFrameRotation == 0 || _camFrameRotation == 180)
          ? image.width
          : image.height;

      _camFrameToScreenScale = MediaQuery.of(context).size.width / w;
    }

    // call the detector
    var res = _sudokuDetector.detect(image, _camFrameRotation);
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    if (res == null || res.isEmpty) {
      return;
    }

    setState(() {
      // _bbox = res.toList(growable: false);
      _bbox =
          res.map((x) => x * _camFrameToScreenScale).toList(growable: false);
      _bbox = _sudokuDetector.reorder(_bbox);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final scale = 1 /
        (_camController!.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Stack(children: [
          CameraPreview(_camController!),
          DetectionLayer(bbox: _bbox),
          Padding(
            padding: EdgeInsets.only(
              top: height * 0.025,
              left: width * 0.02,
              right: width * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_sharp),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.black,
                ),
                const Text(
                  'Camera Mode',
                  style: TextStyle(color: Colors.black),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check_outlined),
                  color: Colors.black,
                )
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.only(top: height * .50),
              child: Container(
                margin: EdgeInsets.only(top: height * .22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClickButton(Icons.auto_fix_high_outlined, width, () {}),
                    // check_outlined , camera
                    ClickButton(Icons.camera, width, () {}),
                    ClickButton(Icons.autorenew, width, () {}),
                  ],
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
