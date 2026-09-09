import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FileFlowButton', () {
    testWidgets('isLoading true shows a progress indicator and ignores taps', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        FileFlowButton(
          text: 'Submit',
          isLoading: true,
          onPressed: () => tapCount++,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('isLoading false renders label and taps invoke onPressed', (tester) async {
      var tapCount = 0;

      await pumpApp(
        tester,
        FileFlowButton(
          text: 'Submit',
          onPressed: () => tapCount++,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('null onPressed disables the button and taps do nothing', (tester) async {
      await pumpApp(
        tester,
        const FileFlowButton(text: 'Submit', onPressed: null),
      );

      expect(find.text('Submit'), findsOneWidget);

      // Should not throw even though there is no callback to invoke.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Submit'), findsOneWidget);
    });
  });
}
