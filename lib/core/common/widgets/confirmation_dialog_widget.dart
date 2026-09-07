import 'package:fileflow/core/common/widgets/file_flow_button.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

class ConfirmationDialogWidget {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomTextStyles.custom18SemiBold.copyWith(
                  color: dialogContext.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: CustomTextStyles.custom14Regular.copyWith(
                  color: dialogContext.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FileFlowButton(
                      text: cancelText,
                      backgroundColor: dialogContext.colors.surfaceVariant,
                      textColor: dialogContext.colors.textPrimary,
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FileFlowButton(
                      text: confirmText,
                      backgroundColor: isDestructive
                          ? AppColors.error
                          : AppColors.primary,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
