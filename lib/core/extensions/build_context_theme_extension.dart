import 'package:fileflow/core/themes/semantic_colors.dart';
import 'package:flutter/material.dart';

extension ThemeContextX on BuildContext {
  SemanticColors get colors => Theme.of(this).extension<SemanticColors>()!;
}
