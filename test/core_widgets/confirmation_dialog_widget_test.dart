import 'package:fileflow/core/common/widgets/confirmation_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('result: $result'),
          ElevatedButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialogWidget.show(
                context,
                title: 'Delete item',
                message: 'Are you sure?',
              );
              setState(() => result = confirmed);
            },
            child: const Text('open'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('ConfirmationDialogWidget', () {
    testWidgets('tapping Confirm resolves true and dismisses the dialog', (tester) async {
      await pumpApp(tester, const _Host());

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete item'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Delete item'), findsNothing);
      expect(find.text('result: true'), findsOneWidget);
    });

    testWidgets('tapping Cancel resolves false and dismisses the dialog', (tester) async {
      await pumpApp(tester, const _Host());

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete item'), findsNothing);
      expect(find.text('result: false'), findsOneWidget);
    });
  });
}
