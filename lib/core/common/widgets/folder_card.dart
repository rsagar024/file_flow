import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:flutter/material.dart';

class FolderCard extends FileFlowStatelessWidget {
  final double size;
  final double tabWidth;

  const FolderCard({super.key, this.size = 200, this.tabWidth = 0.54});

  @override
  Widget buildContent(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FolderPainter(tabWidth: tabWidth)),
    );
  }
}

class _FolderPainter extends CustomPainter {
  final double tabWidth;

  const _FolderPainter({required this.tabWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const Color backBodyTop = Color(0xFF29A0F2);
    const Color backBodyBot = Color(0xFF1888E8);
    const Color frontBodyTop = Color(0xFF7ED3FC);
    const Color frontBodyBot = Color(0xFF3B8EF5);
    const Color dividerTop = Color(0xFFFFFFFF);
    const Color dividerBot = Color(0xFFD0EBFF);

    final double padX = w * 0.035;
    final double padY = h * 0.12;

    final double folderW = w - padX * 2;
    final double folderH = h - padY * 2;

    final double tabH = folderH * 0.185;
    final double tabW = folderW * tabWidth;
    final double tabR = tabH * 0.70;

    final double bodyR = folderW * 0.075;
    final double backTop = padY + tabH * 0.55;

    final double divTop = padY + tabH + folderH * 0.035;
    final double divH = folderH * 0.15;

    final double frontTop = divTop + divH * 0.5;
    final double frontBot = padY + folderH;

    final double radius = tabR;
    const double cutWidth = 30;
    const double cutHeight = 20;

    final Path tabPath = Path();

    tabPath.moveTo(padX + radius, padY);

    tabPath.lineTo(padX + tabW - cutWidth, padY);

    tabPath.quadraticBezierTo(
      padX + tabW - cutWidth / 1.09,
      padY,
      padX + tabW,
      padY + cutHeight,
    );

    tabPath.lineTo(padX + tabW, padY + tabH + bodyR);

    tabPath.lineTo(padX, padY + tabH + bodyR);

    tabPath.lineTo(padX, padY + radius);

    tabPath.arcToPoint(
      Offset(padX + radius, padY),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    tabPath.close();

    final tabPaint = Paint()
      ..shader = const LinearGradient(
        colors: [backBodyTop, backBodyTop],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(padX, padY, tabW, tabH));

    canvas.drawPath(tabPath, tabPaint);

    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(padX, backTop, padX + folderW, frontBot),
      Radius.circular(bodyR),
    );

    const backGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backBodyTop, backBodyBot],
    );
    canvas.drawRRect(
      backRect,
      Paint()
        ..shader = backGrad.createShader(
          Rect.fromLTRB(padX, backTop, padX + folderW, frontBot),
        ),
    );

    const double margin = 10;
    final divRect = RRect.fromLTRBAndCorners(
      padX + margin,
      divTop,
      padX + folderW - margin,
      divTop + divH,
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    const divGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [dividerTop, dividerBot],
    );

    canvas.drawRRect(
      divRect,
      Paint()
        ..shader = divGrad.createShader(
          Rect.fromLTRB(
            padX + margin,
            divTop,
            padX + folderW - margin,
            divTop + divH,
          ),
        ),
    );

    final frontRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(padX, frontTop, padX + folderW, frontBot),
      const Radius.circular(6),
    );

    const frontGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.55, 1.0],
      colors: [frontBodyTop, Color(0xFF5AB8F8), frontBodyBot],
    );
    canvas.drawRRect(
      frontRect,
      Paint()
        ..shader = frontGrad.createShader(
          Rect.fromLTRB(padX, frontTop, padX + folderW, frontBot),
        ),
    );

    final highlightPaint = Paint()
      ..shader =
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromLTRB(
          padX,
          frontTop,
          padX + folderW,
          frontTop + folderH * 0.25,
        ),
      );

    canvas.save();
    canvas.clipRRect(frontRect);
    canvas.drawRect(
      Rect.fromLTRB(padX, frontTop, padX + folderW, frontTop + folderH * 0.25),
      highlightPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
