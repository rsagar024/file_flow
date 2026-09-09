import 'package:fileflow/core/extensions/media_query_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaQueryExtension', () {
    testWidgets('computes screen size, padding, and percentage helpers from MediaQueryData', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(top: 20, bottom: 10),
              viewInsets: EdgeInsets.only(bottom: 50),
            ),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(capturedContext.screenWidth, 400);
      expect(capturedContext.screenHeight, 800);
      expect(capturedContext.topPadding, 20);
      expect(capturedContext.bottomPadding, 10);
      expect(capturedContext.viewInsetsBottom, 50);
      expect(capturedContext.bottomPaddingZero, isFalse);
      expect(capturedContext.heightPercentage(50), 400);
      expect(capturedContext.widthPercentage(25), 100);
    });

    testWidgets('bottomPaddingZero is true when bottom padding is zero', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(capturedContext.bottomPaddingZero, isTrue);
    });
  });
}
