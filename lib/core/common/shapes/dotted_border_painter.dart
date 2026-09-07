import 'dart:math';

import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  const DottedBorderPainter({required this.color, required this.strokeWidth, required this.dashPattern});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Path path = Path();

    _addDashedLine(path, const Offset(0, 0), Offset(size.width, 0));
    _addDashedLine(path, Offset(size.width, 0), Offset(size.width, size.height));
    _addDashedLine(path, Offset(size.width, size.height), Offset(0, size.height));
    _addDashedLine(path, Offset(0, size.height), const Offset(0, 0));

    canvas.drawPath(path, paint);
  }

  void _addDashedLine(Path path, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = sqrt(dx * dx + dy * dy);
    final double dashWidth = dashPattern[0];
    final double gapWidth = dashPattern[1];
    final int dashCount = (distance / (dashWidth + gapWidth)).floor();

    double currentLength = 0;
    for (int i = 0; i < dashCount; i++) {
      final double startX = start.dx + (dx * (currentLength / distance));
      final double startY = start.dy + (dy * (currentLength / distance));
      currentLength += dashWidth;
      final double endX = start.dx + (dx * (currentLength / distance));
      final double endY = start.dy + (dy * (currentLength / distance));

      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
      currentLength += gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
