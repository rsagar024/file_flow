import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = AppColors.neutral900);

    // Top-left purple radial glow
    final topLeftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.topLeftCirclePrimary.withValues(alpha: 0.8),
          AppColors.topLeftCircleSecondary.withValues(alpha: 0.2),
          AppColors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.75));
    canvas.drawCircle(const Offset(0, 0), size.width * 0.75, topLeftPaint);

    // Bottom-right teal radial glow
    final bottomRightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.bottomRightCirclePrimary.withValues(alpha: 0.8),
          AppColors.bottomRightCircleSecondary.withValues(alpha: 0.2),
          AppColors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.75));
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.75, bottomRightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
