import 'package:flutter/material.dart';

class DetectionLayer extends StatelessWidget {
  final List<double> bbox;
  const DetectionLayer({required this.bbox, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoundingBoxPainter(bbox: bbox),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<double> bbox;

  BoundingBoxPainter({required this.bbox});

  final _paint = Paint()
    ..strokeWidth = 2.0
    ..color = Colors.green
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (bbox.isEmpty) return;

    final topLeft      = Offset(bbox[0], bbox[1]);
    final topRight     = Offset(bbox[2], bbox[3]);
    final bottomLeft   = Offset(bbox[4], bbox[5]);
    final bottomRight  = Offset(bbox[6], bbox[7]);

    canvas.drawLine(topLeft, topRight, _paint);
    canvas.drawLine(topRight, bottomRight, _paint);
    canvas.drawLine(bottomRight, bottomLeft, _paint);
    canvas.drawLine(bottomLeft, topLeft, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
