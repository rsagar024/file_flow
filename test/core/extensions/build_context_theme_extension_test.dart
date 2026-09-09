import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ThemeContextX.colors', () {
    testWidgets('resolves to SemanticColors.light under ThemeMode.light', (tester) async {
      late SemanticColors colors;

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox.shrink();
          },
        ),
        themeMode: ThemeMode.light,
      );

      expect(colors, SemanticColors.light);
    });

    testWidgets('resolves to SemanticColors.dark under ThemeMode.dark', (tester) async {
      late SemanticColors colors;

      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox.shrink();
          },
        ),
        themeMode: ThemeMode.dark,
      );

      expect(colors, SemanticColors.dark);
    });
  });
}
