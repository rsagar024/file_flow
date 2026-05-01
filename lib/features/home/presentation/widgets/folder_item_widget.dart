import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/common/widgets/folder_card.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FolderItemWidget extends FileFlowStatelessWidget {
  final String name;

  const FolderItemWidget({super.key, required this.name});

  @override
  Widget buildContent(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width / 3 - 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FolderCard(size: cardWidth),

        SizedBox(
          width: cardWidth,
          child: Text(
            name,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
