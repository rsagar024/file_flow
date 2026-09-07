import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

typedef ThemeModeOptionSelected = void Function(ThemeMode mode, Offset origin);

class ThemeModeSelector extends FileFlowStatelessWidget {
  final ThemeMode selectedMode;
  final ThemeModeOptionSelected onSelected;

  const ThemeModeSelector({super.key, required this.selectedMode, required this.onSelected});

  static const _options = <ThemeMode, String>{
    ThemeMode.system: StringConstants.kSystemDefault,
    ThemeMode.light: StringConstants.kLightMode,
    ThemeMode.dark: StringConstants.kDarkMode,
  };

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.entries.map((entry) {
          final isSelected = entry.key == selectedMode;
          return _ThemeModeSegment(
            label: entry.value,
            isSelected: isSelected,
            onTap: (origin) => onSelected(entry.key, origin),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeModeSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<Offset> onTap;

  const _ThemeModeSegment({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          final renderBox = context.findRenderObject() as RenderBox;
          final origin = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          onTap(origin);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.active : AppColors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: CustomTextStyles.custom12Medium.copyWith(
              color: isSelected ? AppColors.white : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
