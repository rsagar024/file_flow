import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
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
      decoration: BoxDecoration(color: context.colors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
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
                  style: TextStyle(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(fileSize, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: context.colors.textSecondary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(fileDate, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
