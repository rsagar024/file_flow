import 'package:fileflow/core/di/injection_container.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/services/image_picker_service.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ImageDialogManager {
  static Future<void> show(BuildContext context, FormFieldState<String> field, ValueChanged<String?> onChanged) async {
    final imagePickerService = getIt<ImagePickerService>();

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              StringConstants.kChooseImageSource,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(StringConstants.kGallery, style: TextStyle(color: context.colors.textPrimary)),
              onTap: () async {
                context.pop();
                try {
                  final imagePath = await imagePickerService.pickImage(source: ImageSource.gallery, maxFileSize: 10);
                  if (imagePath != null) {
                    field.didChange(imagePath);
                    onChanged(imagePath);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppColors.error));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(StringConstants.kCamera, style: TextStyle(color: context.colors.textPrimary)),
              onTap: () async {
                context.pop();
                try {
                  final imagePath = await imagePickerService.pickImage(source: ImageSource.camera, maxFileSize: 10);
                  if (imagePath != null) {
                    field.didChange(imagePath);
                    onChanged(imagePath);
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to take photo: $e'), backgroundColor: AppColors.error));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
