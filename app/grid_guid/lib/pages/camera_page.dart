import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../core/sudoku_detector.dart';
import '../core/detection_layer.dart';
import '../widgets/camera_page/click_button.dart';
import '../widgets/camera_page/when_dont_have_access_widget.dart';
import '../providers/camera_provider.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/camera-page';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _camController;
  late SudokuDetector _sudokuDetector;
  CameraProvider? _cameraProvider;

  double _camFrameToScreenScale = 0;
  int _camFrameRotation = 0;

  bool doHaveAccessToCamera = true;

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
      log("back camera not found :( weird");
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
    } on CameraException {
      doHaveAccessToCamera = false;
      log("don't have access to camera");
      setState(() {});
      return;
    } catch (e) {
      log('Error initializing camera, error: ${e.toString()}');
    }

    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if ((_cameraProvider != null) &&
        (_cameraProvider!.isImageCaptureButttonClicked)) {
      _camController!.pausePreview();

      if (_camFrameToScreenScale == 0) {
        var w = (_camFrameRotation == 0 || _camFrameRotation == 180)
            ? image.width
            : image.height;

        _camFrameToScreenScale = MediaQuery.of(context).size.width / w;
      }

      _cameraProvider!.detectBoard(
        image,
        _sudokuDetector,
        _camFrameRotation,
        _camFrameToScreenScale,
      );

      if (_cameraProvider!.isSnackBarShown == false) {
        _cameraProvider!.showSnackBar(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // if don't have access to camera
    if (!doHaveAccessToCamera) return WhenDontHaveAccessToCamera(width);

    // if camera controller not mounted
    if (_camController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    _cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final scale = 1 /
        (_camController!.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);

    return Scaffold(
      body: Stack(children: [
        // Transform.scale(
        //   scale: scale,
        //   alignment: Alignment.topCenter,
        //   child: Stack(
        //     children: [
        //       cameraView(),
        //       Consumer<CameraProvider>(
        //         builder: (ctx, cameraProvider, child) {
        //           return DetectionLayer(bbox: cameraProvider.bbox);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        Stack(
          children: [
            cameraView(),
            Consumer<CameraProvider>(
              builder: (ctx, cameraProvider, child) {
                return DetectionLayer(bbox: cameraProvider.bbox);
              },
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            top: height * 0.03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.black,
              ),
              Text(
                'Camera Mode',
                style: TextStyle(color: Colors.black, fontSize: width * .06),
              ),
              Consumer<CameraProvider>(
                  builder: (context, cameraProvider, child) {
                return IconButton(
                  onPressed: cameraProvider.isImageCaptureButttonClicked
                      ? () {}
                      : () {},
                  icon: const Icon(Icons.check_outlined),
                  color: cameraProvider.isImageCaptureButttonClicked
                      ? Colors.black
                      : Colors.transparent,
                );
              })
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.only(top: height * .67),
            child: Container(
              margin: EdgeInsets.only(top: height * .2),
              child: Consumer<CameraProvider>(
                  builder: (context, cameraProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClickButton(
                      show: cameraProvider.isImageCaptureButttonClicked,
                      Icons.lightbulb_outline_sharp,
                      width,
                      () async {
                        log('button clicked');
                        if (_cameraProvider!.isSolutionButtonClicked == false) {
                          final widgetToImageController =
                              ScreenshotController();
                          final bytes = await widgetToImageController
                              .captureFromWidget(cameraView());
                          log('extrackted the bytes');
                          _cameraProvider!.getSolution(bytes, context);
                        }
                      },
                    ),
                    if (!cameraProvider.isImageCaptureButttonClicked)
                      ClickButton(
                        Icons.camera,
                        width,
                        cameraProvider.imageCaptureButtonClicked,
                      ),
                    ClickButton(
                      show: cameraProvider.isImageCaptureButttonClicked,
                      Icons.autorenew,
                      width,
                      () {
                        _camController!.resumePreview();
                        cameraProvider.discardCurrentClickedImage();
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
        )
      ]),
    );
  }

  CameraPreview cameraView() => CameraPreview(_camController!);
}
