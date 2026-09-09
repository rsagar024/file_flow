import 'dart:math' as math;

import 'package:fileflow/core/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ThemeRevealController {
  ThemeRevealController._();

  static final ThemeRevealController instance = ThemeRevealController._();

  static final GlobalKey repaintKey = GlobalKey();

  Future<void> toggleWithReveal({
    required BuildContext context,
    required Offset origin,
    required TickerProvider vsync,
    required VoidCallback applyNewTheme,
  }) async {
    final overlay = AppRoute.navigatorKey.currentState?.overlay;
    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (overlay == null || boundary == null) {
      applyNewTheme();
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final size = mediaQuery.size;

    final image = await boundary.toImage(pixelRatio: devicePixelRatio);

    applyNewTheme();

    final maxRadius = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((corner) => (corner - origin).distance).reduce(math.max);

    final controller = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 500));
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: curved,
          builder: (_, _) {
            return ClipPath(
              clipper: _RevealClipper(center: origin, radius: curved.value * maxRadius),
              child: SizedBox.expand(
                child: RawImage(image: image, fit: BoxFit.cover),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
    try {
      await controller.forward();
    } finally {
      entry.remove();
      controller.dispose();
      image.dispose();
    }
  }
}

class _RevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _RevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final fullScreen = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    return Path.combine(PathOperation.difference, fullScreen, hole);
  }

  @override
  bool shouldReclip(covariant _RevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
