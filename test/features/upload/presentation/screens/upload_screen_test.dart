import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the static upload UI', (tester) async {
    await pumpApp(tester, const UploadScreen());
    await tester.pumpAndSettle();

    expect(find.text(StringConstants.kSelectYourFiles), findsOneWidget);
    expect(find.text(StringConstants.kRoot), findsOneWidget);
    expect(find.text(StringConstants.kLocation), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, StringConstants.kUploadFile), findsOneWidget);
    expect(find.byIcon(Icons.upload_sharp), findsOneWidget);
    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
  });

  testWidgets('tapping the no-op buttons does not throw or change visible state', (tester) async {
    await pumpApp(tester, const UploadScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text(StringConstants.kRoot));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, StringConstants.kUploadFile));
    await tester.pumpAndSettle();

    // Everything on screen is still exactly as it was — the handlers are
    // empty no-ops, so nothing should have changed.
    expect(find.text(StringConstants.kSelectYourFiles), findsOneWidget);
    expect(find.text(StringConstants.kRoot), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, StringConstants.kUploadFile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
