import 'dart:io';

import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/utilities/image_dialog_manager.dart';
import 'package:flutter/material.dart';

class ProfileImagePickerWidget extends FormField<String> {
  ProfileImagePickerWidget({
    super.key,
    required BuildContext context,
    required String? imagePath,
    required ValueChanged<String?> onChanged,
    required bool isEditing,
  }) : super(
         initialValue: imagePath,
         validator: (value) {
           if (value == null || value.isEmpty) {
             return StringConstants.kProfileImageIsRequired;
           }
           return null;
         },
         builder: (field) {
           final hasError = field.hasError;

           return Column(
             children: [
               Container(
                 height: 120,
                 width: double.infinity,
                 margin: const EdgeInsets.symmetric(vertical: 16),
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     Container(
                       height: 100,
                       width: 100,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(color: hasError ? AppColors.red : AppColors.grey, width: 2),
                       ),
                       alignment: Alignment.center,
                       child: _buildImageWidget(field.value),
                     ),

                     if (isEditing)
                       Positioned(
                         bottom: 10,
                         right: MediaQuery.sizeOf(context).width / 2 - 50 - 10,
                         child: GestureDetector(
                           onTap: () async {
                             await ImageDialogManager.show(context, field, onChanged);
                           },
                           child: const CircleAvatar(
                             radius: 15,
                             backgroundColor: AppColors.primary,
                             child: Icon(Icons.edit, size: 12, color: AppColors.white),
                           ),
                         ),
                       ),
                   ],
                 ),
               ),

               if (hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(field.errorText!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                 ),
             ],
           );
         },
       );

  static Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.person, size: 30, color: AppColors.grey);
    }

    if (imagePath.isNetworkUrl) {
      return ClipOval(
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 30, color: AppColors.error);
          },
        ),
      );
    }

    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 30, color: AppColors.error);
            },
          ),
        );
      } else {
        return const Icon(Icons.image_not_supported, size: 30, color: AppColors.error);
      }
    } catch (e) {
      return const Icon(Icons.error, size: 30, color: AppColors.error);
    }
  }
}
