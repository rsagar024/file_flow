import 'package:fileflow/core/common/base/presentation/file_flow_stateless_widget.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/features/home/presentation/widgets/folder_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FolderDetailsScreen extends FileFlowStatelessWidget {
  static const routeName = '/folder-details';

  const FolderDetailsScreen({super.key});

  String _getImageUrl(int index) {
    if (index % 3 == 0 && index % 5 == 0) {
      return 'https://images.pexels.com/photos/36597363/pexels-photo-36597363.jpeg';
    } else if (index % 3 == 0) {
      return 'https://images.pexels.com/photos/35927296/pexels-photo-35927296.jpeg';
    } else if (index % 5 == 0) {
      return 'https://images.pexels.com/photos/36681919/pexels-photo-36681919.png';
    } else {
      return 'https://images.pexels.com/photos/18578038/pexels-photo-18578038.jpeg';
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 40,
        surfaceTintColor: AppColors.transparent,
        animateColor: false,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Work Folder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const FolderDetailsScreen()));
                            },
                            child: SizedBox(
                              width: itemWidth,
                              child: const FolderItemWidget(name: 'Work Folder'),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.paddingOf(context).bottom + 10),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childCount: 18,
                itemBuilder: (context, index) {
                  return Image.network(key: ValueKey(index), _getImageUrl(index));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
