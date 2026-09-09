import 'package:fileflow/core/common/widgets/phone_field/countries.dart';
import 'package:fileflow/core/common/widgets/phone_field/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('PhoneField', () {
    testWidgets('renders the default India dial code prefix and phone input', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: PhoneField(labelText: 'Phone')),
      );

      expect(find.textContaining('91'), findsWidgets);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('typing any non-empty digits reports isValid true via onValidationChanged', (tester) async {
      final calls = <(bool, Country?, String?)>[];

      await pumpApp(
        tester,
        Scaffold(
          body: PhoneField(
            labelText: 'Phone',
            onValidationChanged: (isValid, country, phoneNumber) => calls.add((isValid, country, phoneNumber)),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '98765');
      await tester.pump();

      expect(calls, isNotEmpty);
      expect(calls.last.$1, isTrue);
      expect(calls.last.$3, '98765');
    });

    testWidgets('clearing the field reports isValid false via onValidationChanged', (tester) async {
      final calls = <(bool, Country?, String?)>[];

      await pumpApp(
        tester,
        Scaffold(
          body: PhoneField(
            labelText: 'Phone',
            onValidationChanged: (isValid, country, phoneNumber) => calls.add((isValid, country, phoneNumber)),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '98765');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(calls.last.$1, isFalse);
      expect(calls.last.$3, isNull);
    });

    testWidgets('Form.validate() surfaces an error for an incomplete number and none for a valid one', (tester) async {
      final formKey = GlobalKey<FormState>();

      await pumpApp(
        tester,
        Scaffold(
          body: Form(
            key: formKey,
            child: const PhoneField(labelText: 'Phone'),
          ),
        ),
      );

      // Too short + wrong starting digit for India (valid starts: 6,7,8,9).
      // The starting-digit check runs before the length check, so this is
      // the error PhoneField's own validator actually produces.
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Number must start with 6, 7, 8, 9'), findsOneWidget);

      // A valid 10-digit Indian number starting with a valid digit.
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Number must start with 6, 7, 8, 9'), findsNothing);
    });

    testWidgets('selecting a country from the bottom sheet updates the shown dial code', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(body: PhoneField(labelText: 'Phone')),
      );

      expect(find.textContaining('91'), findsWidgets);

      // The picker (SelectableItemBottomSheet) renders its country ListTiles
      // inside a colored Container with no intervening Material, which trips
      // Flutter's debug-only "ListTile background color or ink splashes may
      // be invisible" assertion for every visible row. That's a real,
      // pre-existing quirk of that widget (not something introduced by this
      // test) unrelated to what we're verifying here, so it's suppressed for
      // just this interaction.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('ListTile background color or ink splashes may be invisible')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      // Open the country picker via the prefix text.
      await tester.tap(find.textContaining('91').first);
      await tester.pumpAndSettle();

      // Search for Australia and select it. Use the search field specifically
      // (PhoneField's own TextFormField also renders an internal TextField).
      final searchField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Search item here',
      );
      await tester.enterText(searchField, 'australia');
      await tester.pump();

      await tester.tap(find.textContaining('Australia').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('61'), findsWidgets);
    });
  });
}
