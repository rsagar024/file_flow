import 'package:fileflow/core/common/widgets/theme_mode_selector.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Color? _decorationColorFor(WidgetTester tester, String label) {
  final finder = find.ancestor(
    of: find.text(label),
    matching: find.byType(AnimatedContainer),
  );
  final container = tester.widget<AnimatedContainer>(finder);
  final decoration = container.decoration as BoxDecoration?;
  return decoration?.color;
}

void main() {
  group('ThemeModeSelector', () {
    testWidgets('renders System/Light/Dark segments', (tester) async {
      await pumpApp(
        tester,
        ThemeModeSelector(selectedMode: ThemeMode.system, onSelected: (_, _) {}),
      );

      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('the selected segment is highlighted with the active color', (tester) async {
      await pumpApp(
        tester,
        ThemeModeSelector(selectedMode: ThemeMode.light, onSelected: (_, _) {}),
      );

      expect(_decorationColorFor(tester, 'Light Mode'), SemanticColors.light.active);
      expect(_decorationColorFor(tester, 'System Default'), AppColors.transparent);
      expect(_decorationColorFor(tester, 'Dark Mode'), AppColors.transparent);
    });

    testWidgets('tapping an unselected segment invokes onSelected with the mode and an offset', (tester) async {
      final calls = <(ThemeMode, Offset)>[];

      await pumpApp(
        tester,
        ThemeModeSelector(
          selectedMode: ThemeMode.system,
          onSelected: (mode, origin) => calls.add((mode, origin)),
        ),
      );

      await tester.tap(find.text('Dark Mode'));
      await tester.pump();

      expect(calls, hasLength(1));
      expect(calls.single.$1, ThemeMode.dark);
      expect(calls.single.$2, isNotNull);
    });
  });
}
