import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color inactive;
  final Color active;
  final Color pressed;
  final Color disabled;

  const SemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.inactive,
    required this.active,
    required this.pressed,
    required this.disabled,
  });

  static const dark = SemanticColors(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textDisabled: AppColors.textDisabled,
    inactive: AppColors.inactive,
    active: AppColors.active,
    pressed: AppColors.pressed,
    disabled: AppColors.disabled,
  );

  static const light = SemanticColors(
    background: AppColors.neutral50,
    surface: AppColors.white,
    surfaceVariant: AppColors.neutral200,
    textPrimary: AppColors.neutral900,
    textSecondary: AppColors.neutral400,
    textTertiary: AppColors.neutral300,
    textDisabled: AppColors.neutral300,
    inactive: AppColors.neutral400,
    active: AppColors.primary,
    pressed: AppColors.pressed,
    disabled: AppColors.neutral300,
  );

  @override
  SemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? inactive,
    Color? active,
    Color? pressed,
    Color? disabled,
  }) {
    return SemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      inactive: inactive ?? this.inactive,
      active: active ?? this.active,
      pressed: pressed ?? this.pressed,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return t < 0.5 ? this : other;
  }
}
