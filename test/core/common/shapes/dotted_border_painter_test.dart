import 'dart:ui' as ui;

import 'package:fileflow/core/common/shapes/dotted_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DottedBorderPainter', () {
    test('paints without throwing for a normal size and dash pattern', () {
      const painter = DottedBorderPainter(color: Colors.grey, strokeWidth: 1, dashPattern: [4, 4]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(200, 100)), returnsNormally);

      recorder.endRecording();
    });

    test('throws when the dash pattern sums to zero (distance / 0 produces an un-floorable Infinity)', () {
      const painter = DottedBorderPainter(color: Colors.grey, strokeWidth: 1, dashPattern: [0, 0]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(200, 100)), throwsA(isA<UnsupportedError>()));

      recorder.endRecording();
    });

    test('does not throw for a zero size (each edge has zero length, so no dash segments are computed)', () {
      const painter = DottedBorderPainter(color: Colors.grey, strokeWidth: 1, dashPattern: [4, 4]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, Size.zero), returnsNormally);

      recorder.endRecording();
    });

    test('shouldRepaint always returns false regardless of constructor params', () {
      const oldPainter = DottedBorderPainter(color: Colors.grey, strokeWidth: 1, dashPattern: [4, 4]);
      const newPainter = DottedBorderPainter(color: Colors.red, strokeWidth: 3, dashPattern: [1, 1]);

      expect(newPainter.shouldRepaint(oldPainter), isFalse);
    });
  });
}
