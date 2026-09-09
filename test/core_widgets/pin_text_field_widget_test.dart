import 'package:fileflow/core/common/widgets/pin_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

// The widget's own invisible `TextField` also renders an `EditableText` whose
// composing text matches the typed digit, so a plain `find.text(...)` finds
// both that and the visible pin-box `Text`. Restrict to plain `Text` widgets
// so these assertions only look at the pin boxes.
Finder _pinBoxText(String data) => find.byWidgetPredicate((widget) => widget is Text && widget.data == data);

void main() {
  group('PinTextFieldWidget', () {
    testWidgets('renders one box per digit of length', (tester) async {
      await pumpApp(tester, Scaffold(body: PinTextFieldWidget(length: 6)));

      final row = tester.widget<Row>(find.byType(Row));
      final boxCount = row.children.whereType<Container>().length;

      expect(boxCount, 6);
    });

    testWidgets('entering digits updates the widget-owned controller', (tester) async {
      final widget = PinTextFieldWidget(length: 4);
      await pumpApp(tester, Scaffold(body: widget));

      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();

      final rendered = tester.widget<PinTextFieldWidget>(find.byType(PinTextFieldWidget));
      expect(rendered.controller.text, '1234');

      // Flush the pending obscure timers before the widget disposes.
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('obscure:true shows the digit briefly then obscures it after 200ms', (tester) async {
      await pumpApp(tester, Scaffold(body: PinTextFieldWidget(length: 4)));

      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();

      expect(_pinBoxText('1'), findsOneWidget);
      expect(_pinBoxText('*'), findsNothing);

      await tester.pump(const Duration(milliseconds: 200));

      expect(_pinBoxText('1'), findsNothing);
      expect(_pinBoxText('*'), findsOneWidget);
    });

    testWidgets('obscure:false never obscures the digit', (tester) async {
      await pumpApp(tester, Scaffold(body: PinTextFieldWidget(length: 4, obscure: false)));

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      expect(_pinBoxText('5'), findsOneWidget);
      expect(_pinBoxText('*'), findsNothing);

      await tester.pump(const Duration(milliseconds: 200));

      expect(_pinBoxText('5'), findsOneWidget);
      expect(_pinBoxText('*'), findsNothing);
    });
  });
}
