import 'dart:ui' as ui;

import 'package:fileflow/core/common/shapes/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackgroundPainter', () {
    test('paints without throwing for a normal size', () {
      final painter = BackgroundPainter(backgroundColor: Colors.white, isDark: false);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400, 800)), returnsNormally);

      recorder.endRecording();
    });

    test('paints without throwing for a small non-zero size', () {
      final painter = BackgroundPainter(backgroundColor: Colors.black, isDark: true);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(1, 1)), returnsNormally);

      recorder.endRecording();
    });

    group('shouldRepaint', () {
      test('returns false when backgroundColor and isDark are unchanged', () {
        final oldPainter = BackgroundPainter(backgroundColor: Colors.white, isDark: false);
        final newPainter = BackgroundPainter(backgroundColor: Colors.white, isDark: false);

        expect(newPainter.shouldRepaint(oldPainter), isFalse);
      });

      test('returns true when backgroundColor differs', () {
        final oldPainter = BackgroundPainter(backgroundColor: Colors.white, isDark: false);
        final newPainter = BackgroundPainter(backgroundColor: Colors.black, isDark: false);

        expect(newPainter.shouldRepaint(oldPainter), isTrue);
      });

      test('returns true when isDark differs', () {
        final oldPainter = BackgroundPainter(backgroundColor: Colors.white, isDark: false);
        final newPainter = BackgroundPainter(backgroundColor: Colors.white, isDark: true);

        expect(newPainter.shouldRepaint(oldPainter), isTrue);
      });
    });
  });
}
