import 'package:fileflow/core/common/widgets/folder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('FolderCard', () {
    testWidgets('renders without throwing', (tester) async {
      await pumpApp(tester, const FolderCard());

      expect(find.byType(FolderCard), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
