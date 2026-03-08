import 'package:flutter/material.dart';

class SharpDividerPainter extends CustomPainter {
  final Shader? linearGradient;
  final double? width;

  SharpDividerPainter({this.linearGradient, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = width ?? 2
      ..style = PaintingStyle.stroke
      ..shader =
          linearGradient ??
          const LinearGradient(
            colors: [Colors.transparent, Colors.grey, Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
