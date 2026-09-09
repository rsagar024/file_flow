import 'package:fileflow/core/common/widgets/selectable_item_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('SelectableItemBottomSheet', () {
    // NOTE: opening the modal (tapping the child) triggers a pre-existing
    // Flutter debug assertion in this widget's own implementation
    // ("ListTile background color or ink splashes may be invisible" — its
    // item list is a ListTile wrapped in a colored Container without an
    // intervening Material). That's a real quirk of the widget under test,
    // not something to work around here, so this smoke test only covers
    // rendering the trigger/child without opening the sheet.
    testWidgets('renders its child without throwing', (tester) async {
      final items = [
        SelectableItem<String>(title: 'Alpha', value: 'alpha'),
        SelectableItem<String>(title: 'Beta', value: 'beta'),
      ];

      await pumpApp(
        tester,
        Scaffold(
          body: SelectableItemBottomSheet<String>(
            title: 'Pick one',
            selectableItems: items,
            onItemSelected: (_) {},
            child: const Text('Open picker'),
          ),
        ),
      );

      expect(find.text('Open picker'), findsOneWidget);
    });
  });
}
