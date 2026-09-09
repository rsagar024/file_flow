import 'package:fileflow/core/common/widgets/file_flow_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FileFlowAppBar', () {
    testWidgets('renders with a title without throwing', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(appBar: FileFlowAppBar(title: 'Home'), body: SizedBox()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('renders leading and trailing widgets when provided', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          appBar: FileFlowAppBar(
            title: 'Home',
            leading: Icon(Icons.arrow_back),
            trailing: Icon(Icons.settings),
          ),
          body: SizedBox(),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
