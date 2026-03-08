import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? disabledColor;
  final Color? splashColor;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final double elevation;
  final bool isLoading;
  final bool enabled;
  final MainAxisAlignment alignment;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.child,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.gradient,
    this.disabledColor,
    this.splashColor,
    this.textStyle,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
    this.elevation = 0,
    this.isLoading = false,
    this.enabled = true,
    this.alignment = MainAxisAlignment.center,
  });

  bool get _isInteractive => enabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final Widget content =
        child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: alignment,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                if (isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                if (child == null && !isLoading) Flexible(child: Text(text, style: textStyle, overflow: TextOverflow.ellipsis)) else if (child != null && !isLoading) Flexible(child: child!),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            );

    final BoxDecoration decoration = BoxDecoration(
      color: gradient == null ? backgroundColor : null,
      gradient: gradient,
      borderRadius: borderRadius,
      border: border,
      boxShadow: elevation > 0 ? [BoxShadow(color: Colors.black.withAlpha((0.12 * 255).toInt()), blurRadius: elevation, offset: Offset(0, elevation / 2))] : null,
    );

    return Container(
      margin: margin,
      width: width,
      height: height ?? 50,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: decoration,
          child: InkWell(onTap: _isInteractive ? onPressed : null, borderRadius: borderRadius, splashColor: splashColor, child: Padding(padding: padding, child: Center(child: content))),
        ),
      ),
    );
  }
}