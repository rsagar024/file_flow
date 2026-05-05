import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FileFlowButton extends FileFlowStatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double height;
  final IconAlignment iconAlignment;

  const FileFlowButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.height = 50,
    this.iconAlignment = IconAlignment.end,
  });

  @override
  Widget buildContent(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: padding,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconAlignment == IconAlignment.start
            ? [icon!, const SizedBox(width: 8), _text()]
            : [_text(), const SizedBox(width: 8), icon!],
      );
    }

    return _text();
  }

  Widget _text() {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
    );
  }
}
