import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FileListItemWidget extends FileFlowStatelessWidget {
  final String imageUrl;
  final String fileName;
  final String fileSize;
  final String fileDate;

  const FileListItemWidget({
    super.key,
    required this.imageUrl,
    required this.fileName,
    required this.fileSize,
    required this.fileDate,
  });

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.white12, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(fileSize, style: const TextStyle(color: AppColors.white54, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: AppColors.white54, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(fileDate, style: const TextStyle(color: AppColors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.white54),
          ),
        ],
      ),
    );
  }
}
