import 'dart:ui' as ui;

import 'package:fileflow/core/common/shapes/sharp_divider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SharpDividerPainter', () {
    test('paints without throwing using default width and gradient', () {
      final painter = SharpDividerPainter();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(200, 10)), returnsNormally);

      recorder.endRecording();
    });

    test('paints without throwing using an explicit width and gradient shader', () {
      final shader = const LinearGradient(
        colors: [Colors.red, Colors.blue],
      ).createShader(const Rect.fromLTWH(0, 0, 200, 10));
      final painter = SharpDividerPainter(linearGradient: shader, width: 4);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(200, 10)), returnsNormally);

      recorder.endRecording();
    });

    test('shouldRepaint always returns false', () {
      final oldPainter = SharpDividerPainter();
      final newPainter = SharpDividerPainter(width: 10);

      expect(newPainter.shouldRepaint(oldPainter), isFalse);
    });
  });
}
