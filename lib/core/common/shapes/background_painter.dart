import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final Color backgroundColor;
  final bool isDark;

  BackgroundPainter({required this.backgroundColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = backgroundColor);

    final primaryAlpha = isDark ? 0.8 : 0.25;
    final secondaryAlpha = isDark ? 0.2 : 0.08;

    // Top-left purple radial glow
    final topLeftPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.topLeftCirclePrimary.withValues(alpha: primaryAlpha),
          AppColors.topLeftCircleSecondary.withValues(alpha: secondaryAlpha),
          AppColors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(0, 0), radius: size.width * 0.75));
    canvas.drawCircle(const Offset(0, 0), size.width * 0.75, topLeftPaint);

    // Bottom-right teal radial glow
    final bottomRightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.bottomRightCirclePrimary.withValues(alpha: primaryAlpha),
          AppColors.bottomRightCircleSecondary.withValues(alpha: secondaryAlpha),
          AppColors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.75));
    canvas.drawCircle(Offset(size.width, size.height), size.width * 0.75, bottomRightPaint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor || oldDelegate.isDark != isDark;
}
