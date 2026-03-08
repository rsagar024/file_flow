import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

class GradientButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;

  const GradientButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 56,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withAlpha((0.3 * 255).toInt()), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: CustomTextStyles.custom16SemiBold.copyWith(letterSpacing: 0.5)),
      ),
    );
  }
}
