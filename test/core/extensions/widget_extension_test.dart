import 'package:fileflow/core/extensions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('TextWidgetExtension.appendDot', () {
    testWidgets('wraps the text in a Flexible row and appends a bullet separator', (tester) async {
      await pumpApp(tester, Row(children: [const Text('hello').appendDot()]));

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('•'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('hello'), matching: find.byType(Flexible)),
        findsWidgets,
      );
    });
  });

  group('TextWidgetExtension.withFlexible', () {
    testWidgets('wraps the text in a single Flexible with the same data', (tester) async {
      await pumpApp(tester, Row(children: [const Text('hello').withFlexible()]));

      final flexible = tester.widget<Flexible>(find.byType(Flexible));
      expect(flexible.child, isA<Text>());
      expect((flexible.child as Text).data, 'hello');
    });
  });
}
