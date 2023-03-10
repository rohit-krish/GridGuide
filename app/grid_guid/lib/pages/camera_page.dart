import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/camera-page';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _camController;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _camController?.dispose();
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

    _camController = CameraController(
      desc,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
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
    if (mounted || !mounted) return;

    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(child: Text('loading'));
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
