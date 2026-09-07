import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class UserAvatar extends FileFlowStatelessWidget {
  final String? imageUrl;
  final String? displayName;
  final double size;

  const UserAvatar({super.key, this.imageUrl, this.displayName, this.size = 96});

  String get _initials {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '';
    final parts = name.split(RegExp(r'\s+'));
    final first = parts[0][0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget buildContent(BuildContext context) {
    final hasImage = imageUrl.isNotNullOrEmpty;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.topLeftCirclePrimary],
              ),
      ),
      alignment: Alignment.center,
      child: hasImage ? _buildImage() : _buildFallback(),
    );
  }

  Widget _buildImage() {
    if (imageUrl!.isNetworkUrl) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorWidget: (context, url, error) => _buildFallback(),
        ),
      );
    }

    final file = File(imageUrl!);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    if (_initials.isEmpty) {
      return Icon(Icons.person, size: size * 0.5, color: AppColors.white);
    }
    return Text(
      _initials,
      style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: AppColors.white),
    );
  }
}
