import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF070D1F));

    // Top-left purple radial glow
    final topLeftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2D1B5E).withValues(alpha: 0.8),
          const Color(0xFF1A1040).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.75));
    canvas.drawCircle(const Offset(0, 0), size.width * 0.75, topLeftPaint);

    // Bottom-right teal radial glow
    final bottomRightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D3B5E).withValues(alpha: 0.8),
          const Color(0xFF081E35).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.75));
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.75, bottomRightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
