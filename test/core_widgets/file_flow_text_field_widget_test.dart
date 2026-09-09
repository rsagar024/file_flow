import 'package:fileflow/core/common/widgets/file_flow_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FileFlowTextFieldWidget', () {
    testWidgets('typing text triggers onChanged and updates field value', (tester) async {
      String? changedValue;
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Form(
            key: formKey,
            child: FileFlowTextFieldWidget(
              hintText: 'Enter name',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Sagar');
      await tester.pump();

      expect(changedValue, 'Sagar');
    });

    testWidgets('validator returning an error surfaces error text below the field', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Form(
            key: formKey,
            child: FileFlowTextFieldWidget(
              hintText: 'Enter name',
              validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
            ),
          ),
        ),
      );

      expect(find.text('This field is required'), findsNothing);

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('hintText renders and initial controller value is shown', (tester) async {
      final controller = TextEditingController(text: 'Initial Value');

      await pumpApp(
        tester,
        Scaffold(
          body: FileFlowTextFieldWidget(
            hintText: 'Enter name',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Enter name'), findsOneWidget);
      expect(find.text('Initial Value'), findsOneWidget);
    });
  });
}
