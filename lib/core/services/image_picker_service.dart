import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _imagePicker;

  ImagePickerService({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  Future<String?> pickImage({ImageSource source = ImageSource.gallery, int? maxFileSize}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (maxFileSize != null) {
          final fileSizeInMB = await _getFileSizeInMB(pickedFile.path);
          if (fileSizeInMB > maxFileSize) {
            throw Exception('File size exceeds ${maxFileSize}MB limit');
          }
        }

        return pickedFile.path;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<List<String>> pickMultipleImages({int? maxFileSize}) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final paths = <String>[];

        for (final pickedFile in pickedFiles) {
          if (maxFileSize != null) {
            final fileSizeInMB = await _getFileSizeInMB(pickedFile.path);
            if (fileSizeInMB > maxFileSize) {
              continue;
            }
          }

          paths.add(pickedFile.path);
        }

        return paths;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  bool isValidImageFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final extension = file.path.split('.').last.toLowerCase();
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

    return validExtensions.contains(extension);
  }

  Future<double> _getFileSizeInMB(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;

    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  double getFileSizeInMB(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return 0;

    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  Future<String?> compressImage(String filePath, {int quality = 80}) async {
    return filePath;
  }
}
