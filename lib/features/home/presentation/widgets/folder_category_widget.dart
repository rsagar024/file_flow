import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/features/home/presentation/widgets/folder_item_widget.dart';
import 'package:flutter/material.dart';

class FolderCategoryWidget extends FileFlowStatelessWidget {
  const FolderCategoryWidget({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: MediaQuery.paddingOf(context).bottom + 30),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final int crossAxisCount = constraints.maxWidth < 600
                    ? 3
                    : constraints.maxWidth < 900
                    ? 4
                    : 6;
                final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                return Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: 20,
                    children: List.generate(20, (index) {
                      return SizedBox(
                        width: itemWidth,
                        child: const FolderItemWidget(name: 'Work Folder'),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
